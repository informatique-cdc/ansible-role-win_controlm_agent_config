#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic
function Get-ModuleParameter {
    <#
.SYNOPSIS
Removes defined parameter values from a passed $PSBoundParameters object

.DESCRIPTION
When passed a $PSBoundParameters hashtable, this function removes standard parameters
(like Verbose/Confirm etc) and returns the passed object with only the non-standard
parameters left in place.

.PARAMETER Parameters
This is the input object from which to remove the default set of parameters.
It is intended to accept the $PSBoundParameters object from another function.

.PARAMETER ParametersToRemove
Accepts an array of any additional parameter keys which should be removed from the passed input
object. Specifying additional parameter names/keys here means that the default value assigned
to the BaseParameters parameter will remain unchanged.

.EXAMPLE
$PSBoundParameters | Get-ModuleParameter

.EXAMPLE
Get-ModuleParameter -Parameters $PSBoundParameters -ParametersToRemove param1,param2

.INPUTS
$PSBoundParameters object

.OUTPUTS
Hashtable/$PSBoundParameters object, with defined parameters removed.
#>
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'FilteredParameters', Justification = "False Positive")]
    [CmdletBinding()]
    [OutputType('System.Collections.Hashtable')]
    param(
        [parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [Hashtable]$Parameters,

        [parameter(
            Mandatory = $false)]
        [array]$ParametersToRemove = @()

    )

    BEGIN {

        $BaseParameters = [Collections.Generic.List[String]]@(
            [System.Management.Automation.PSCmdlet]::CommonParameters +
            [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
        )

    }#begin

    PROCESS {

        $Parameters.Keys | ForEach-Object {

            $FilteredParameters = @{ }

        } {

            if (($BaseParameters + $ParametersToRemove) -notcontains $PSItem) {

                $FilteredParameters.Add($PSItem, $Parameters[$PSItem])

            }

        } { $FilteredParameters }

    }#process

    END { }#end

}
Function Convert-StringToPascalCase {
    <#
    .SYNOPSIS
    This function convert a string in snake_case format to PascalCase
    .PARAMETER String
    Specifies the string in snake_case format.
#>
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $string
    )

    $string = (Get-Culture).TextInfo.ToTitleCase(($string.ToLower() -replace "_", " ")) -replace " ", ""
    return $string
}

Function Convert-StringToSnakeCase {
    <#
    .SYNOPSIS
    This function convert a string in convert a string in camelCase format to snake_case
    .PARAMETER String
    Specifies the string in snake_case format.
#>
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $string
    )
    # cope with pluralized abbreaviations such as TargetGroupARNs
    if ($string -cmatch "[A-Z]{3,}s") {
        $replacement_string = $string -creplace $matches[0], "_$($matches[0].ToLower())"

        # handle when there was nothing before the plural pattern
        if ($replacement_string.StartsWith("_") -and -not $string.StartsWith("_")) {
            $replacement_string = $replacement_string.Substring(1)
        }
        $string = $replacement_string
    }
    $string = $string -creplace "(.)([A-Z][a-z]+)", '$1_$2'
    $string = $string -creplace "([a-z0-9])([A-Z])", '$1_$2'
    $string = $string.ToLower()

    return $string
}

function ConvertTo-Boolean {
    <#
    .SYNOPSIS
    This function Convert common values to Powershell boolean values $true and $false.
    .PARAMETER value
    Specifies the string to convert.
#>
    param
    (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]
        $value
    )
    switch ($value) {
        "y" { return $true; }
        "yes" { return $true; }
        "true" { return $true; }
        "t" { return $true; }
        1 { return $true; }
        "n" { return $false; }
        "no" { return $false; }
        "false" { return $false; }
        "f" { return $false; }
        0 { return $false; }
    }
}


