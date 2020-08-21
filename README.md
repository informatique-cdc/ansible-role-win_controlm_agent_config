
# win_controlm_agent_config - Manipulate the configuration of a Control-M Agent on a Windows host

## Synopsis

* This Ansible module allows to change the Control-M Agent configuration on Windows-based systems.
* Control-M Agent configurations use both `CTMWINCFG` or `CTMAGCFG` command for setting configuration.
* This module provides an implementation for working with Agent configuration in a deterministic way. Commands are not used. This module make change in registry locations.

## Parameters

| Parameter     | Choices/<font color="blue">Defaults</font> | Comments |
| ------------- | ---------|--------- |
| __agent_to_server_port__<br><font color="purple">integer</font></font> | __Default:__<br><font color="blue">7005</font> | Defines the port number in the Control-M Agent computer where data is received from the Control-M Server computer.<br>The value assigned to this parameter must correspond to the value assigned to the Server-to-Agent Port Number field in the configuration file on the corresponding Control-M Agent computer. |
| __server_to_agent_port__<br><font color="purple">integer</font></font> | __Default:__<br><font color="blue">7006</font> | Defines the port number between 1024 and 65535 that receives data from the Control-M Agent computer.<br>This value must match the Agent-to-Server Port Number in Control-M Server. The value is the _COMTIMOUT_ communication job-tracking timeout in seconds. |
| __primary_controlm_server_host__<br><font color="purple">string</font></font> |  | Defines the hostname of the computer where the current Control-M Server submits jobs to the Control-M Agent. |
| __authorized_controlm_server_hosts__<br><font color="purple">string</font></font> |  | Defines a list of backup servers which can replace the primary server if it fails. The Control-M Agent only accept requests from servers on this list.<br>You cannot submit jobs to the same Control-M Agent if there is more than one active Control-M Server.<br>Another Control-M Agent instance must be installed with unique ports to support this configuration or job status updates corrupt. |
| __diagnostic_level__<br><font color="purple">integer</font></font> | __Default:__<br><font color="blue">0</font> | Defines the debug level.<br>Range 0-4 where 0 indicates no diagnostic activity, and 4 indicates the highest level of diagnostic functionality. |
| __communication_trace__<br><font color="purple">boolean</font></font> | __Choices__: <ul><li><font color="blue">__no &#x2190;__</font></li><li>yes</li></ul> | Flag indicating whether communication packets that Control-M Agent sends to and receives from Control-M Server are written to a file.<br>If set to `yes`, separate files are created for each session (job, ping, and so forth).<br>This parameter can only be changed after completing the installation. |
| __days_to_retain_log_files__<br><font color="purple">integer</font></font> | __Default:__<br><font color="blue">1</font> | Number of days to retain agent proclog files. After this period, agent proclog files are deleted by the New Day procedure.<br>Range 1-99. |
| __daily_log_file_enabled__<br><font color="purple">boolean</font></font> | __Choices__: <ul><li>no</li><li><font color="blue">__yes &#x2190;__</font></li></ul> | Indicates if the ctmag_\<year>\<month>\<day>.log file is generated `Yes` or not `No`. |
| __tracker_event_port__<br><font color="purple">integer</font></font> | __Default:__<br><font color="blue">7035</font> | Number of the port for sending messages to the Tracker process when jobs end. |
| __logical_agent_name__<br><font color="purple">string</font></font> |  | Logical name of the agent.<br>The value specified should match the name the agent is defined by in Control-M Server. Where multiple agent names are defined in Control-M Server, and all use the same server-to-agent port, server messages are sent to that agent.<br>The logical name is used when the agent initiates the communication to Control-M Server with the output from agent utilities and in messages sent by the agent to the server.<br>The default value is the `Agent host name`. |
| __persistent_connection__<br><font color="purple">boolean</font></font> | __Choices__: <ul><li><font color="blue">__no &#x2190;__</font></li><li>yes</li></ul> | Indicates the persistent connection setting. Set the _persistent_connection_ parameter to connect to a specific agent with either a persistent or transient connection.<br>When _persistent_connection_ is set to `Yes`, the NS process creates a persistent connection with the agent and manages the session with this agent. If the connection is broken with an agent or NS is unable to connect with an agent, the agent is marked as Unavailable. When the connection with the agent is resumed, the NS recreates a persistent connection with the agent and marks the agent as Available. |
| __allow_comm_init__<br><font color="purple">boolean</font></font> | __Choices__: <ul><li>no</li><li><font color="blue">__yes &#x2190;__</font></li></ul> | Determines if the agent can open a connection to the server when working in persistent connection mode.<br>When _allow_comm_init_ is set to `Y`, the Control-M Agent to initiate the communication with the Control-M Server. |
| __foreign_language_support__<br><font color="purple">string</font></font> | __Choices__: <ul><li><font color="blue">__LATIN-1 &#x2190;__</font></li><li>CJK</li></ul> | Indicates whether the system is configured for CJK languages or Latin1 languages. |
| __ssl__<br><font color="purple">boolean</font></font> | __Choices__: <ul><li><font color="blue">__no &#x2190;__</font></li><li>yes</li></ul> | Determines whether SSL is used to encrypt the communication between Control-M Server and the Control-M Agent. |
| __server_agent_protocol_version__<br><font color="purple">integer</font></font> | __Default:__<br><font color="blue">12</font> | Server-Agent communication protocol version.<br>Valid values range to 12 or lower. |
| __autoedit_inline__<br><font color="purple">boolean</font></font> | __Choices__: <ul><li>no</li><li><font color="blue">__yes &#x2190;__</font></li></ul> | Flag that indicates whether all variables will be set as environment variables in the script. |
| __listen_to_network_interface__<br><font color="purple">string</font></font> | __Default:__<br><font color="blue">\*ANY</font> | The network interface the agent is listening on.<br>It can be set to a specific hostname or IP address so that the agent port is not opened in the other interfaces.<br>If this parameter is set to `*ANY`, the agent is listening on all available interfaces. |
| __ctms_address_mode__<br><font color="purple">string</font></font> | __Choices__: <ul><li></li><li>IP</li></ul> | If this parameter is set to `IP`, the IP address instead of the host name is saved in _ctms_hostmane_.<br>Use this parameter when Control-M runs on a computer with more than one network card. |
| __timeout_for_agent_utilities__<br><font color="purple">integer</font></font> | __Default:__<br><font color="blue">600</font> | Maximum time (in seconds) the agent waits after sending a request to Control-M Server.<br>This timeout interval should be longer than the TCP/IP Timeout. |
| __tcpip_timeout__<br><font color="purple">integer</font></font> | __Default:__<br><font color="blue">60</font> | The communication job-tracking timeout in seconds.<br>When the value of ‘TCP/IP timeout’ is changed, using the configuration utility or CCM, the timeout part of the _server_to_agent_port_ and _agent_to_server_port_ parameters are changed.<br>Range 0-999999. |
| __tracker_polling_interval__<br><font color="purple">integer</font></font> | __Default:__<br><font color="blue">60</font> | Job Tracking Timeout. Tracker event timeout in seconds.<br>Range 1-86400. |
| __limit_log_file_size__<br><font color="purple">integer</font></font> | __Default:__<br><font color="blue">10</font> | Maximum size (MB) of diagnostic log files for a process or a thread.<br>When the defined size is reached, the log file is closed and a new one is created.<br>Restart the agent for the parameter to take effect.<br>Range 1-1000. |
| __limit_log_version__<br><font color="purple">integer</font></font> | __Default:__<br><font color="blue">10</font> | Number of generations of diagnostic log information to keep for a process or a thread.<br>When the number is reached, the older log file is deleted.<br>Range 0-99. |
| __measure_usage_day__<br><font color="purple">integer</font></font> | __Default:__<br><font color="blue">7</font> | Determines the number of days to retain the files in the dailylog directory.<br>These files contain the information about jobs that is used to calculate the metrics for the usage measurement report. |
| __logon_as_user__<br><font color="purple">boolean</font></font> | __Choices__: <ul><li><font color="blue">__no &#x2190;__</font></li><li>yes</li></ul> | Flag that specifies which user account is used for the services to log on to.<br>If this parameter is set to `Yes`, jobs are submitted with the permissions and environment variables of the specified user.<br>If this parameter is set to `No`, jobs are submitted with the permissions and environment variables of the local system account. |
| __logon_domain__<br><font color="purple">string</font></font> | __Default:__<br><font color="blue">""</font> | The domain is determined by the value of this parameter if `logon_domain` is not specified in <domain>\<username> in the Run_As parameter of the job definition.<br>If the domain is not specified in the Run_As parameter or this parameter, the user profile is searched in the trusted domains.<br>BMC recommends that you do not specify a value for Logon Domain. |
| __job_children_inside_job_object__<br><font color="purple">boolean</font></font> | __Choices__: <ul><li>no</li><li><font color="blue">__yes &#x2190;__</font></li></ul> | Flag that specifies if procedures invoked by a job can be run outside the Job Object.<br>If so, this prevents a situation in which the original job remains in executing mode until the invoked procedure completes.<br>If this parameter is set to `Yes`, all procedures invoked by the job are run outside the job object.<br>If this parameter is set to `No`, all procedures invoked by the job are run inside the job object. |
| __add_job_statistics_to_sysout__<br><font color="purple">boolean</font></font> | __Choices__: <ul><li>no</li><li><font color="blue">__yes &#x2190;__</font></li></ul> | Flag that indicates how to manage job object processing statistics.<br>If this parameter is set to `Yes`, statistics are added to the end of the OUTPUT file.<br>If this parameter is set to `No`, statistics are not added to the OUTPUT file. |
| __job_output_name__<br><font color="purple">string</font></font> | __Choices__: <ul><li><font color="blue">__MEMNAME &#x2190;__</font></li><li>JOBNAME</li></ul> | Determines the prefix for the OUTPUT file name.<br>If this parameter is set to `MEMNAME`, the OUTPUT file prefix is the MEMNAME of the job.<br>If this parameter is set to `JOBNAME`, the OUTPUT file prefix is the JOBNAME of the job. |
| __wrap_parameters_with_double_quotes__<br><font color="purple">integer</font></font> | __Default:__<br><font color="blue">4</font> | Indication of how parameter values (%%PARMn....%%PARMx) are managed by Control-M Agent for Microsoft Windows.<br>If this parameter is set to `1`, this parameter is no longer relevant.<br>If this parameter is set to `2`, parameter values are always passed to the operating system without quotes. If quotes were specified in the job definition, they are removed before the parameter is passed onward by the agent. This option is compatible with the way that these parameters were managed in version 6.0.0x, or 6.1.01 with Fix Pack 1, 2, 3, or 4 installed. In this case, if a parameter value contains a blank, the operating system may consider each string as a separate parameter.<br>If this parameter is set to `3`, this parameter is no longer relevant.<br>If this parameter is set to `4`, parameters are passed to the operating system in exactly the same way that they were specified in the job definition. No quotes are added or removed in this case. This option is compatible with the way that parameters were managed by version 2.24.0x. |
| __run_user_logon_script__<br><font color="purple">boolean</font></font> | __Choices__: <ul><li><font color="blue">__no &#x2190;__</font></li><li>yes</li></ul> | Indicates wether a user-defined logon script should be run by the Control-M Agent before running the standard user logon script.<br>If this parameter is set to `Yes`, the user-defined logon script is run, if it exists.<br>If this parameter is set to `No`, the user-defined logon script is not run. |
| __cjk_encoding__<br><font color="purple">string</font></font> | __Choices__: <ul><li><font color="blue">__UTF-8 &#x2190;__</font></li><li>JAPANESE EUC</li><li>JAPANESE SHIFT-JIS</li><li>KOREAN EUC</li><li>SIMPLIFIED CHINESE GBK</li><li>SIMPLIFIED CHINESE GB</li><li>TRADITIONAL CHINESE EUC</li><li>TRADITIONAL CHINESE BIG5</li></ul> | Determines the CJK encoding used by Control-M Agent to run jobs. |
| __default_printer__<br><font color="purple">string</font></font> | __Default:__<br><font color="blue">""</font> | Default printer for job OUTPUT files. |
| __echo_job_commands_into_sysout__<br><font color="purple">boolean</font></font> | __Choices__: <ul><li>no</li><li><font color="blue">__yes &#x2190;__</font></li></ul> | Specifies whether to print commands in the OUTPUT of a job.<br>If this parameter is set to `Yes`, implements ECHO_ON, which prints commands in the job OUTPUT.<br>If this parameter is set to `No`, implements ECHO_OFF, which does not print commands in the job OUTPUT. |
| __smtp_server_relay_name__<br><font color="purple">string</font></font> |  | The name of the SMTP server. |
| __smtp_port__<br><font color="purple">integer</font></font> | __Default:__<br><font color="blue">25</font> | The port number on which the SMTP server communicates.<br>Range 0-65535. |
| __smtp_sender_mail__<br><font color="purple">string</font></font> | __Default:__<br><font color="blue">control@m</font> | The e-mail address of the sender.<br>Text up to 99 characters. |
| __smtp_sender_friendly_name__<br><font color="purple">string</font></font> |  | The name or alias that appears on the e-mail sent. |
| __smtp_reply_to_mail__<br><font color="purple">string</font></font> |  | The e-mail address to which to send replies.<br>If this field is left empty, the sender e-mail address is used. |

