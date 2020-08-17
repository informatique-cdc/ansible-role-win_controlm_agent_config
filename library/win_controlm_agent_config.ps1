#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic

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
        server_agent_protocol_version      = @{ type = "int" }
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
        job_output_name                    = @{ type = "str"; choices = @('MEMNAME', 'JOBNAME') }
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
    agent_to_server_port               = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'ATCMNDATA' ; Default = '7005' }
    server_to_agent_port               = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'AGCMNDATA' ; Default = '7006' }
    primary_controlm_server_host       = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'CTMSHOST' ; Default = '' }
    authorized_controlm_server_hosts   = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'CTMPERMHOSTS' ; Default = '' }
    diagnostic_level                   = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'DBGLVL'; Default = '0' }
    communication_trace                = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'COMM_TRACE'; Default = '0' }
    days_to_retain_log_files           = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'LOGKEEPDAYS'; Default = '1' }
    daily_log_file_enabled             = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'AG_LOG_ON'; Default = 'Y' }
    tracker_event_port                 = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'TRACKER_EVENT_PORT'; Default = '7035' }
    logical_agent_name                 = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'LOGICAL_AGENT_NAME' ; Default = "$env:COMPUTERNAME" }
    java_new_ar                        = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'JAVA_AR' ; Default = 'N' }
    persistent_connection              = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'PERSISTENT_CONNECTION'; Default = 'N' }
    allow_comm_init                    = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'ALLOW_COMM_INIT'; Default = 'Y' }
    foreign_language_support           = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'I18N'; Default = 'LATIN-1' }
    ssl                                = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'COMMOPT'; Default = 'SSL=N' }
    server_agent_protocol_version      = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'PROTOCOL_VERSION'; Default = '12' }
    autoedit_inline                    = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'USE_JOB_VARIABLES'; Default = 'Y' }
    listen_to_network_interface        = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'LISTEN_INTERFACE'; Default = '*ANY' }
    ctms_address_mode                  = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'CTMS_ADDR_MODE'; Default = '' }
    timeout_for_agent_utilities        = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'UTTIMEOUT'; Default = '600' }
    tcpip_timeout                      = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'TCP_IP_TIMEOUT'; Default = '60' }
    tracker_polling_interval           = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'EVENT_TIMEOUT' ; Default = '60' }
    limit_log_file_size                = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'LIMIT_LOG_FILE_SIZE'; Default = '10' }
    limit_log_version                  = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'LIMIT_LOG_VERSIONS'; Default = '10' }
    measure_usage_day                  = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'MEASURE_USAGE_DAYS'; Default = '7' }
    logon_as_user                      = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'LOGON_AS_USER'; Default = 'N' }
    logon_domain                       = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'DOMAIN'; Default = '' }
    job_children_inside_job_object     = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'JOB_WAIT'; Default = 'Y' }
    add_job_statistics_to_sysout       = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'JOB_STATISTIC'; Default = 'Y' }
    job_output_name                    = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'OUTPUT_NAME'; Default = 'MEMNAME' }
    wrap_parameters_with_double_quotes = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'WRAP_PARAM_QUOTES'; Default = '4' }
    run_user_logon_script              = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'RUN_USER_LOGON_SCRIPT'; Default = 'N' }
    cjk_encoding                       = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'APPLICATION_LOCALE'; Default = '' }
    default_printer                    = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'DFTPRT'; Default = '' }
    echo_job_commands_into_sysout      = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'ECHO_OUTPUT'; Default = 'Y' }
    smtp_server_relay_name             = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'SMTP_SERVER_NAME'; Default = '' }
    smtp_port                          = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'SMTP_PORT_NUMBER'; Default = '25' }
    smtp_sender_mail                   = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'SMTP_SENDER_EMAIL'; Default = 'control@m' }
    smtp_sender_friendly_name          = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'SMTP_SENDER_FRIENDLY_NAME'; Default = '' }
    smtp_reply_to_mail                 = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'SMTP_REPLY_TO_EMAIL'; Default = '' }
    default_agent_name                 = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent' ; Name = 'DEFAULT_AGENT'; Default = '' }
    cm_type                            = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\WIN' ; Name = 'APPLICATION_VERSION'; Default = '' }
    cm_name                            = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'CM_APPL_TYPE'; Default = '' }
    agent_version                      = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'CODE_VERSION'; Default = '' }
    fd_number                          = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'FD_NUMBER'; Default = '' }
    fix_number                         = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'FIX_NUMBER'; Default = '' }
    agent_directory                    = @{ Path = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent\CONFIG' ; Name = 'AGENT_DIR'; Default = '' }
}

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

    }

    PROCESS {

        $Parameters.Keys | ForEach-Object {

            $FilteredParameters = @{ }

        } {

            if (($BaseParameters + $ParametersToRemove) -notcontains $PSItem) {

                $FilteredParameters.Add($PSItem, $Parameters[$PSItem])

            }

        } { $FilteredParameters }

    }

    END { }

}
Function Convert-StringToSnakeCase {
    <#
    .SYNOPSIS
    This function convert a string in convert a string in camelCase format to snake_case
    .PARAMETER String
    Specifies the string in snake_case format.
    #>
    [OutputType([System.String])]
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

Function ConvertFrom-ControlMParameter {

    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Name,
        [string]
        $Value
    )
    $ConvertedValue = $null

    if ($Name -eq 'SSL') {
        $ConvertedValue = ($Value -contains 'SSL=Y')
    }
    elseif ($Name -eq 'CommunicationTrace') {
        $ConvertedValue = ConvertTo-Boolean -Value $Value;
    }
    elseif (-not $script:ParameterList[$Name]) {
        $ConvertedValue = [string]$Value
    }
    else {
        $ParameterType = $script:ParameterList[$Name].ParameterType.Name
        $ConvertedValue = switch ($ParameterType) {
            "Int32" {
                [int]$int = $null
                [int32]::TryParse($Value, [ref]$int) | Out-Null; $int; break
            }
            "Boolean" {
                ConvertTo-Boolean -Value $Value; break
            }
            default {
                [string]$Value
            }
        }
    }
    return $ConvertedValue
}