$spec = @{
    options             = @{
        agent_to_server_port               = @{ type = "int"; choices = @(1024..65535) }
        server_to_agent_port               = @{ type = "int"; choices = @(1024..65535) }
        primary_controlm_server_host       = @{ type = "str" } # do not use IP address
        authorized_controlm_server_hosts   = @{ type = "str" } # do not use IP address
        diagnostic_level                   = @{ type = "int"; choices = @(1..4) }
        communication_trace                = @{ type = "bool" } # (0-OFF|1-ON) : [0]
        days_to_retain_log_files           = @{ type = "int"; choices = @(1..99) }
        daily_log_file_enabled             = @{ type = "bool" }
        tracker_event_port                 = @{ type = "int"; choices = @(1025..65535) }
        logical_agent_name                 = @{ type = "str" }
        java_new_ar                        = @{ type = "bool" }
        persistent_connection              = @{ type = "bool" }
        allow_comm_init                    = @{ type = "bool" }
        foreign_language_support           = @{ type = "str"; choices = @('LATIN-1', 'CJK') }
        ssl                                = @{ type = "bool" }
        protocol_version                   = @{ type = "int" }
        autoedit_inline                    = @{ type = "bool" }
        listen_to_network_interface        = @{ type = "str" }
        ctms_address_mode                  = @{ type = "str"; choices = @('', 'IP') }
        timeout_for_agent_utilities        = @{ type = "int" }
        tcpip_timeout                      = @{ type = "int"; choices = @(0..999999) }
        tracker_polling_interval           = @{ type = "int"; choices = @(1..86400) }
        limit_log_file_size                = @{ type = "int"; choices = @(1..1000) }
        limit_log_version                  = @{ type = "int"; choices = @(1..99) }
        measure_usage_day                  = @{ type = "int" }
        logon_as_user                      = @{ type = "bool" }
        logon_domain                       = @{ type = "str" }
        job_children_inside_job_object     = @{ type = "bool" }
        job_statistics_to_sysout           = @{ type = "bool" }
        sysout_name                        = @{ type = "str"; choices = @('MEMNAME', 'JOBNAME') }
        wrap_parameters_with_double_quotes = @{ type = "int"; choices = @(1, 2, 3, 4) }
        run_user_logon_script              = @{ type = "bool" }
        cjk_encoding                       = @{ type = "str"; choices = @('', 'UTF-8', 'JAPANESE EUC', 'JAPANESE SHIFT-JIS', 'KOREAN EUC', 'SIMPLIFIED CHINESE GBK', 'SIMPLIFIED CHINESE GB', 'TRADITIONAL CHINESE EUC', 'TRADITIONAL CHINESE BIG') } # (CJK Encoding) Determines the CJK encoding used by Control-M/Agent to run jobs.
        default_printer                    = @{ type = "str" }
        echo_job_commands_into_sysout      = @{ type = "bool" }
        smtp_server_relay_name             = @{ type = "bool" }
        smtp_port                          = @{ type = "int"; choices = @(0..65535) }
        smtp_sender_mail                   = @{ type = "str" }
        smtp_sender_friendly_name          = @{ type = "str" }
        smtp_reply_to_mail                 = @{ type = "str" }
    }
    supports_check_mode = $true
}

# All entries to REG_SZ type
$configuration = @{
    agent_to_server_port               = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'ATCMNDATA' ; Default = '7005' }
    server_to_agent_port               = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'AGCMNDATA' ; Default = '7006' }
    primary_controlm_server_host       = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'CTMSHOST' ; Default = '' }
    authorized_controlm_server_hosts   = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'CTMPERMHOSTS' ; Default = '' }
    diagnostic_level                   = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'DBGLVL'; Default = '0' }
    communication_trace                = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'COMM_TRACE'; Default = '0' }
    days_to_retain_log_files           = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'LOGKEEPDAYS'; Default = '1' }
    daily_log_file_enabled             = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'AG_LOG_ON'; Default = 'Y' }
    tracker_event_port                 = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'TRACKER_EVENT_PORT'; Default = '7035' }
    logical_agent_name                 = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'LOGICAL_AGENT_NAME' ; Default = "$env:COMPUTERNAME" }
    java_new_ar                        = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'JAVA_AR' ; Default = 'N' }
    persistent_connection              = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'PERSISTENT_CONNECTION'; Default = 'N' }
    allow_comm_init                    = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'ALLOW_COMM_INIT'; Default = 'Y' }
    foreign_language_support           = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'I18N'; Default = 'LATIN-1' }
    ssl                                = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'COMMOPT'; Default = 'SSL=N' }
    protocol_version                   = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'PROTOCOL_VERSION'; Default = '12' }
    autoedit_inline                    = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'USE_JOB_VARIABLES'; Default = 'Y' }
    listen_to_network_interface        = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'LISTEN_INTERFACE'; Default = '*ANY' }
    ctms_address_mode                  = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'CTMS_ADDR_MODE'; Default = '' }
    timeout_for_agent_utilities        = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'UTTIMEOUT'; Default = '600' }
    tcpip_timeout                      = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'TCP_IP_TIMEOUT'; Default = '60' }
    tracker_polling_interval           = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'EVENT_TIMEOUT' ; Default = '60' }
    limit_log_file_size                = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'LIMIT_LOG_FILE_SIZE'; Default = '10' }
    limit_log_version                  = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'LIMIT_LOG_VERSIONS'; Default = '10' }
    measure_usage_day                  = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'MEASURE_USAGE_DAYS'; Default = '7' }
    logon_as_user                      = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'LOGON_AS_USER'; Default = 'N' }
    logon_domain                       = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'DOMAIN'; Default = '' }
    job_children_inside_job_object     = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'JOB_WAIT'; Default = 'Y' }
    add_job_statistics_to_sysout       = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'JOB_STATISTIC'; Default = 'Y' }
    sysout_name                        = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'OUTPUT_NAME'; Default = 'MEMNAME' }
    wrap_parameters_with_double_quotes = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'WRAP_PARAM_QUOTES'; Default = '4' }
    run_user_logon_script              = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'RUN_USER_LOGON_SCRIPT'; Default = 'N' }
    cjk_encoding                       = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'APPLICATION_LOCALE'; Default = '' }
    default_printer                    = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'DFTPRT'; Default = '' }
    echo_job_commands_into_sysout      = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'ECHO_OUTPUT'; Default = 'Y' }
    smtp_server_relay_name             = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'SMTP_SERVER_NAME'; Default = '' }
    smtp_port                          = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'SMTP_PORT_NUMBER'; Default = '25' }
    smtp_sender_mail                   = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'SMTP_SENDER_EMAIL'; Default = 'control@m' }
    smtp_sender_friendly_name          = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'SMTP_SENDER_FRIENDLY_NAME'; Default = '' }
    smtp_reply_to_mail                 = @{ Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'SMTP_REPLY_TO_EMAIL'; Default = '' }
}