## Examples

```yaml
---
- name: test the win_controlm_agent_config module
  hosts: all
  gather_facts: false

  roles:
    - win_controlm_agent_config

  tasks:
    - name: Change port numbers
      win_controlm_agent_config:
        agent_to_server_port: 8000
        server_to_agent_port: 8001
        tracker_event_port: 8002

    - name: Change Control-M Server hosts
      win_controlm_agent_config:
        primary_controlm_server_host: "server1"
        authorized_controlm_server_hosts: "server1|server2|server3.cloud"

    - name: Change job children inside job object
      win_controlm_agent_config:
        job_children_inside_job_object: no

    - name: Change the job ouput name
      win_controlm_agent_config:
        job_output_name: JOBNAME

```

## Return Values

Common return values are documented [here](https://docs.ansible.com/ansible/latest/reference_appendices/common_return_values.html#common-return-values), the following are the fields unique to this module:

| Key    | Returned   | Description |
| ------ |------------| ------------|
|__config__<br><font color="purple">dictionary</font> | On success | The retrieved configuration. |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__agent_to_server_port__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">integer</font> | success | The port number in the Control-M Agent computer where data is received from the Control-M Server computer.<br><br>__Sample:__<br><font color=blue>7006</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__allow_comm_init__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">boolean</font> | success | Indicates whether the agent can open a connection to the server when working in persistent connection mode. |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__authorized_controlm_server_hosts__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">string</font> | success | A list of backup servers which can replace the primary server if it fails. |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__autoedit_inline__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">boolean</font> | success | Indicates whether all variables will be set as environment variables in the script. |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__cjk_encoding__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">string</font> | success | The CJK encoding used by Control-M Agent to run jobs.<br><br>__Sample:__<br><font color=blue>UTF-8</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__communication_trace__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">boolean</font> | success | Indicates whether communication packets that Control-M Agent sends to and receives from Control-M Server are written to a file. |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__ctms_address_mode__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">string</font> | success | Indicates if the IP address is used instead of the host name. |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__daily_log_file_enabled__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">boolean</font> | success | Indicates if the ctmag_\<year>\<month>\<day>.log file is generated. |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__days_to_retain_log_files__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">integer</font> | success | Number of days to retain agent proclog files.<br><br>__Sample:__<br><font color=blue>1</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__default_printer__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">string</font> | success | The default printer for job OUTPUT files. |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__diagnostic_level__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">integer</font> | success | The debug level.<br><br>__Sample:__<br><font color=blue>0</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__echo_job_commands_into_sysout__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">boolean</font> | success | Indicates whether to print commands in the OUTPUT of a job. |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__foreign_language_support__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">string</font> | success | Indicates whether the system is configured for CJK languages or Latin1 languages.<br><br>__Sample:__<br><font color=blue>LATIN-1</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__job_children_inside_job_object__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">boolean</font> | success | Indicates whether procedures invoked by a job can be run outside the Job Object. |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__limit_log_file_size__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">integer</font> | success | The maximum size (MB) of diagnostic log files for a process or a thread.<br><br>__Sample:__<br><font color=blue>10</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__limit_log_version__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">integer</font> | success | The number of generations of diagnostic log information to keep for a process or a thread.<br><br>__Sample:__<br><font color=blue>10</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__listen_to_network_interface__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">string</font> | success | The network interface the agent is listening on.<br><br>__Sample:__<br><font color=blue>\*ANY</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__logical_agent_name__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">string</font> | success | The logical name of the agent. |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__logon_as_user__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">boolean</font> | success | Indicates whether the user account is used for the services to log on to. |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__logon_domain__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">string</font> | success | The logon domain of the user account. |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__measure_usage_day__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">integer</font> | success | The number of days to retain the files in the dailylog directory.<br><br>__Sample:__<br><font color=blue>7</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__persistent_connection__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">boolean</font> | success | Indicates whether NS process creates a persistent connection with the agent and manages the session with this agent. |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__primary_controlm_server_host__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">string</font> | success | The hostname of the computer where the current Control-M Server submits jobs to the Control-M Agent. |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__server_agent_protocol_version__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">integer</font> | success | The server-Agent communication protocol version.<br><br>__Sample:__<br><font color=blue>12</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__run_user_logon_script__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">boolean</font> | success | Indicates wether a user-defined logon script should be run by the Control-M Agent before running the standard user logon script. |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__server_to_agent_port__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">integer</font> | success | The port number that receives data from the Control-M Agent computer.<br><br>__Sample:__<br><font color=blue>7005</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__smtp_port__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">integer</font> | success | The port number on which the SMTP server communicates.<br><br>__Sample:__<br><font color=blue>25</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__smtp_reply_to_mail__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">string</font> | success | The e-mail address to which to send replies. |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__smtp_sender_friendly_name__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">string</font> | success | The name or alias that appears on the e-mail sent. |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__smtp_sender_mail__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">string</font> | success | The e-mail address of the sender.<br><br>__Sample:__<br><font color=blue>control@m</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__smtp_server_relay_name__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">string</font> | success | The name of the SMTP server. |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__ssl__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">boolean</font> | success | ndicates whether SSL is used to encrypt the communication between Control-M Server and the Control-M Agent. |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__job_output_name__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">string</font> | success | The prefix for the OUTPUT file name.<br><br>__Sample:__<br><font color=blue>JOBNAME</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__tcpip_timeout__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">integer</font> | success | The communication job-tracking timeout in seconds.<br><br>__Sample:__<br><font color=blue>60</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__timeout_for_agent_utilities__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">integer</font> | success | The maximum time (in seconds) the agent waits after sending a request to Control-M Server.<br><br>__Sample:__<br><font color=blue>600</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__tracker_event_port__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">integer</font> | success | The number of the port for sending messages to the Tracker process when jobs end.<br><br>__Sample:__<br><font color=blue>7035</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__tracker_polling_interval__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">integer</font> | success | The tracker event timeout in seconds.<br><br>__Sample:__<br><font color=blue>60</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__wrap_parameters_with_double_quotes__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">integer</font> | success | Indicates how parameter values (%%PARMn....%%PARMx) are managed by Control-M Agent for Microsoft Windows.<br><br>__Sample:__<br><font color=blue>4</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__default_agent_name__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">string</font> | success | The agent name.<br><br>__Sample:__<br><font color=blue>Default</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__cm_name__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">string</font> | success | The Control/M application version.<br><br>__Sample:__<br><font color=blue>WIN</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__cm_type__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">string</font> | success | The Control/M plateforme type.<br><br>__Sample:__<br><font color=blue>WIN2K</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__agent_version__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">string</font> | success | The agent version.<br><br>__Sample:__<br><font color=blue>9.0.19.200</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__fd_number__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">string</font> | success | The unique identifier of the agent.<br><br>__Sample:__<br><font color=blue>DRKAI.9.0.20.000</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__fix_number__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">string</font> | success | The unique identifier of the fix pack.<br><br>__Sample:__<br><font color=blue>DRKAI.9.0.20.000</font> |
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__agent_directory__<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="purple">string</font> | success | The installation folder of the agent.<br><br>__Sample:__<br><font color=blue>C:\\Program Files\\Control-M Agent\\Default\\</font> |

## Authors

* Stéphane Bilqué (@sbilque) Informatique CDC

## License

This project is licensed under the Apache 2.0 License.

See [LICENSE](LICENSE) to see the full text.
