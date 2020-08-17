#!/usr/bin/python
# -*- coding: utf-8 -*-

# This is a windows documentation stub.  Actual code lives in the .ps1
# file of the same name.

# Copyright 2020 Informatique CDC. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

from __future__ import absolute_import, division, print_function
__metaclass__ = type


ANSIBLE_METADATA = {'metadata_version': '1.1',
                    'status': ['preview'],
                    'supported_by': 'community'}

DOCUMENTATION = r'''
---
module: win_controlm_agent_config
short_description: Manipulate the configuration of a Control/M Agent
author:
    - Stéphane Bilqué (@sbilque) Informatique CDC
description:
    - This Ansible module allows to change the Control/M Agent configuration on a Windows host.
    - Control/M Agent configurations use both `CTMWINCFG` or `CTMAGCFG` command for setting configuration.
    - This module provides an implementation for working with Agent configuration in a deterministic way. Commands are not used. This module make change in registry locations.
options:
    agent_to_server_port:
        description:
            - Defines the port number in the Control-M/Agent computer where data is received from the Control-M/Server computer.
            - The value assigned to this parameter must correspond to the value assigned to the Server-to-Agent Port Number field in the configuration file on the corresponding ControlM/Agent computer.
        default: 7005
        type: int
    server_to_agent_port:
        description:
            - Defines the port number between 1024 and 65535 that receives data from the Control-M/Agent computer.
            - This value must match the Agent-to-Server Port Number in Control-M/Server. The value is the I(COMTIMOUT) communication job-tracking timeout in seconds.
        default: 7006
        type: int
    primary_controlm_server_host:
        description:
            - Defines the hostname of the computer where the current Control-M/Server submits jobs to the Control-M/Agent.
        type: str
    authorized_controlm_server_hosts:
        description:
            - Defines a list of backup servers which can replace the primary server if it fails. The Control-M/Agent only accept requests from servers on this list.
            - You cannot submit jobs to the same ControlM/Agent if there is more than one active Control-M/Server.
            - Another Control-M/Agent instance must be installed with unique ports to support this configuration or job status updates corrupt.
        type: str
    diagnostic_level:
        description:
            - Defines the debug level.
            - Valid values range from 0 to 4 where 0 indicates no diagnostic activity, and 4 indicates the highest level of diagnostic functionality.
        default: 0
        type: int
    communication_trace:
        description:
            - Flag indicating whether communication packets that Control-M/Agent sends to and receives from Control-M/Server are written to a file.
            - If set to c(yes), separate files are created for each session (job, ping, and so forth).
            - This parameter can only be changed after completing the installation.
        default: No
        type: bool
    days_to_retain_log_files:
        description:
            - Number of days to retain agent proclog files. After this period, agent proclog files are deleted by the New Day procedure.
            - Valid values: 1-99
        default: 1
        type: int
    daily_log_file_enabled:
        description:
            - Indicates if the ctmag_<year><month><day>.log file is generated c(Yes) or not c(No).
        default: Yes
        type: bool
    tracker_event_port:
        description:
            - Number of the port for sending messages to the Tracker process when jobs end.
        default: 7035
        type: int
    logical_agent_name:
        description:
            - Logical name of the agent.
            - The value specified should match the name the agent is defined by in Control-M/Server. Where multiple agent names are defined in Control-M/Server, and all use the same server-to-agent port, server messages are sent to that agent.
            - The logical name is used when the agent initiates the communication to Control-M/Server with the output from agent utilities and in messages sent by the agent to the server.
            - Default: c(Agent host name)
        type: str
    persistent_connection:
        description:
            - Indicates the persistent connection setting. Set the I(persistent_connection) parameter to connect to a specific agent with either a persistent or transient connection.
            - When I(persistent_connection) is set to c(Yes), the NS process creates a persistent connection with the agent and manages the session with this agent. If the connection is broken with an agent or NS is unable to connect with an agent, the agent is marked as Unavailable. When the connection with the agent is resumed, the NS recreates a persistent connection with the agent and marks the agent as Available.
        type: bool
        default: No
    allow_comm_init:
        description:
            - Determines if the agent can open a connection to the server when working in persistent connection mode.
            - When I(allow_comm_init) is set to c(Y), the Control-M/Agent to initiate the communication with the Control-M/Server.
        default: Yes
        type: bool
    foreign_language_support:
        description:
            - Indicates whether the system is configured for CJK languages or Latin1 languages.
        default: LATIN-1
        type: str
        choices: [ LATIN-1,CJK ]
    ssl:
        description:
            - Determines whether SSL is used to encrypt the communication between Control-M/Server and the ControlM/Agent.
        default: No
        type: bool
    server_agent_protocol_version:
        description:
            - Server-Agent communication protocol version.
            - Valid values: 12 or lower.
        default: 12
        type: int
    autoedit_inline:
        description:
            - Flag that indicates whether all variables will be set as environment variables in the script.
        type: bool
        default: yes
    listen_to_network_interface:
        description:
            - The network interface the agent is listening on.
            - It can be set to a specific hostname or IP address so that the agent port is not opened in the other interfaces.
            - Default: *ANY (the agent is listening on all available interfaces)
        default: "*ANY"
        type: str
    ctms_address_mode:
        description:
            - If this parameter is set to c(IP), the IP address instead of the host name is saved in I(ctms_hostmane).
            - Use this parameter when Control-M runs on a computer with more than one network card.
        type: str
        default: ""
    timeout_for_agent_utilities:
        description:
            - Maximum time (in seconds) the agent waits after sending a request to Control-M/Server. This timeout interval should be longer than the TCP/IP Timeout.
        type: int
        default: 600
    tcpip_timeout:
        description:
            - The communication job-tracking timeout in seconds.
            - When the value of ‘TCP/IP timeout’ is changed, using the configuration utility or CCM, the timeout part of the I(server_to_agent_port) and I(agent_to_server_port) parameters are changed.
            - Valid values: 0-999999
        default: 60
        type: int
    tracker_polling_interval:
        description:
            - Job Tracking Timeout. Tracker event timeout in seconds.
            - Valid values: 1-86400
        default: 60
        type: int
    limit_log_file_size:
        description:
            - Maximum size (MB) of diagnostic log files for a process or a thread.
            - When the defined size is reached, the log file is closed and a new one is created.
            - Restart the agent for the parameter to take effect
            - Valid values: 1 - 1000
        default: 10
        type: int
    limit_log_version:
        description:
            - Number of generations of diagnostic log information to keep for a process or a thread.
            - When the number is reached, the older log file is deleted.
            - Valid values: 0 - 99
        default: 10
        type: int
    measure_usage_day:
        description:
            - Determines the number of days to retain the files in the dailylog directory.
            - These files contain the information about jobs that is used to calculate the metrics for the usage measurement report.
        default: 7
        type: int
    logon_as_user:
        description:
            - Flag that specifies which user account is used for the services to log on to.
            - If this parameter is set to c(Yes), jobs are submitted with the permissions and environment variables of the specified user.
            - If this parameter is set to c(No), jobs are submitted with the permissions and environment variables of the local system account.
        default: No
        type: bool
    logon_domain:
        description:
            - The domain is determined by the value of this parameter if c(logon_domain) is not specified in <domain>\<username> in the Run_As parameter of the job definition.
            - If the domain is not specified in the Run_As parameter or this parameter, the user profile is searched in the trusted domains.
            - BMC recommends that you do not specify a value for Logon Domain
        type: str
        default: ""
    job_children_inside_job_object:
        description:
            - Flag that specifies if procedures invoked by a job can be run outside the Job Object.
            - If so, this prevents a situation in which the original job remains in executing mode until the invoked procedure completes.
            - If this parameter is set to c(Yes), all procedures invoked by the job are run outside the job object.
            - If this parameter is set to c(No), all procedures invoked by the job are run inside the job object.
        type: bool
        default: Yes
    add_job_statistics_to_sysout:
        description:
            - Flag that indicates how to manage job object processing statistics.
            - If this parameter is set to c(Yes), statistics are added to the end of the OUTPUT file
            - If this parameter is set to c(No), statistics are not added to the OUTPUT file.
        type: bool
        default: Yes
    job_output_name:
        description:
            - Determines the prefix for the OUTPUT file name.
            - If this parameter is set to c(MEMNAME), the OUTPUT file prefix is the MEMNAME of the job.
            - If this parameter is set to c(JOBNAME), the OUTPUT file prefix is the JOBNAME of the job.
        type: str
        choices: [ MEMNAME, JOBNAME ]
        default: MEMNAME
    wrap_parameters_with_double_quotes:
        description:
            - Indication of how parameter values (%%PARMn....%%PARMx) are managed by Control-M/Agent for Microsoft Windows.
            - If this parameter is set to c(1), this parameter is no longer relevant.
            - If this parameter is set to c(2), parameter values are always passed to the operating system without quotes. If quotes were specified in the job definition, they are removed before the parameter is passed onward by the agent. This option is compatible with the way that these parameters were managed in version 6.0.0x, or 6.1.01 with Fix Pack 1, 2, 3, or 4 installed. In this case, if a parameter value contains a blank, the operating system may consider each string as a separate parameter.
            - If this parameter is set to c(3), this parameter is no longer relevant.
            - If this parameter is set to c(4), parameters are passed to the operating system in exactly the same way that they were specified in the job definition. No quotes are added or removed in this case. This option is compatible with the way that parameters were managed by version 2.24.0x.
        type: int
        default: 4
    run_user_logon_script:
        description:
            - Indicates wether a user-defined logon script should be run by the Control-M/Agent before running the standard user logon script.
            - If this parameter is set to c(Yes), the user-defined logon script is run, if it exists.
            - If this parameter is set to c(No), the user-defined logon script is not run
        type: bool
        default: No
    cjk_encoding:
        description:
            - Determines the CJK encoding used by Control-M/Agent to run jobs.
        choices: [ UTF-8, JAPANESE EUC, JAPANESE SHIFT-JIS, KOREAN EUC, SIMPLIFIED CHINESE GBK, SIMPLIFIED CHINESE GB, TRADITIONAL CHINESE EUC, TRADITIONAL CHINESE BIG5 ]
        type: str
        default: UTF-8
    default_printer:
        description:
            - Default printer for job OUTPUT files.
        type: str
        default: ''
    echo_job_commands_into_sysout:
        description:
            - Specifies whether to print commands in the OUTPUT of a job.
            - If this parameter is set to c(Yes), implements ECHO_ON, which prints commands in the job OUTPUT.
            - If this parameter is set to c(No), implements ECHO_OFF, which does not print commands in the job OUTPUT.
        type: bool
        default: Yes
    smtp_server_relay_name:
        description:
            - The name of the SMTP server.
        type: str
    smtp_port:
        description:
            - The port number on which the SMTP server communicates.
            - Valid values: 0-65535
        type: int
        default: 25
    smtp_sender_mail:
        description:
            - The e-mail address of the sender.
            - Valid values: Text up to 99 characters
        type: str
        default: control@m
    smtp_sender_friendly_name:
        description:
            - The name or alias that appears on the e-mail sent.
        type: str
    smtp_reply_to_mail:
        description:
            - The e-mail address to which to send replies.
            - If this field is left empty, the sender e-mail address is used.
        type: str
'''

