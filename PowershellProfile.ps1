#########################################################################################################################
#   This file is just a recommendation for some of the function I think we/I use often
#
#   You can take this and change it to however you like it. (be sure to contribute back if you find something useful)   #
#########################################################################################################################

# Variables for BestEx
$bestexLibrariesPath ="C:\Users\${env:USERNAME}\Dev\QTrade_BestEx.Libraries\BestEx.Libraries"
$bestexInrulePath = "C:\Users\${env:USERNAME}\Dev\QTrade_BestEx.InRule\BestEx.InRule"
$streamConnectionPath = "C:\Users\${env:USERNAME}\Dev\QTrade_StreamConnection\StreamConnection"

$dashAccount = "${env:USERNAME}-" #If your dash account username is not {USERNAME}-, change it here.

$dockerScriptsPath = "C:\Users\${env:USERNAME}\Dev\QTrade_BestEx.Scripts\BestEx.Scripts\Docker"
$bestexscriptsPath = "C:\Users\${env:USERNAME}\Dev\QTrade_BestEx.Scripts\BestEx.Scripts\CustomServices"
$dockerAdminCertPath = "C:\Users\${env:USERNAME}\Dev\auth\dash-general"
$dockerCertPath = "C:\Users\${env:USERNAME}\Dev\auth\general"
$dockerSandboxCertPath = "C:\Users\${env:USERNAME}\Dev\auth\sandbox-general"

$commonProjectPath = "${bestexLibrariesPath}\Common\BestEx.Common\BestEx.Common.fsproj"
$bondProjectPath = "${bestexLibrariesPath}\BondEventResolution\BestEx.BondEventResolution\BestEx.BondEventResolution.csproj"
$frameworkProjectPath = "${bestexLibrariesPath}\Framework\BestEx.Framework\BestEx.Framework.fsproj"

$inRuleDomainProjectPath = "${bestexInrulePath}\BestEx.InRule.Wrappers\BestEx.InRule.Wrappers.csproj"
$inRuleClientProjectPath = "${bestexInrulePath}\BestEx.InRule\BestEx.InRule.fsproj"

$streamConnectionNuspecPath = "${streamConnectionPath}\FinEx.StreamConnection.nuspec"
$streamConnectionProjectPath = "${streamConnectionPath}\FinEx.Kafka\FinEx.Kafka.fsproj"

function prompt {
    Write-Host ("[" + $((getDockerLocation).ToUpper()) + "]") -nonewline -ForegroundColor Yellow
    Write-Host("[" + $(getKubernetesInfo) + "] ") -nonewline -ForegroundColor Green
    Write-Host ("$(Get-Date) $(Get-Location)" )
    return " > "
}

function getDockerLocation {
    If ($env:DOCKER_HOST -like "*qldockerucp*") { return "enterprise"; }
    ElseIf ($env:DOCKER_HOST -like "*qldockersandbox*") { return "sandbox"; }
    Else { return "local"; }
}

function getKubernetesInfo {
    return "$(kubectl config current-context) | $(kubens --current)";
}

function set-default-colors {
    # set regular console colors
    [console]::backgroundcolor = "black"
    # [console]::backgroundcolor = "white"
    [console]::foregroundcolor = "darkyellow"
    [console]::parameterforegroundcolor = "cyan"

    # set special colors

    $p = $host.privatedata

    $p.ErrorForegroundColor = "Red"
    $p.ErrorBackgroundColor = "Black"
    $p.WarningForegroundColor = "Yellow"
    $p.WarningBackgroundColor = "Black"
    $p.DebugForegroundColor = "#00FFFF"
    $p.DebugBackgroundColor = "Black"
    $p.VerboseForegroundColor = "Yellow"
    $p.VerboseBackgroundColor = "Black"
    $p.ProgressForegroundColor = "Yellow"
    $p.ProgressBackgroundColor = "Black"

    # clear screen
    clear-host
}

function ff ([string] $glob) { get-childitem -recurse -include $glob }
function ll { get-childitem -force }
function docker-ps-a { docker ps -a }
function docker-ps { docker ps }
function delete-all-containers { If ( $(getDockerLocation) -eq "local" ) { docker rm -fv $(docker ps -aq) }          Else { Write-Warning "You can only run `delete-all-containers` command when on Local Docker" } }
function delete-all-images { If ( $(getDockerLocation) -eq "local" ) { docker rmi -f $(docker images -q) }       Else { Write-Warning "You can only run `delete-all-images` command when on Local Docker" } }
function delete-all-volumes { If ( $(getDockerLocation) -eq "local" ) { docker volume rm $(docker volume ls -q) } Else { Write-Warning "You can only run `delete-all-containers` command when on Local Docker" } }
function switch-to-admin { runas /profile /user:MI\${dashAccount} "powershell.exe" }
function docker-total-fresh-start {
    delete-all-containers
    delete-all-images
    delete-all-volumes
}