Function Get-ControlMParameter {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]
        $Name
    )

    $optionName = Convert-StringToSnakeCase -String $Name
    if ( -not $configuration.ContainsKey($optionName) ) {
        Throw "The configuration hashtable does not contain the $optionName setting converted from the $Name parameter name"
    }

    $RegistryInfo = $configuration[$optionName]
    Get-ChildItem -Path Registry::$($RegistryInfo.Path) -Name $RegistryInfo.Name -ErrorAction SilentlyContinue -ErrorVariable RegistryError -OutVariable RegistryEntry
    $RegistryValue = if ($RegistryError) { $RegistryInfo.Default } else { $RegistryEntry.$($RegistryInfo.Name) }

    $ParameterList = (Get-Command -Name 'Test-TargetResource').Parameters;
    if ($Name -eq 'ssl') {
        $Value = ($RegistryValue -contains 'SSL=Y')
    }
    else {
        $ParameterType = $ParameterList[$Name].ParameterType.Name
        $Value = switch ($ParameterType) {
            "Int32" {
                [int]$int = $null
                $r = [int32]::TryParse($RegistryValue, [ref]$int); $int; break
            }
            "Boolean" {
                ConvertTo-Boolean -Value $RegistryValue; break
            }
            default {
                [string]$RegistryValue
            }
        }
    }
    return $Value
}

Function Set-ControlMParameter {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]
        $Name,
        $Value
    )
    $optionName = Convert-StringToSnakeCase -String $Name
    if ( -not $configuration.ContainsKey($optionName) ) {
        Throw "The configuration hashtable does not contain the $optionName setting converted from the $Name parameter name"
    }

    $RegistryInfo = $configuration[$optionName]

    if ($optionName -eq 'ssl') {
        Get-ChildItem -Path Registry::$($RegistryInfo.Path) -Name $RegistryInfo.Name -ErrorAction SilentlyContinue -ErrorVariable RegistryError -OutVariable RegistryEntry
        $RegistryValue = if ($RegistryError) { $RegistryInfo.Default } else { $RegistryEntry.$($RegistryInfo.Name) }
        $NewSetting = if ([bool]$Value) { 'SSL=Y' } else { 'SSL=N' }
        $NewValue = if ([string]::IsNullOrEmpty($Value)) { $NewSetting } else { $RegistryValue -replace "SSL=[N|Y]", $NewSetting }
    }
    elseif ($optionName -eq 'communication_trace') {
        $NewSetting = if ([bool]$Value) { '1' } else { '0' }
    }
    elseif ($value -is [bool]) {
        $NewSetting = if ([bool]$Value) { 'Y' } else { 'N' }
    }
    elseif ($value -is [int]) {
        $NewSetting = [string]$NewValue
    }
    else {
        $NewSetting = [string]$NewValue
    }

    if (-not $module.CheckMode) {
        Set-ItemProperty -Path Registry::$($RegistryInfo.Path) -Name $RegistryInfo.Name -Value $NewValue -ErrorAction SilentlyContinue -ErrorVariable RegistryError
    }
    return ($null -ne $RegistryError)
}

