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

$RegistryPath = 'HKLM:\SOFTWARE\BMC Software\Control-M/Agent'

try {

    Describe 'win_controlm_agent_config' -Tag 'Set' {

        Context 'Control/M Agent is installed' {

            BeforeAll {

                Mock -CommandName Get-ItemProperty -ParameterFilter { $Path.StartsWith($RegistryPath) } -MockWith {
                    return @{
                        ATCMNDATA           = '9000'
                        AGCMNDATA           = '9001'
                        TRACKER_EVENT_PORT  = '9002'
                        CTMSHOST            = 'server2'
                        CTMPERMHOSTS        = 'server2'
                        OUTPUT_NAME         = 'MEMNAME'
                        COMM_TRACE          = '1'
                        JOB_WAIT            = 'Y'
                        COMMOPT             = 'SSL=N;DUMMY=N'
                        LIMIT_LOG_FILE_SIZE = '11'
                        LIMIT_LOG_VERSIONS  = '11'
                    }
                }

                Mock -CommandName Get-Service -ParameterFilter { $Name -eq 'ctmag' } -MockWith {
                    return @{
                        Name   = 'ctmag'
                        Status = 'Running'
                    }
                }

                Mock -CommandName Set-ItemProperty -ParameterFilter { $Path.StartsWith($RegistryPath) } -MockWith {
                    Write-Host "Item $Name is set in the registry with $Value"
                }

                Mock -CommandName Restart-Service -ParameterFilter { $Name -eq 'ctmag' } -MockWith {
                    Write-Host "The service is restard"
                }
                Mock -CommandName Get-NetFirewallPortFilter -MockWith { }
                Mock -CommandName Set-NetFirewallPortFilter -MockWith { }
            }

            It 'Should return the configuration only' {

                $params = @{ }
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -Be $false
            }

            It 'Should change port numbers' {

                $params = @{
                    agent_to_server_port = 8000
                    server_to_agent_port = 8001
                    tracker_event_port   = 8002
                }

                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -Be $true
                $result.diff.after.agent_to_server_port | Should -Be 8000
                $result.diff.after.server_to_agent_port | Should -Be 8001
                $result.diff.after.tracker_event_port | SHould -Be 8002
            }

            It 'Should change controlm server hosts' {

                $params = @{
                    primary_controlm_server_host     = 'server1'
                    authorized_controlm_server_hosts = 'server1|server2|server3.cloud'
                }
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -Be $true
            }

            It 'Should change job name' {

                $params = @{
                    job_output_name = 'JOBNAME'
                }
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -Be $true
            }

            It 'Should change communication trace' {

                $params = @{
                    communication_trace = $false
                }
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -Be $true
            }

            It 'Should change job children inside job object' {

                $params = @{
                    job_children_inside_job_object = $false
                }
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -Be $true
            }

            It 'Should change ssl' {

                $params = @{
                    ssl = $true
                }
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -Be $true
                $result.diff.before.ssl | Should -Be $false
                $result.diff.after.ssl | Should -Be $true
            }

            It 'Should change maximum log of diagnostic logs files' {

                $params = @{
                    limit_log_file_size = 1000
                }
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -Be $true
                $result.diff.before.limit_log_file_size | Should -Be 11
                $result.diff.after.limit_log_file_size | Should -Be 1000
            }

            It 'Should change the number of generations of diagnostic log information' {

                $params = @{
                    limit_log_version = 99
                }
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -Be $true
                $result.diff.before.limit_log_version | Should -Be 11
                $result.diff.after.limit_log_version | Should -Be 99
            }
        }
    }
}
finally {
    Invoke-TestCleanup
}
