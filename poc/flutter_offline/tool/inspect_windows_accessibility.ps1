[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateRange(1, 2147483647)]
    [int] $ProcessId,

    [string] $WindowName = 'nexo_offline_poc',

    [string] $SectionName = 'Política de privacidad y datos personales',

    [ValidateSet('Collapsed', 'Expanded')]
    [string] $InitialState = 'Collapsed',

    [ValidateSet('Unknown', 'Debug', 'Profile', 'Release')]
    [string] $RunMode = 'Unknown',

    [string] $EvidencePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

if (-not $EvidencePath) {
    $runtimeDirectory = [System.IO.Path]::GetFullPath(
        (Join-Path $PSScriptRoot '..\..\.runtime')
    )
    $EvidencePath = Join-Path $runtimeDirectory "windows-accessibility-$ProcessId.json"
}

$runtimeDirectory = Split-Path -Parent $EvidencePath
New-Item -ItemType Directory -Path $runtimeDirectory -Force | Out-Null

function Get-PropertyResult {
    param(
        [System.Windows.Automation.AutomationElement] $Element,
        [string] $PropertyName
    )

    try {
        $value = $Element.Current.$PropertyName
        if ($null -eq $value -or ($value -is [string] -and [string]::IsNullOrWhiteSpace($value))) {
            return [pscustomobject]@{ status = 'absent'; value = $null }
        }
        return [pscustomobject]@{ status = 'available'; value = $value }
    }
    catch {
        return [pscustomobject]@{ status = 'query_failed'; error = $_.Exception.Message }
    }
}

function Get-PatternResult {
    param(
        [System.Windows.Automation.AutomationElement] $Element,
        [string] $PatternName,
        [System.Windows.Automation.AutomationPattern[]] $SupportedPatterns
    )

    $patternId = switch ($PatternName) {
        'TextPattern' { [System.Windows.Automation.TextPattern]::Pattern }
        'ValuePattern' { [System.Windows.Automation.ValuePattern]::Pattern }
        'LegacyIAccessiblePattern' { $null }
        'InvokePattern' { [System.Windows.Automation.InvokePattern]::Pattern }
        'ExpandCollapsePattern' { [System.Windows.Automation.ExpandCollapsePattern]::Pattern }
        default { throw "Patrón no contemplado: $PatternName" }
    }

    if ($PatternName -eq 'LegacyIAccessiblePattern') {
        $patternId = $SupportedPatterns |
            Where-Object { $_.ProgrammaticName -match 'LegacyIAccessiblePattern' } |
            Select-Object -First 1
    }
    $patternAvailable = $patternId -and @(
        $SupportedPatterns | Where-Object {
            $_.ProgrammaticName -eq $patternId.ProgrammaticName
        }
    ).Count -gt 0
    if (-not $patternAvailable) {
        return [pscustomobject]@{ status = 'not_supported' }
    }

    try {
        $pattern = $Element.GetCurrentPattern($patternId)
        switch ($PatternName) {
            'TextPattern' {
                $text = $pattern.DocumentRange.GetText(10000)
                if ([string]::IsNullOrWhiteSpace($text)) {
                    return [pscustomobject]@{ status = 'absent'; value = $null }
                }
                return [pscustomobject]@{ status = 'available'; value = $text }
            }
            'ValuePattern' {
                return [pscustomobject]@{ status = 'available'; value = $pattern.Current.Value }
            }
            'LegacyIAccessiblePattern' {
                $legacy = $pattern.Current
                return [pscustomobject]@{
                    status = 'available'
                    name = $legacy.Name
                    value = $legacy.Value
                    description = $legacy.Description
                    help = $legacy.Help
                    keyboardShortcut = $legacy.KeyboardShortcut
                    role = $legacy.Role
                    state = $legacy.State
                    defaultAction = $legacy.DefaultAction
                }
            }
            'InvokePattern' {
                return [pscustomobject]@{ status = 'available'; action = 'Invoke' }
            }
            'ExpandCollapsePattern' {
                return [pscustomobject]@{ status = 'available'; state = $pattern.Current.ExpandCollapseState.ToString() }
            }
        }
    }
    catch {
        return [pscustomobject]@{ status = 'query_failed'; error = $_.Exception.Message }
    }
}

function Get-WindowSnapshot {
    param([System.Windows.Automation.AutomationElement] $Window)

    $allElements = @($Window) + @(
        $Window.FindAll(
            [System.Windows.Automation.TreeScope]::Descendants,
            [System.Windows.Automation.Condition]::TrueCondition
        )
    )
    $records = [System.Collections.Generic.List[object]]::new()
    $elementRecords = [System.Collections.Generic.List[object]]::new()
    $index = 0

    foreach ($element in $allElements) {
        try {
            $controlType = $element.Current.ControlType.ProgrammaticName
        }
        catch {
            $controlType = "query_failed: $($_.Exception.Message)"
        }

        try {
            $patterns = @($element.GetSupportedPatterns())
            $patternNames = @($patterns | ForEach-Object ProgrammaticName)
        }
        catch {
            $patterns = @()
            $patternNames = @("query_failed: $($_.Exception.Message)")
        }

        $records.Add([pscustomobject]@{
            index = $index
            controlType = $controlType
            name = Get-PropertyResult $element 'Name'
            helpText = Get-PropertyResult $element 'HelpText'
            isKeyboardFocusable = Get-PropertyResult $element 'IsKeyboardFocusable'
            hasKeyboardFocus = Get-PropertyResult $element 'HasKeyboardFocus'
            patterns = $patternNames
            textPattern = Get-PatternResult $element 'TextPattern' $patterns
            valuePattern = Get-PatternResult $element 'ValuePattern' $patterns
            legacyIAccessiblePattern = Get-PatternResult $element 'LegacyIAccessiblePattern' $patterns
            invokePattern = Get-PatternResult $element 'InvokePattern' $patterns
            expandCollapsePattern = Get-PatternResult $element 'ExpandCollapsePattern' $patterns
        })
        $elementRecords.Add([pscustomobject]@{ element = $element; index = $index })
        $index++
    }

    return [pscustomobject]@{ nodes = $records.ToArray(); elements = $elementRecords.ToArray() }
}

