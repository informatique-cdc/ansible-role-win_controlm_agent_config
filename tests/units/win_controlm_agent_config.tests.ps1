# Set $ErrorActionPreference to what's set during Ansible execution
$ErrorActionPreference = "Stop"

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
            Mock -CommandName Get-ItemProperty  -MockWith { }
            Mock -CommandName Set-ItemProperty  -MockWith { }

            $params = @{
                agent_to_server_port         = 7007
                server_to_agent_port         = 7008
                primary_controlm_server_host = 'server1'
                authorized_controlm_server_hosts = 'server1|server2|server3.cloud'
                tracker_event_port = 8000
                job_children_inside_job_object = $false
                job_output_name = 'JOBNAME'
            }

            It 'Should return params' {
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -Be $true
            }
        }
    }
}
finally {
    Invoke-TestCleanup
}



