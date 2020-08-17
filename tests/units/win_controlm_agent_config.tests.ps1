# Set $ErrorActionPreference to what's set during Ansible execution
$ErrorActionPreference = "Stop"

# Update Pester if needed
try {
    $PesterVersion = [version](get-InstalledModule -Name Pester -ErrorAction SilentlyContinue).Version
    $DoPesterUpdate = ($PesterVersion.Major -le 3)
}
catch {
    $DoPesterUpdate = $true
}
finally {
    if ($DoPesterUpdate) {
        Install-Module -Name Pester -Force -SkipPublisherCheck
    }
}

#Get Current Directory
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path

#Get Function Name
$moduleName = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -Replace ".Tests.ps1"

#Resolve Path to Module path
$ansibleModulePath = "$Here\..\..\library\$moduleName.ps1"

function Get-AnsibleCSharpUtils {
    param (
        [parameter(ValueFromPipeline)]
        [string]$Path
    )
    $content = get-content -path $Path
    $module_pattern = [Regex]"(?im)#AnsibleRequires -CSharpUtil (?<module>[a-z.]*)"
    $modules_matches = $module_pattern.Matches($content)
    foreach ($match in $modules_matches) {
        $match.Groups["module"].Value
    }
}

function Import-AnsibleCSharpUtils {
    param (
        [parameter(ValueFromPipeline)]
        [string[]]$name
    )
    begin {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    }

    process {
        $moduleName = $_
        $ModulePath = "$Here\$moduleName.cs"
        if (!(Test-Path -Path $ModulePath)) {
            $url = "https://raw.githubusercontent.com/ansible/ansible/stable-2.8/lib/ansible/module_utils/csharp/$moduleName.cs"
            $output = "$Here\$moduleName.cs"
            $wc = New-Object System.Net.WebClient
            $wc.DownloadFile($url, $output)
        }
        $_csharp_utils = @(
            [System.IO.File]::ReadAllText($ModulePath)
        )
        'Ansible.ModuleUtils.AddType' | Import-AnsibleModuleUtils

        Add-CSharpType -References $_csharp_utils -IncludeDebugInfo
    }
}

function Get-AnsibleModuleUtils {
    param (
        [parameter(ValueFromPipeline)]
        [string]$Path
    )
    $content = get-content -path $Path
    $module_pattern = [Regex]"(?im)#Requires -Module (?<module>[a-z.]*)"
    $modules_matches = $module_pattern.Matches($content)
    foreach ($match in $modules_matches) {
        $match.Groups["module"].Value
    }
}

function Import-AnsibleModuleUtils {
    param (
        [parameter(ValueFromPipeline)]
        [string[]]$name
    )
    begin {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    }

    process {
        $moduleName = $_
        $ModulePath = "$Here\$moduleName.psm1"
        if (!(Test-Path -Path $ModulePath)) {
            $url = "https://raw.githubusercontent.com/ansible/ansible/stable-2.8/lib/ansible/module_utils/powershell/$moduleName.psm1"
            $output = "$Here\$moduleName.psm1"
            $wc = New-Object System.Net.WebClient
            $wc.DownloadFile($url, $output)
        }
        if (-not (Get-Module -Name $moduleName -ErrorAction SilentlyContinue)) {
            Import-Module -Name $ModulePath
        }
    }
}
function Invoke-TestSetup {
    $ModuleUtils = Get-AnsibleCSharpUtils -Path $ansibleModulePath
    if ($ModuleUtils) {
        $ModuleUtils | Import-AnsibleCSharpUtils
    }

    $ModuleUtils = Get-AnsibleModuleUtils -Path $ansibleModulePath
    if ($ModuleUtils ) {
        $ModuleUtils | Import-AnsibleModuleUtils
    }
}
function Invoke-TestCleanup {
    $ModuleUtils = Get-AnsibleModuleUtils -Path $ansibleModulePath
    if ($ModuleUtils) {
        $ModuleUtils | Remove-Module
    }
}

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

            Mock -CommandName Set-ItemProperty  -MockWith { }
            Mock -CommandName Get-Service -MockWith { }
            Mock -CommandName Restart-Service -MockWith { }
            Mock -CommandName Get-NetFirewallPortFilter -MockWith { }
            Mock -CommandName Set-NetFirewallPortFiltere -MockWith { }

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
                        OUTPUT_NAME = 'JOBNAME'
                    }
                }

                $params = @{
                    job_output_name = 'MEMNAME'
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

            It 'Should change job children inside job_ bject' {

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