$root = [System.Windows.Automation.AutomationElement]::RootElement
$processCondition = [System.Windows.Automation.PropertyCondition]::new(
    [System.Windows.Automation.AutomationElement]::ProcessIdProperty,
    $ProcessId
)
$windows = @($root.FindAll([System.Windows.Automation.TreeScope]::Children, $processCondition))
$window = $windows | Where-Object { $_.Current.Name -eq $WindowName } | Select-Object -First 1
if (-not $window -and $windows.Count -eq 1) {
    $window = $windows[0]
}
if (-not $window) {
    throw "No se encontró una ventana '$WindowName' para el PID $ProcessId. Ventanas coincidentes por PID: $($windows.Count)."
}

$initial = Get-WindowSnapshot $window
$sectionRecord = $initial.elements | Where-Object {
    $_.element.Current.Name -eq $SectionName
} | Select-Object -First 1
if (-not $sectionRecord) {
    $privacyButton = $initial.elements | Where-Object {
        $_.element.Current.Name -eq 'Privacidad y uso'
    } | Select-Object -First 1
    if ($privacyButton) {
        $privacyPatterns = @($privacyButton.element.GetSupportedPatterns())
        $privacyInvoke = Get-PatternResult $privacyButton.element 'InvokePattern' $privacyPatterns
        if ($privacyInvoke.status -eq 'available') {
            $privacyButton.element.GetCurrentPattern(
                [System.Windows.Automation.InvokePattern]::Pattern
            ).Invoke()
            Start-Sleep -Milliseconds 400
            $initial = Get-WindowSnapshot $window
            $sectionRecord = $initial.elements | Where-Object {
                $_.element.Current.Name -eq $SectionName
            } | Select-Object -First 1
        }
    }
}
if (-not $sectionRecord) {
    throw "No se encontró la sección '$SectionName' dentro de la ventana del PID $ProcessId."
}

$sectionPatterns = @($sectionRecord.element.GetSupportedPatterns())
$expandPattern = Get-PatternResult $sectionRecord.element 'ExpandCollapsePattern' $sectionPatterns
$invokePattern = Get-PatternResult $sectionRecord.element 'InvokePattern' $sectionPatterns

if ($expandPattern.status -eq 'available') {
    $actualInitialState = $expandPattern.state
    $expectedInitialState = if ($InitialState -eq 'Expanded') { 'Expanded' } else { 'Collapsed' }
    if ($actualInitialState -ne $expectedInitialState) {
        throw "El estado visible ($actualInitialState) no coincide con -InitialState $InitialState."
    }
}
elseif ($invokePattern.status -eq 'available') {
    $actualInitialState = "operator_declared_$InitialState"
}
else {
    $actualInitialState = 'not_observable'
}

if ($invokePattern.status -eq 'available') {
    try {
        $sectionRecord.element.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern).Invoke()
        Start-Sleep -Milliseconds 350
        $toggled = Get-WindowSnapshot $window
        $sectionRecord.element.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern).Invoke()
        Start-Sleep -Milliseconds 350
        $restored = Get-WindowSnapshot $window
        $toggleStatus = 'captured_and_restored'
    }
    catch {
        $toggled = $null
        $restored = $null
        $toggleStatus = "query_failed: $($_.Exception.Message)"
    }
}
else {
    $toggled = $null
    $restored = $null
    $toggleStatus = 'not_supported'
}

$evidence = [pscustomobject]@{
    schemaVersion = 1
    capturedAt = (Get-Date).ToString('o')
    processId = $ProcessId
    runMode = $RunMode
    windowName = $window.Current.Name
    sectionName = $SectionName
    requestedInitialState = $InitialState
    initialState = $actualInitialState
    toggledState = if ($InitialState -eq 'Collapsed') {
        if ($expandPattern.status -eq 'available') { 'read_from_ExpandCollapsePattern' }
        else { 'operator_declared_Expanded' }
    }
    else {
        if ($expandPattern.status -eq 'available') { 'read_from_ExpandCollapsePattern' }
        else { 'operator_declared_Collapsed' }
    }
    restoredState = if ($expandPattern.status -eq 'available') {
        'read_from_ExpandCollapsePattern'
    }
    else {
        "operator_declared_$InitialState"
    }
    toggleStatus = $toggleStatus
    initial = $initial.nodes
    toggled = if ($toggled) { $toggled.nodes } else { $null }
    restored = if ($restored) { $restored.nodes } else { $null }
    statusDefinitions = @{
        absent = 'La propiedad o valor existe en el modelo pero no se informó.'
        not_supported = 'El elemento no expone ese patrón UIA.'
        query_failed = 'El proveedor anunció el patrón o propiedad, pero la consulta falló.'
    }
}

$evidence | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $EvidencePath -Encoding utf8
Write-Output "UIA: PID=$ProcessId; ventana='$($window.Current.Name)'; estado inicial=$actualInitialState; transición=$toggleStatus"
Write-Output "Evidencia: $EvidencePath"