Function Get-TargetResource {
    [OutputType('System.Collections.Hashtable')]

    $TargetResource = @{ }

    $ParameterList = (Get-Command -Name 'Test-TargetResource').Parameters

    $BaseParameters = [Collections.Generic.List[String]]@(
        [System.Management.Automation.PSCmdlet]::CommonParameters +
        [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
    )

    foreach ($Parameter in $ParameterList) {

        $ParameterNames = $Parameter.Values.Name
        foreach ($ParameterName in $ParameterNames) {
            if ($BaseParameters -contains $ParameterName) {
                continue
            }
            $Value = Get-ControlMParameter -Name $ParameterName
            $targetResource[$ParameterName] = $Value
        }
    }
    return $targetResource
}

Function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [ValidateRange(1024, 65535)]
        [int]
        $AgentToServerPort,
        [ValidateRange(1024, 65535)]
        [int]
        $ServerToAgentPort,
        [string]
        $PrimaryControlmServerHost,
        [string]
        $AuthorizedControlmServerHosts,
        [ValidateRange(0, 4)]
        [int]
        $DiagnosticLevel,
        [bool]
        $CommunicationTrace,
        [ValidateRange(1, 99)]
        [int]
        $DaysToRetainLogFiles,
        [bool]
        $DailyLogFileEnabled = $true,
        [ValidateRange(1024, 65535)]
        [int]
        $TrackerEventPort,
        [string]
        $LogicalAgentName,
        [bool]
        $PersistentConnection,
        [bool]
        $AllowCommInit,
        [ValidateSet("LATIN-1", "CJK")]
        [string]
        $ForeignLanguageSupport,
        [bool]
        $SSL,
        [ValidateRange(1, 12)]
        [int]
        $ProtocolVersion,
        [bool]
        $AutoeditInline,
        [string]
        $ListenToNetworkInterface,
        [ValidateSet("", "IP")]
        [string]
        $CtmsAddressMode,
        [int]
        $TimeoutForAgentUtilities,
        [ValidateRange(0, 999999)]
        [int]
        $TcpipTimeout,
        [ValidateRange(1, 86400)]
        [int]
        $TrackerPollingInterval,
        [validateRange(1, 1000)]
        [int]
        $LimitLogFileSize,
        [validateRange(0, 99)]
        [int]
        $LimitLogVersion,
        [validateRange(1, 99)]
        [int]
        $MeasureUsageDay,
        [bool]
        $LogonAsUser,
        [string]
        $LogonDomain,
        [bool]
        $JobChildrenInsideJobObject,
        [bool]
        $AddJobStatisticsToSysout,
        [ValidateSet("MEMNAME", "JOBNAME")]
        [string]
        $SysoutName,
        [validateRange(1, 4)]
        [int]
        $WrapParametersWithDoubleQuotes,
        [bool]
        $RunUserLogonScript,
        [ValidateSet("", "UTF-8", "JAPANESE EUC", "JAPANESE SHIFT-JIS", "KOREAN EUC", "SIMPLIFIED CHINESE GBK", "SIMPLIFIED CHINESE GB", "TRADITIONAL CHINESE EUC", "TRADITIONAL CHINESE BIG5")]
        [string]
        $CjkEncoding,
        [string]
        $DefaultPrinter,
        [bool]
        $EchoJobCommandsIntoSysout,
        [string]
        $SmtpServerRelayName,
        [ValidateRange(0, 65535)]
        [int]
        $SmtpPort,
        [ValidateLength(0, 99)]
        [string]
        $SmtpSenderMail,
        [string]
        $SmtpSenderFriendlyName,
        [string]
        $SmtpReplyToMail
    )
    $isCompliant = $true;

    $resources = Get-TargetResource
    if (-not ($resources -is [hashtable])) {
        $resources = @($resources)
    }

    if ($resources.Length -eq 0) {
        return $false
    }
    $options = $PSBoundParameters | Get-ModuleParameter

    foreach ($option in $options.GetEnumerator()) {
        $optionName = $option.Key
        if ($resources.ContainsKey($optionName)) {
            if ($resources[$optionName] -ne $option.Value) {
                $isCompliant = $false
                break
            }
        }
    }
    return $isCompliant
}