function change-docker-remote-to-UCP {
    param(  $admin = $False,
        $cluster)

    $Env:DOCKER_TLS_VERIFY = "1"
    If ($cluster -eq "enterprise") {
        $Env:DOCKER_HOST = "tcp://qldockerucp.rockfin.com:443"
        If ($admin -eq $True) { $Env:DOCKER_CERT_PATH = $dockerAdminCertPath }
        Else { $Env:DOCKER_CERT_PATH = $dockerCertPath }
    }

    ElseIf ($cluster -eq "local") {
        If (Test-Path env:DOCKER_HOST ) { Remove-Item Env:DOCKER_HOST }
        If (Test-Path env:DOCKER_CERT_PATH ) { Remove-Item Env:DOCKER_CERT_PATH }
        If (Test-Path env:COMPOSE_TLS_VERSION ) { Remove-Item Env:COMPOSE_TLS_VERSION }
        If (Test-Path env:DOCKER_TLS_VERIFY ) { Remove-Item Env:DOCKER_TLS_VERIFY }
    }

    ElseIf ($cluster -eq "sandbox") {
        $Env:DOCKER_HOST = "tcp://qldockersandbox.rockfin.com:443"
        $Env:DOCKER_CERT_PATH = $dockerSandboxCertPath
    }
}

function docker-ucp-enterprise { change-docker-remote-to-UCP -admin $False -cluster enterprise }
function docker-ucp-enterprise-admin { change-docker-remote-to-UCP -admin $True -cluster enterprise }
function docker-ucp-sandbox { change-docker-remote-to-UCP -admin $False -cluster sandbox }
function docker-local { change-docker-remote-to-UCP -cluster local }

function add-bestex-scripts-to-path-env {
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";${dockerScriptsPath}", [EnvironmentVariableTarget]::Process)
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";${bestexscriptsPath}", [EnvironmentVariableTarget]::Process)
}

function push-bestex-common {
    PushToLocalNuget -Project $commonProjectPath
}

function push-bestex-bond {
    PushToLocalNuget -Project $bondProjectPath
}

function push-bestex-framework {
    PushToLocalNuget -Project $frameworkProjectPath
}
function push-bestex-inrule {
    PushToLocalNuget -Project $inRuleDomainClientPath
}
function push-stream-connection {
    PushToLocalNuget -Project $streamConnectionProjectPath -Nuspec $streamConnectionNuspecPath
}
function print-detailed-history {
    Get-History | Select-Object Id, StartExecutionTime, CommandLine
}

#region For personal use
function pull-main {
    if(test-git -eq $true) {
        $branch = git branch --show-current
        if ($branch -ne "main") {
            git checkout main
        }
        git pull
    }
}
function pull-and-merge-main {
    if (test-git -eq $true) {
        $branch = git branch --show-current
        pull-main
        if ($branch -ne "main") {
            git checkout $branch
            git merge main
        }
    }

}

function pull-merge-push {
    if (test-git -eq $true) {
        pull-and-merge-main
        git push
    }
}

function log-into-redis {
    if (Test-Path "C:\Users\${env:USERNAME}\OneDrive - Knex\Downloads\credentials") {
        Set-Location "C:\Users\${env:USERNAME}\Dev\"
        .\instance-connect.ps1
    }
    else {
        Write-Warning "Credentials needed from awsconsole/ before logging in"
    }
}

function branch-off-main {
    [CmdletBinding()]
    param(
            [Parameter(Mandatory)]
            [string]
            [ValidatePattern("^\d+_[a-zA-Z_0-9-]")]
            $branch
        )
    if(test-git -eq $true){
        pull-main
        git checkout -b $branch
    }
}

function test-git {
    $ErrorActionPreference = 'SilentlyContinue'
    $result
    if ((git branch)) {
        $result = $true
    } else {
        Write-Warning "This is not a git repository"
        $result = $false
    }
    $ErrorActionPreference = 'Continue'
    return $result
}

function bounce-custom-service {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $service,
        [Parameter(Mandatory)]
        [ValidateSet("qa","int","prod")]
        [string]
        $environment,
        [Parameter()]
        [int]
        $scale=6,
        [Parameter()]
        [bool]
        $admin=$false
    )
    if($admin){
        ucp-enterprise-admin
    } else {
        ucp-enterprise
    }
    docker service scale bestex_${environment}_custom_services_${service}=0
    docker service scale bestex_${environment}_custom_services_${service}=$scale

}

function bounce-rule-decorator-qa {
    bounce-custom-service -service ruledecorator -environment qa
}

