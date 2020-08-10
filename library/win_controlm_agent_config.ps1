#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic
#Requires -Module Ansible.ModuleUtils.CamelConversion
#Requires -Module Ansible.ModuleUtils.Legacy

$spec = @{
    options = @{

        # CTMAGCFG.exe
        # details in https://docs.bmc.com/docs/ctm/files/644067496/644067642/1/1463474322253/CTM_Admin_9.0.00.200_480027.pdf
        # https://docs.bmc.com/docs/ctm/files/727402814/828957420/1/1538574713805/CTM_Admin_9.0.00.500_491283.pdf (page 205)
        agent_to_server_port             = @{ type = "int"; default = 7005 }
        server_to_agent_port             = @{ type = "int"; default = 7006 }
        primary_controlm_server_host     = @{ type = "str" } # do not use IP address
        authorized_controlm_server_hosts = @{ type = "str" } # do not use IP address
        diagnostic_level                 = @{ type = "int"; default = 0 }
        comm_trace              = @{ type = "bool"; default = $false } # (0-OFF|1-ON) : [0]
        days_to_retain_log_files  = @{ type = "int"; default = 1 }
        daily_log_file_enabled = @{ type = "bool"; default = $true } # (Y|N)
        tracker_event_port             = @{ type = "int"; default = 7035 }
        logical_agent_name = @{ type = "str"; default = "$env:COMPUTERNAME" }
        java_new_ar   = @{ type = "bool"; default = $false } #  N
        persistent_connection = @{ type = "bool"; default = $false } # (Y|N)
        allow_comm_init = @{ type = "str"; default = "Y"; choices=@('Y','N','A') }
        foreign_language_support = @{ type = "str"; default = "LATIN-1";choices=@('LATIN-1','CJK') }
        ssl = @{ type = "bool"; default = $false } # (Y|N)
        protocol_version = @{ type = "int"; default = 12 } # 12 = Synchronized with Control-m/Server
        autoedit_inline = @{ type = "bool"; default = $true } # (Y|N)
        listen_to_network_interface = @{ type = "str"; default = '*ANY' } # (Y|N)
        ctms_address_mode = @{ type = "str"; default = "" }  # (IP|)
        timeout_for_agent_utilities = @{ type = "int"; default = 600 }
        tcpip_timeout = @{ type = "int"; default = 60 }
        tracker_polling_interval = @{ type = "int"; default = 60 }
        limit_log_file_size_mb =  @{ type = "int"; default = 10; choices=@(1..1000) } #  Maximum size of log file MB. initializes the file size limit for log files. when the defined size is reached, the log file is closed and a new one is created.
        limit_log_version =  @{ type = "int"; default = 10; choices=@(1..99) } # Number of log file version. Sets the number of log files. When the number is reached, the older log file is deleted.
        measure_usage_day = @{ type = "int"; default = 7 } # Determines the number of days to retain the files in the dailylog directory.

        # CTMWINCFG.exe
        logon_as_user                    = @{ type = "bool"; default = $false }
        logon_domain                     = @{ type = "str" }
        job_children_inside_job_object   = @{ type = "bool"; default = $true }
        job_statistics_to_sysout         = @{ type = "bool"; default = $true }
        sysout_name                      = @{ type = "str"; default = "MEMNAME"; choices=@('MEMNAME','JOBNAME') }
        wrap_parameters_with_double_quotes =  @{ type = "int"; default = 4; choices=@(1,2,3,4) } #  1 – This parameter is no longer relevant.  2 – Parameter values are always passed to the operating system without quotes. If quotes were specified in the job definition, they are removed before the parameter is passed onward by the agent. This option is compatible with the way that these parameters were managed in version 6.0.0x, or 6.1.01 with Fix Pack 1, 2, 3, or 4 installed. In this case, if a parameter value contains a blank, the operating system may consider each string as a separate parameter.  3 – This parameter is no longer relevant.  4 – Parameters are passed to the operating system in exactly the same way that they were specified in the job definition. No quotes are added or removed in this case. This option is compatible with the way that parameters were managed by version 2.24.0x .
        run_user_logon_script= @{ type = "bool"; default = $false }
        cjk_encoding = @{ type = "str"; default = ""; choices = @('UTF-8', 'JAPANESE EUC', 'JAPANESE SHIFT-JIS', 'KOREAN EUC', 'SIMPLIFIED CHINESE GBK', 'SIMPLIFIED CHINESE GB', 'TRADITIONAL CHINESE EUC', 'TRADITIONAL CHINESE BIG' } # (CJK Encoding) Determines the CJK encoding used by Control-M/Agent to run jobs.
        default_printer = @{ type = "str" }
        echo_job_commands_into_sysout  = @{ type = "bool"; default = $true }
        smtp_server_relay_name = @{ type = "bool" }
        smtp_port = @{ type = "int"; default = 25 }
        smtp_sender_mail = @{ type = "str"; default = "control@m" }
        smtp_sender_friendly_name = @{ type = "str" }
        smtp_replay_to_mail = @{ type = "str" }
    }
    supports_check_mode = $true
}

# All entries to REG_SZ type
$configuration = @{
    agent_to_server_port = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\ATCMNDATA'
    server_to_agent_port= 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\AGCMNDATA'
    primary_controlm_server_host = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\CTMSHOST'
    authorized_controlm_server_hosts = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\CTMPERMHOSTS'
    diagnostic_level = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\DBGLVL'
    comm_trace   = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\COMM_TRACE'
    days_to_retain_log_files =  'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\LOGKEEPDAYS'
    daily_log_file_enabled  = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\AG_LOG_ON'
    tracker_event_port = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\TRACKER_EVENT_PORT'
    logical_agent_name = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\LOGICAL_AGENT_NAME'
    java_new_ar = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\JAVA_AR'
    persistent_connection = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\PERSISTENT_CONNECTION'
    allow_comm_init = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\ALLOW_COMM_INIT'
    foreign_language_support = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\I18N'
    ssl = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\COMMOPT'  # SSL=N
    protocol_version = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\PROTOCOL_VERSION'
    autoedit_inline  = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\USE_JOB_VARIABLES'
    listen_to_network_interface = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\LISTEN_INTERFACE'
    ctms_address_mode = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\CTMS_ADDR_MODE'
    timeout_for_agent_utilities = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\UTTIMEOUT'
    tcpip_timeout = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\TCP_IP_TIMEOUT'
    tracker_polling_interval = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\EVENT_TIMEOUT'
    limit_log_file_size = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG\LIMIT_LOG_FILE_SIZE'
    limit_log_version = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG\LIMIT_LOG_VERSIONS'
    measure_usage_day = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\CONFIG\MEASURE_USAGE_DAYS'

    logon_as_user = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\LOGON_AS_USER'
    logon_domain = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\DOMAIN'
    job_children_inside_job_object = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\JOB_WAIT'
    job_statistics_to_sysout = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\JOB_STATISTIC'
    sysout_name = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\OUTPUT_NAME'
    wrap_parameters_with_double_quotes  = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\WRAP_PARAM_QUOTES'
    run_user_logon_script = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\RUN_USER_LOGON_SCRIPT'
    cjk_encoding = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\APPLICATION_LOCALE'
    default_printer = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\DFTPRT'
    echo_job_commands_into_sysout = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\ECHO_OUTPUT'
    smtp_server_relay_name = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\SMTP_SERVER_NAME'
    smtp_port = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\SMTP_PORT_NUMBER'
    smtp_sender_mail = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\SMTP_SENDER_EMAIL'
    smtp_sender_friendly_name  = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\SMTP_SENDER_FRIENDLY_NAME'
    smtp_replay_to_mail = 'HKEY_LOCAL_MACHINE\SOFTWARE\BMC Software\Control-M/Agent\WIN\SMTP_REPLY_TO_EMAIL'
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$agent_to_server_port  = $module.Params.agent_to_server_port