Function ConvertTo-ControlMParameter {

    [OutputType('System.String')]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Name,
        [Parameter(Mandatory = $true)]
        $Value
    )

    $NewValue = $null

    if ($Name -eq 'SSL') {
        $NewSetting = if ([bool]$Value) { 'SSL=Y' } else { 'SSL=N' }
        $ControlMValue = Get-ControlMParameter -Name 'SSL'
        $NewValue = if ([string]::IsNullOrEmpty($Value)) { $NewSetting } else { $ControlMValue -replace "SSL=[N|Y]", $NewSetting }
    }
    elseif ($Name -eq 'CommunicationTrace') {
        $NewValue = if ([bool]$Value) { '1' } else { '0' }
    }
    elseif ($value -is [bool]) {
        $NewValue = if ([bool]$Value) { 'Y' } else { 'N' }
    }
    elseif ($value -is [int]) {
        $NewValue = [string]$Value
    }
    else {
        $NewValue = [string]$Value
    }
    return $NewValue
}

Function Get-ControlMParameter {

    [OutputType('System.String')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]
        $Name
    )

    $optionName = Convert-StringToSnakeCase -String $Name
    if ( -not $configuration.ContainsKey($optionName) ) {
        $module.FailJson("The configuration hashtable does not contain the `"$optionName`" setting converted from the `"$Name`" parameter name")
    }

    $RegistryInfo = $configuration[$optionName]
    Get-ItemProperty -Path $RegistryInfo.Path -Name $RegistryInfo.Name -ErrorAction SilentlyContinue -ErrorVariable RegistryError -OutVariable RegistryEntry | Out-Null
    if ($RegistryError) { $RegistryValue = $RegistryInfo.Default } else { $RegistryValue = $($RegistryEntry.$($RegistryInfo.Name)) }

    return $RegistryValue
}

