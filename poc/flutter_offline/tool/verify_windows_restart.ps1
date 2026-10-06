param(
  [string]$App = (Join-Path $PSScriptRoot '..\build\windows\x64\runner\Release\nexo_offline_poc.exe'),
  [string]$ApiDirectory = (Join-Path $PSScriptRoot '..\..\api'),
  [int]$Port = 3011
)

$ErrorActionPreference = 'Stop'
$App = (Resolve-Path $App).Path
$ApiDirectory = (Resolve-Path $ApiDirectory).Path
$runtime = (Resolve-Path (Join-Path $PSScriptRoot '..\..\.runtime')).Path
$evidence = Join-Path $runtime 'windows-restart-validation.log'
$accountId = 't005-relaunch-account'
$movementIds = @('t005-relaunch-income', 't005-relaunch-expense')
$apiUrl = "http://127.0.0.1:$Port"

if (Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue) {
  throw "El puerto $Port ya está ocupado. Elige otro puerto libre para esta prueba."
}

$dataDirectory = Join-Path $runtime ('windows-restart-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $dataDirectory | Out-Null
Set-Content -Path $evidence -Value "$(Get-Date -Format o) app=$App API=$apiUrl data=$dataDirectory" -Encoding utf8
$snapshot = [ordered]@{
  version = 2
  revision = 3
  account = [ordered]@{
    id = $accountId
    name = 'Cuenta sintética relanzamiento'
    openingCents = 1000000
    status = 'pending'
    syncError = $null
    syncRejected = $false
  }
  movements = @(
    [ordered]@{
      id = $movementIds[0]; description = 'Ingreso sintético reinicio'; cents = 125000
      type = 'income'; createdAt = '2026-10-05T12:00:00.000Z'; status = 'pending'
      syncError = $null; syncRejected = $false
    },
    [ordered]@{
      id = $movementIds[1]; description = 'Gasto sintético reinicio'; cents = 2500
      type = 'expense'; createdAt = '2026-10-05T12:01:00.000Z'; status = 'pending'
      syncError = $null; syncRejected = $false
    }
  )
  serverBalanceCents = $null
}
$snapshotJson = $snapshot | ConvertTo-Json -Depth 8
[IO.File]::WriteAllText(
  (Join-Path $dataDirectory 'nexo_offline_poc.json.r3.json'),
  $snapshotJson,
  [Text.UTF8Encoding]::new($false)
)
Push-Location $ApiDirectory
try {
  & node 'dist/test/cleanup-account.js' $accountId
  if ($LASTEXITCODE -ne 0) { throw 'No se pudo limpiar la cuenta sintética anterior.' }
} finally {
  Pop-Location
}

$appProcess = $null
$apiProcess = $null
$previousPort = $env:PORT
try {
  $env:NEXO_DATA_DIRECTORY = $dataDirectory
  $env:PORT = "$Port"
  Remove-Item Env:NEXO_SYNC_ON_START -ErrorAction SilentlyContinue
  $appProcess = Start-Process -FilePath $App -PassThru
  Start-Sleep -Seconds 3
  $appProcess.Refresh()
  if ($appProcess.HasExited -or $appProcess.MainWindowHandle -eq [IntPtr]::Zero) {
    throw 'La ventana del ejecutable no quedó disponible en el primer arranque.'
  }
  $appProcess.Refresh()
  if ($appProcess.HasExited) { throw 'El ejecutable cerró durante el primer arranque offline.' }
  "$(Get-Date -Format o) app offline PID=$($appProcess.Id); cola local seed: cuenta + 2 movimientos" |
    Add-Content -Encoding utf8 $evidence
  Stop-Process -Id $appProcess.Id -Force
  $appProcess.WaitForExit()
  "$(Get-Date -Format o) app cerrada PID=$($appProcess.Id)" | Add-Content -Encoding utf8 $evidence
  $appProcess = $null

  $apiProcess = Start-Process -FilePath 'node' -ArgumentList 'dist/src/main.js' `
    -WorkingDirectory $ApiDirectory -PassThru -NoNewWindow `
    -RedirectStandardOutput (Join-Path $runtime 'windows-restart-api.stdout.log') `
    -RedirectStandardError (Join-Path $runtime 'windows-restart-api.stderr.log')
  $apiReady = $false
  for ($attempt = 0; $attempt -lt 100; $attempt++) {
    try {
      $null = Invoke-RestMethod "$apiUrl/accounts/not-yet-created" -TimeoutSec 1
    } catch {
      if ($_.Exception.Response.StatusCode.value__ -eq 404) { $apiReady = $true; break }
    }
    Start-Sleep -Milliseconds 100
  }
  if (-not $apiReady) { throw 'La API PostgreSQL no respondió después de reactivarla.' }
  "$(Get-Date -Format o) API reactivada PID=$($apiProcess.Id)" | Add-Content -Encoding utf8 $evidence

  $env:NEXO_SYNC_ON_START = '1'
  $appProcess = Start-Process -FilePath $App -PassThru
  $account = $null
  for ($attempt = 0; $attempt -lt 100; $attempt++) {
    try {
      $account = Invoke-RestMethod "$apiUrl/accounts/$accountId" -TimeoutSec 1
      if ($account.movements.Count -eq 2) { break }
    } catch { }
    Start-Sleep -Milliseconds 200
  }
  if ($null -eq $account -or $account.movements.Count -ne 2) {
    throw 'La app relanzada no reprodujo los dos movimientos pendientes.'
  }
  if ($account.balanceCents -ne '1122500') { throw "Saldo inesperado: $($account.balanceCents)." }
  if (@($account.movements.id | Sort-Object) -join ',' -ne (@($movementIds | Sort-Object) -join ',')) {
    throw 'IDs sincronizados distintos a la cola persistida.'
  }

  $saved = $null
  for ($attempt = 0; $attempt -lt 100; $attempt++) {
    $latest = Get-ChildItem $dataDirectory -Filter 'nexo_offline_poc.json.r*.json' |
      Sort-Object { [int]([regex]::Match($_.Name, '\.r(\d+)\.json$').Groups[1].Value) } -Descending |
      Select-Object -First 1
    try { $saved = Get-Content $latest.FullName -Raw | ConvertFrom-Json }
    catch { $saved = $null }
    if ($saved -and $saved.account.status -eq 'synced' -and
        @($saved.movements | Where-Object status -ne 'synced').Count -eq 0) { break }
    Start-Sleep -Milliseconds 100
  }
  if ($null -eq $saved) { throw 'No se pudo leer la cola local sincronizada.' }
  if ($saved.account.status -ne 'synced' -or @($saved.movements | Where-Object status -ne 'synced').Count -ne 0) {
    throw 'El almacén local no persistió los estados sincronizados tras el relanzamiento.'
  }
  "$(Get-Date -Format o) app relanzada PID=$($appProcess.Id); movimientos=2; balanceCents=1122500; cola local=sincronizada" |
    Add-Content -Encoding utf8 $evidence

  Stop-Process -Id $appProcess.Id -Force
  $appProcess.WaitForExit()
  $appProcess = Start-Process -FilePath $App -PassThru
  Start-Sleep -Seconds 3
  $appProcess.Refresh()
  if ($appProcess.HasExited -or $appProcess.MainWindowHandle -eq [IntPtr]::Zero) {
    throw 'La instancia final no quedó abierta para inspección visual.'
  }
  $account = Invoke-RestMethod "$apiUrl/accounts/$accountId"
  if ($account.movements.Count -ne 2 -or $account.balanceCents -ne '1122500') {
    throw 'El segundo relanzamiento generó duplicados o alteró el saldo.'
  }
  "$(Get-Date -Format o) replay tras segundo relanzamiento: filas=2; saldoCents=1122500; sin duplicados" |
    Add-Content -Encoding utf8 $evidence
  "Prueba completa. Evidencia: $evidence"
  "App visual disponible: PID $($appProcess.Id); API PID $($apiProcess.Id); cuenta sintética $accountId"
} catch {
  if ($appProcess -and -not $appProcess.HasExited) { Stop-Process -Id $appProcess.Id -Force }
  if ($apiProcess -and -not $apiProcess.HasExited) { Stop-Process -Id $apiProcess.Id -Force }
  throw
} finally {
  Remove-Item Env:NEXO_DATA_DIRECTORY -ErrorAction SilentlyContinue
  Remove-Item Env:NEXO_SYNC_ON_START -ErrorAction SilentlyContinue
  if ($null -eq $previousPort) { Remove-Item Env:PORT -ErrorAction SilentlyContinue }
  else { $env:PORT = $previousPort }
}