function bounce-stream-replicator {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateRange(1,6)]
        [int]
        $num
    )
    ucp-enterprise
    docker service scale bestex_StreamReplicators_streamreplicator_${num}=0
    docker service scale bestex_StreamReplicators_streamreplicator_${num}=1
}

function rename-branch {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        [ValidatePattern("^\d+_[a-zA-Z_0-9-]")]
        $branch
    )
    git branch -m $branch
}

function create-random-branch {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $branch
    )
    if(test-git -eq $true){
        git checkout -b $branch
    }
}

function rename-random-branch {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $branch
    )
    git branch -m $branch
}

function publish-and-push-branch {
    if(test-git -eq $true) {
        $branch = git branch --show-current
        git push --set-upstream origin $branch
    }
}
# Create a pull request and copy the URL to the clipboard
function create-pull-request {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $title
    )
    if(test-git -eq $true) {
        $commitString = git log --pretty=format:"%h"
        $commits = $commitString -split "\n"
        Write-Debug $commits
    }
}

function update-existing-file {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $src,
        [Parameter(Mandatory)]
        [string]
        $dest,
        [Parameter(Mandatory)]
        [string]
        $file
    )
    if(Test-Path "${dest}\${file}") {
    if($dest -is [System.IO.DirectoryInfo]) {
        $shouldRecurse = "-Recurse"
    } else {
        $shouldRecurse = ""
    }

    Remove-Item "${dest}\${file}" $shouldRecurse
    Copy-Item "${src}\${file}" -Destination "${dest}\${file}" $shouldRecurse
    Write-Host("${dest}\${file} copied successfully")
}
}

function update-dockerdb {
    $dest = "C:\Users\CTallquist\Dev\DockerDBScripts"
    $sqldb = "C:\Users\CTallquist\Dev\QTrade_CustomServices\CustomServices\SQLDB\SolutionItems\DockerDBScripts"
    if(Test-Path -Path $dest -IsValid) {
        update-existing-file -src $sqldb -dest $dest -file "DacPacFiles"
        update-existing-file -src $sqldb -dest $dest -file "CreateBestExDB.sql"
        update-existing-file -src $sqldb -dest $dest -file "docker-compose-yml"
        update-existing-file -src $sqldb -dest $dest -file "Dockerfile"
        update-existing-file -src $sqldb -dest $dest -file "README.md"
    }
    Write-Host ("Docker DB updated successfully.")
}

function Invoke-Login-ECR {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $acctNum,
        [Parameter()]
        [string]
        $region="us-east-2"
    )

    Invoke-Expression "aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${acctNum}.dkr.ecr.${region}.amazonaws.com"
}

function build-and-push-to-ecr {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $image,
        [Parameter(Mandatory)]
        [string]
        $folderPath
    )

    Invoke-Expression "docker build -t ${image} ${folderPath}"
    Invoke-Expression "docker push ${image}"
}
#endregion

Set-Alias -Name dpsa -Value docker-ps-a
Set-Alias -Name dps -Value docker-ps
Set-Alias -Name dfs -Value docker-total-fresh-start
Set-Alias -Name admin -Value switch-to-admin

Set-Alias -Name 'ucp-enterprise' docker-ucp-enterprise
Set-Alias -Name 'ucp-enterprise-admin' docker-ucp-enterprise-admin
Set-Alias -Name 'local' docker-local
Set-Alias -Name 'sandbox' docker-ucp-sandbox

Set-Alias -Name sbss StartBackingServices
Set-Alias -Name PushCommon push-bestex-common
Set-Alias -Name PushBond push-bestex-bond
Set-Alias -Name PushFramework push-bestex-framework
Set-Alias -Name PushInRule push-bestex-inrule

#region For personal use, but could potentially be used by others if they choose
Set-Alias -Name pmm -Value pull-and-merge-main
Set-Alias -Name pmmp -Value pull-merge-push
Set-Alias -Name redis -Value log-into-beta-redis
Set-Alias -Name bom -Value branch-off-main
Set-Alias -Name brdqa -Value bounce-rule-decorator-qa
Set-Alias -Name bsr -Value bounce-stream-replicator
Set-Alias -Name ppb -Value publish-and-push-branch
#endregion

# Setup for saving the history of commands
$HistoryFilePath = Join-Path ([Environment]::GetFolderPath('UserProfile')) .ps_history
Register-EngineEvent PowerShell.Exiting -Action { Get-History | Export-Clixml $HistoryFilePath } | out-null
if (Test-path $HistoryFilePath) { Import-Clixml $HistoryFilePath | Add-History }
$MaximumHistoryCount = 500
Set-Alias -Name hh print-detailed-history

# Setup calls
# set-default-colors
if($PSHOME -ne $null) { Copy-Item $PSHOME\Microsoft.PowerShell_profile.ps1 $PROFILE; }
add-bestex-scripts-to-path-env