Function Set-ControlMParameter {

    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]
        $Name,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]
        $Value
    )

    $optionName = Convert-StringToSnakeCase -String $Name
    if ( -not $configuration.ContainsKey($optionName) ) {
        $module.FailJson("The configuration hashtable does not contain the `"$optionName`" setting converted from the `"$Name`" parameter name")
    }
    $Changed = $false

    $CurrentValue = Get-ControlMParameter -Name $Name
    if ($CurrentValue -ne $Value) {
        $Changed = $true
        if (-not $module.CheckMode) {
            $RegistryInfo = $configuration[$optionName]
            Set-ItemProperty -Path $RegistryInfo.Path -Name $RegistryInfo.Name -Value $Value -ErrorAction SilentlyContinue -ErrorVariable RegistryError
            if ($RegistryError) {
                $module.FailJson("An error occurs when saving the `"$optionName`" setting in the registry: $RegistryError")
            }
        }
    }
    return $Changed
}

Function Get-TargetResource {
    <#
    .SYNOPSIS
    Retrieves all settings of the configuration.
    .PARAMETER Parameters
    This is the input object from the name of parameters to retrieve.
    .PARAMETER ParametersAdd
    Accepts an array of any additional parameter keys which should be add
    object.
    #>
    [OutputType('System.Collections.Hashtable')]
    param (
        [parameter(Position = 0, ValueFromPipeline = $true)]
        [array]$Parameters = @($script:ParameterList.Keys),
        [array]
        $ParametersToAdd = @()
    )

    $TargetResource = @{ }

    $Parameters + $ParametersToAdd | ForEach-Object {
        $ControlMValue = Get-ControlMParameter -Name $_
        $Value = ConvertFrom-ControlMParameter -Name $_ -Value $ControlMValue
        $targetResource[$_] = $Value
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
        $ServerAgentProtocolVersion,
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
        $JobOutputName,
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

    if ($resources.Length -eq 0) {
        return $false
    }
    $Parameters = $PSBoundParameters | Get-ModuleParameter

    $difference = $Parameters.Keys | ForEach-Object { if ($resources.ContainsKey($_)) { if ($resources[$_] -ne $Parameters[$_] ) { $_ } } }
    $isCompliant = ($null -eq $difference)

    return $isCompliant
}

function Set-TargetResource {

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
        $ServerAgentProtocolVersion,
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
        $JobOutputName,
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

    $module.Result.changed = $false
    $Parameters = $PSBoundParameters | Get-ModuleParameter
    $resources = Get-TargetResource

    $Parameters.Keys | ForEach-Object { if ($resources.ContainsKey($_)) {
            if ($resources[$_] -ne $Parameters[$_] ) {

                $ControlMValue = ConvertTo-ControlMParameter -Name $_ -Value $Parameters[$_]

                if (Set-ControlMParameter -Name $_ -Value $ControlMValue) {
                    $optionName = Convert-StringToSnakeCase -String $_
                    $module.Diff.before.$optionName = $resources[$_]
                    $module.Diff.after.$optionName = $Parameters[$_]
                    $module.Result.changed = $true
                }
                if ($_ -eq 'PrimaryControlmServerHost') {
                    if (-not $resources['AuthorizedControlmServerHosts'] -and -not $Parameters['AuthorizedControlmServerHosts']) {
                        if (Set-ControlMParameter -Name 'AuthorizedControlmServerHosts' -Value $ControlMValue) {
                            $module.Diff.before.primary_controlm_server_host = ''
                            $module.Diff.after.primary_controlm_server_host = $Parameters[$_]
                            $module.Result.changed = $true
                        }
                    }
                }
            }
        }
    }

    if (-not $module.CheckMode) {
        @('AgentToServerPort') | ForEach-Object {
            $Name = $_
            if ($Parameters[$Name]) {
                $PortFilter = Get-NetFirewallPortFilter | Where-Object { $_.RemotePort -Eq $resources[$Name] }
                $PortFilter | Set-NetFirewallPortFilter -RemotePort $Parameters[$Name] -ErrorAction SilentlyContinue -ErrorVariable ProcessError
                if ($ProcessError) {
                    $module.FailJson("An error occurs when changing the firewall rule with the $($resources[$Name]) remote port to $($Parameters[$Name]) : $ProcessError")
                }
            }
        }
        @('ServerToAgentPort', 'TrackerEventPort') | ForEach-Object {
            $Name = $_
            if ($Parameters[$Name]) {
                $PortFilter = Get-NetFirewallPortFilter | Where-Object { $_.LocalPort -Eq $resources[$Name] }
                $PortFilter | Set-NetFirewallPortFilter -LocalPort $Parameters[$Name] -ErrorAction SilentlyContinue -ErrorVariable ProcessError
                if ($ProcessError) {
                    $module.FailJson("An error occurs when changing the firewall rule with the $($resources[$Name]) local port to $($Parameters[$Name]) : $ProcessError")
                }
            }
        }
        if ($Parameters['TrackerEventPort']) {
            if ($Parameters['TrackerEventPort'] -ne $resources['TrackerEventPort']) {
                Restart-Service -Name ctmag -Force -ErrorAction SilentlyContinue -ErrorVariable ProcessError
                If ($ProcessError) {
                    $module.FailJson("The Control/M Agent Windows service could not be restarted. $ProcessError")
                }
            }
        }
    }
    return $module.Result.changed
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Get-Service -Name ctmag -ErrorAction SilentlyContinue -ErrorVariable ProcessError -OutVariable Service
If ($ProcessError) {
    $module.FailJson("The Control/M Agent Windows service is not installed. $ProcessError")
}

$module.Diff.before = @{ }
$module.Diff.after = @{ }

$BaseParameters = [Collections.Generic.List[String]]@(
    [System.Management.Automation.PSCmdlet]::CommonParameters +
    [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
)

$script:ParameterList = (Get-Command -Name 'Test-TargetResource').Parameters
@($script:ParameterList.Keys) | ForEach-Object {
    if ($_ -in $BaseParameters) {
        $script:ParameterList.Remove($_) | Out-Null
    }
}

$params = @{ }
$ParameterList.Keys | ForEach-Object {
    $optionName = Convert-StringToSnakeCase -String $_
    if ($module.Params.ContainsKey($optionName) -and -not ($null -eq $module.Params.$optionName)) {
        $params.$($_) = $module.Params.$optionName
    }
}

if (!(Test-TargetResource @params)) {
    Set-TargetResource @params | Out-Null
}

$resources = Get-TargetResource -ParametersToAdd @('default_agent_name', 'cm_type', 'cm_name', 'agent_version', 'fd_number', 'fix_number', 'agent_directory')
$module.result.Config = @{ }
$resources.Keys | Foreach-Object { $module.result.Config.Add($(Convert-StringToSnakeCase -String $_), $resources[$_]) }

$module.ExitJson()