EXAMPLES = r'''
---
- hosts: all

  roles:
      - win_sqlserver_ceip

  tasks:

      - name: Desactivate all CEIP services
        win_sqlserver_ceip:
          state: absent

      - name: Enable all CEIP services
        win_sqlserver_ceip:
          state: present
'''

RETURN = r'''
config:
    description: The retrieved configuration.
    returned: success
    type: dict
    contains:
        agent_to_server_port:
            description: The port number in the Control-M/Agent computer where data is received from the Control-M/Server computer.
            returned: success
            type: int
            sample: 7006
        allow_comm_init:
            description: Indicates whether the agent can open a connection to the server when working in persistent connection mode.
            returned: success
            type: bool
        authorized_controlm_server_hosts:
            description: A list of backup servers which can replace the primary server if it fails.
            returned: success
            type: str
        autoedit_inline:
            description: Indicates whether all variables will be set as environment variables in the script.
            returned: success
            type: bool
        cjk_encoding:
            description: The CJK encoding used by Control-M/Agent to run jobs.
            returned: success
            type: str
            sample: UTF-8
        communication_trace:
            description: Indicates whether communication packets that Control-M/Agent sends to and receives from Control-M/Server are written to a file.
            returned: success
            type: bool
        ctms_address_mode:
            description: Indicates if the IP address is used instead of the host name.
            returned: success
            type: str
        daily_log_file_enabled:
            description: Indicates if the ctmag_<year><month><day>.log file is generated.
            returned: success
            type: bool
        days_to_retain_log_files:
            description: Number of days to retain agent proclog files.
            returned: success
            type: int
            sample: 1
        default_printer:
            description: The default printer for job OUTPUT files.
            returned: success
            type: str
        diagnostic_level:
            description: The debug level.
            returned: success
            type: int
            sample: 0
        echo_job_commands_into_sysout:
            description: Indicates whether to print commands in the OUTPUT of a job.
            returned: success
            type: bool
        foreign_language_support:
            description: Indicates whether the system is configured for CJK languages or Latin1 languages.
            returned: success
            type: str
            sample: LATIN-1
        job_children_inside_job_object:
            description: Indicates whether procedures invoked by a job can be run outside the Job Object.
            returned: success
            type: bool
        limit_log_file_size:
            description: The maximum size (MB) of diagnostic log files for a process or a thread.
            returned: success
            type: int
            sample: 10
        limit_log_version:
            description: The number of generations of diagnostic log information to keep for a process or a thread.
            returned: success
            type: int
            sample: 10
        listen_to_network_interface:
            description: The network interface the agent is listening on.
            returned: success
            type: str
            sample: *ANY
        logical_agent_name:
            description: The logical name of the agent.
            returned: success
            type: str
        logon_as_user:
            description: Indicates whether the user account is used for the services to log on to.
            returned: success
            type: bool
        logon_domain:
            description: The logon domain of the user account.
            returned: success
            type: str
        measure_usage_day:
            description: The number of days to retain the files in the dailylog directory.
            returned: success
            type: int
            sample: 7
        persistent_connection:
            description: Indicates whether NS process creates a persistent connection with the agent and manages the session with this agent.
            returned: success
            type: bool
        primary_controlm_server_host:
            description: The hostname of the computer where the current Control-M/Server submits jobs to the Control-M/Agent.
            returned: success
            type: str
        server_agent_protocol_version:
            description: The server-Agent communication protocol version.
            returned: success
            type: int
            sample: 12
        run_user_logon_script:
            description: Indicates wether a user-defined logon script should be run by the Control-M/Agent before running the standard user logon script.
            returned: success
            type: bool
        server_to_agent_port:
            description: The port number that receives data from the Control-M/Agent computer.
            returned: success
            type: int
            sample: 7005
        smtp_port:
            description: The port number on which the SMTP server communicates.
            returned: success
            type: int
            sample: 25
        smtp_reply_to_mail:
            description: The e-mail address to which to send replies.
            returned: success
            type: str
        smtp_sender_friendly_name:
            description: The name or alias that appears on the e-mail sent.
            returned: success
            type: str
        smtp_sender_mail:
            description: The e-mail address of the sender.
            returned: success
            type: str
            sample: control@m
        smtp_server_relay_name:
            description: The name of the SMTP server.
            returned: success
            type: str
        ssl:
            description: ndicates whether SSL is used to encrypt the communication between Control-M/Server and the ControlM/Agent.
            returned: success
            type: bool
        job_output_name:
            description: The prefix for the OUTPUT file name.
            returned: success
            type: str
            sample: JOBNAME
        tcpip_timeout:
            description: The communication job-tracking timeout in seconds.
            returned: success
            type: int
            sample: 60
        timeout_for_agent_utilities:
            description: The maximum time (in seconds) the agent waits after sending a request to Control-M/Server.
            returned: success
            type: int
            sample: 600
        tracker_event_port:
            description: The number of the port for sending messages to the Tracker process when jobs end.
            returned: success
            type: int
            sample: 7035
        tracker_polling_interval:
            description: The tracker event timeout in seconds.
            returned: success
            type: int
            sample: 60
        wrap_parameters_with_double_quotes:
            description: Indicates how parameter values (%%PARMn....%%PARMx) are managed by Control-M/Agent for Microsoft Windows.
            returned: success
            type: int
            sample: 4
        default_agent_name:
            description: The agent name.
            returned: success
            type: str
            sample: Default
        cm_name:
            description: The Control/M application version.
            returned: success
            type: str
            sample: WIN
        cm_type:
            description: The Control/M plateforme type.
            returned: success
            type: str
            sample: WIN2K
        agent_version: The agent version.
            description:
            returned: success
            type: str
            sample: 9.0.19.200
        fd_number:
            description: The unique identifier of the agent.
            returned: success
            type: str
            sample: DRKAI.9.0.20.000
        fix_number: The unique identifier of the fix pack.
            description:
            returned: success
            type: str
            sample: DRKAI.9.0.20.000
        agent_directory:
            description: The installation folder of the agent.
            returned: success
            type: str
            sample: C:\Program Files\Control-M Agent\Default\
'''