function Set-TargetResource {
    param (
        [ValidateRange(1024, 65535)]
        [int]
        $AgentToServerPort,
        [ValidateRange(1024, 65535)]
        [int]
        $ServerToAgentPort,
        [string]
        $PrimaryControlmServerHost,
        [string]
        $AuthorizedControlmServerHosts,
        [ValidateRange(0, 4)]
        [int]
        $DiagnosticLevel,
        [bool]
        $CommunicationTrace,
        [ValidateRange(1, 99)]
        [int]
        $DaysToRetainLogFiles,
        [bool]
        $DailyLogFileEnabled = $true,
        [ValidateRange(1024, 65535)]
        [int]
        $TrackerEventPort,
        [string]
        $LogicalAgentName,
        [bool]
        $PersistentConnection,
        [bool]
        $AllowCommInit,
        [ValidateSet("LATIN-1", "CJK")]
        [string]
        $ForeignLanguageSupport,
        [bool]
        $SSL,
        [ValidateRange(1, 12)]
        [int]
        $ProtocolVersion,
        [bool]
        $AutoeditInline,
        [string]
        $ListenToNetworkInterface,
        [ValidateSet("", "IP")]
        [string]
        $CtmsAddressMode,
        [int]
        $TimeoutForAgentUtilities,
        [ValidateRange(0, 999999)]
        [int]
        $TcpipTimeout,
        [ValidateRange(1, 86400)]
        [int]
        $TrackerPollingInterval,
        [validateRange(1, 1000)]
        [int]
        $LimitLogFileSize,
        [validateRange(0, 99)]
        [int]
        $LimitLogVersion,
        [validateRange(1, 99)]
        [int]
        $MeasureUsageDay,
        [bool]
        $LogonAsUser,
        [string]
        $LogonDomain,
        [bool]
        $JobChildrenInsideJobObject,
        [bool]
        $AddJobStatisticsToSysout,
        [ValidateSet("MEMNAME", "JOBNAME")]
        [string]
        $SysoutName,
        [validateRange(1, 4)]
        [int]
        $WrapParametersWithDoubleQuotes,
        [bool]
        $RunUserLogonScript,
        [ValidateSet("", "UTF-8", "JAPANESE EUC", "JAPANESE SHIFT-JIS", "KOREAN EUC", "SIMPLIFIED CHINESE GBK", "SIMPLIFIED CHINESE GB", "TRADITIONAL CHINESE EUC", "TRADITIONAL CHINESE BIG5")]
        [string]
        $CjkEncoding,
        [string]
        $DefaultPrinter,
        [bool]
        $EchoJobCommandsIntoSysout,
        [string]
        $SmtpServerRelayName,
        [ValidateRange(0, 65535)]
        [int]
        $SmtpPort,
        [ValidateLength(0, 99)]
        [string]
        $SmtpSenderMail,
        [string]
        $SmtpSenderFriendlyName,
        [string]
        $SmtpReplyToMail
    )

    $changed = $false

    $options = $PSBoundParameters | Get-ModuleParameter

    $isCompliant = Test-TargetResource @options
    if ($isCompliant) {
        return $changed
    }
    $resources = Get-TargetResource

    if (-not ($resources -is [hashtable])) {
        $resources = @($resources)
    }

    foreach ($option in $options.GetEnumerator()) {
        $ParameterName = $option.Key

        if ($resources.ContainsKey($ParameterName)) {

            if ($resources[$ParameterName] -ne $option.Value) {

                $optionName = Convert-StringToSnakeCase -String $ParameterName

                if (Set-ControlMParameter -Name $ParameterName -Value $option.Value) {
                    $module.Diff.before.$optionName = $resources[$ParameterName]
                    $module.Diff.after.$optionName = $option.Value
                    $module.Result.changed = $true
                }
                if ($ParameterName -eq 'PrimaryControlmServerHost') {
                    if (-not $resources['AuthorizedControlmServerHosts'] -and -not $options['AuthorizedControlmServerHosts']) {
                        if (Set-ControlMParameter -Name 'AuthorizedControlmServerHosts' -Value $option.Value) {
                            $module.Diff.before.primary_controlm_server_host = ''
                            $module.Diff.after.primary_controlm_server_host = $option.Value
                            $module.Result.changed = $true
                        }
                    }
                }
            }
        }
    }
}

$BaseParameters = [Collections.Generic.List[String]]@(
    [System.Management.Automation.PSCmdlet]::CommonParameters +
    [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
)

$ParameterList = (Get-Command -Name 'Test-TargetResource').Parameters;

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)
$module.Diff.before = @{ }
$module.Diff.after = @{ }

$params = @{ }

foreach ($Parameter in $ParameterList) {

    $ParameterNames = $Parameter.Values.Name
    foreach ($ParameterName in $ParameterNames) {
        if ($BaseParameters -contains $ParameterName) {
            continue
        }
        $optionName = Convert-StringToSnakeCase -String $ParameterName
        if ($module.Params.$optionName) {
            $params.$ParameterName = $module.Params.$optionName
        }
    }
}

Set-TargetResource @params

$module.ExitJson()

