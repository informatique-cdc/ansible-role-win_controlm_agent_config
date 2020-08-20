# Set $ErrorActionPreference to what's set during Ansible execution
$ErrorActionPreference = "Stop"

#Get Current Directory
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path

.$(Join-Path -Path $Here -ChildPath 'test_utils.ps1')

# Update Pester if needed
Update-Pester

#Get Function Name
$moduleName = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -Replace ".Tests.ps1"

#Resolve Path to Module path
$ansibleModulePath = "$Here\..\..\library\$moduleName.ps1"

Invoke-TestSetup

Function Invoke-AnsibleModule {
    [CmdletBinding()]
    Param(
        [hashtable]$params
    )

    begin {
        $global:complex_args = @{
            "_ansible_check_mode" = $false
            "_ansible_diff"       = $true
        } + $params
    }
    Process {
        . $ansibleModulePath
        return $module.result
    }
}

try {
    Describe 'win_controlm_agent_config' -Tag 'Set' {

        Context 'Control/M Agent is installed' {

            Mock -CommandName Set-ItemProperty -MockWith { }
            Mock -CommandName Get-Service -MockWith { }
            Mock -CommandName Restart-Service -MockWith { }
            Mock -CommandName Get-NetFirewallPortFilter -MockWith { }
            Mock -CommandName Set-NetFirewallPortFilter -MockWith { }

            It 'Should return the configuration only' {

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        ATCMNDATA          = '9000'
                        AGCMNDATA          = '9001'
                        TRACKER_EVENT_PORT = '9002'
                    }
                }

                $params = @{ }

                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -Be $false
            }

            It 'Should change port numbers' {

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        ATCMNDATA          = '9000'
                        AGCMNDATA          = '9001'
                        TRACKER_EVENT_PORT = '9002'
                    }
                }

                $params = @{
                    agent_to_server_port = 8000
                    server_to_agent_port = 8001
                    tracker_event_port   = 8002
                }

                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -Be $true
            }

            It 'Should change controlm server hosts' {

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        CTMSHOST     = 'server2'
                        CTMPERMHOSTS = 'server2'
                    }
                }

                $params = @{
                    primary_controlm_server_host     = 'server1'
                    authorized_controlm_server_hosts = 'server1|server2|server3.cloud'
                }
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -Be $true
            }

            It 'Should change job name' {

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        OUTPUT_NAME = 'MEMNAME'
                    }
                }

                $params = @{
                    job_output_name = 'JOBNAME'
                }
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -Be $true
            }

            It 'Should change communication trace' {

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        COMM_TRACE = '1'
                    }
                }
                $params = @{
                    communication_trace = $false
                }
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -Be $true
            }

            It 'Should change job children inside job object' {

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        JOB_WAIT = 'Y'
                    }
                }
                $params = @{
                    job_children_inside_job_object = $false
                }
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -Be $true
            }

            It 'Should change ssl' {

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        COMMOPT = 'SSL=N;DUMMY=N'
                    }
                }
                $params = @{
                    ssl = $true
                }
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -Be $true
                $result.diff.before.ssl | Should -Be $false
                $result.diff.after.ssl | Should -Be $true
            }
        }
    }
}
finally {
    Invoke-TestCleanup
}
