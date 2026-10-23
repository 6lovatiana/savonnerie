[CmdletBinding()]
param(
    [string]$WildFlyHome = $env:WILDFLY_HOME,
    [string]$AntCommand = 'ant',
    [string]$JavaHome,
    [int]$HttpPort = 8088
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$BuildFile = Join-Path $ProjectRoot 'build.xml'

if ([string]::IsNullOrWhiteSpace($WildFlyHome)) {
    $WildFlyHome = 'C:\wildfly-10.1.0.Final'
}
if ([string]::IsNullOrWhiteSpace($JavaHome)) {
    # WildFly 10 uses legacy JDK internals and does not start reliably on Java 17+.
    $KnownJavaHome = 'C:\Program Files\Eclipse Adoptium\jdk-8.0.504.1-hotspot'
    if (Test-Path -LiteralPath (Join-Path $KnownJavaHome 'bin\javac.exe') -PathType Leaf) {
        $JavaHome = $KnownJavaHome
    } elseif (-not [string]::IsNullOrWhiteSpace($env:JAVA_HOME)) {
        $JavaHome = $env:JAVA_HOME
    }
}
if ($AntCommand -eq 'ant') {
    $KnownAnt = 'C:\apache-ant-1.10.18\bin\ant.bat'
    if (Test-Path -LiteralPath $KnownAnt -PathType Leaf) {
        $AntCommand = $KnownAnt
    }
}

if (-not (Test-Path -LiteralPath $BuildFile -PathType Leaf)) {
    throw "Le fichier de compilation est introuvable : $BuildFile"
}

$WildFlyHome = [System.IO.Path]::GetFullPath($WildFlyHome)
$DeployDirectory = Join-Path $WildFlyHome 'standalone\deployments'
$Standalone = Join-Path $WildFlyHome 'bin\standalone.bat'
$Libraries = Join-Path $ProjectRoot 'build-file\lib'

if (-not (Test-Path -LiteralPath $Standalone -PathType Leaf)) {
    throw "WildFly was not found at '$WildFlyHome'. Pass -WildFlyHome or set WILDFLY_HOME."
}
if (-not (Test-Path -LiteralPath $Libraries -PathType Container) -or
    -not (Get-ChildItem -LiteralPath $Libraries -Filter '*.jar' -File | Select-Object -First 1)) {
    throw "Ant libraries are missing from '$Libraries'."
}

$Ant = Get-Command $AntCommand -ErrorAction SilentlyContinue
if (-not $Ant) {
    throw "Apache Ant est introuvable ('$AntCommand'). Installez Ant ou indiquez le chemin de ant.bat avec -AntCommand."
}

if (-not [string]::IsNullOrWhiteSpace($JavaHome)) {
    $JavaHome = [System.IO.Path]::GetFullPath($JavaHome)
    if (-not (Test-Path -LiteralPath (Join-Path $JavaHome 'bin\javac.exe') -PathType Leaf)) {
        throw "No javac.exe compiler was found in '$JavaHome'."
    }
    $env:JAVA_HOME = $JavaHome
    $env:Path = (Join-Path $JavaHome 'bin') + ';' + $env:Path
    $JavaInfo = New-Object System.Diagnostics.ProcessStartInfo
    $JavaInfo.FileName = Join-Path $JavaHome 'bin\java.exe'
    $JavaInfo.Arguments = '-version'
    $JavaInfo.UseShellExecute = $false
    $JavaInfo.RedirectStandardError = $true
    $JavaInfo.RedirectStandardOutput = $true
    $JavaProcess = [System.Diagnostics.Process]::Start($JavaInfo)
    $JavaVersionOutput = $JavaProcess.StandardError.ReadToEnd() + $JavaProcess.StandardOutput.ReadToEnd()
    $JavaProcess.WaitForExit()
    if ($JavaVersionOutput -notmatch 'version "1\.8\.') {
        throw "WildFly 10 requires Java 8 for this project. Selected Java at '$JavaHome' reports: $($JavaVersionOutput.Trim())"
    }
}

if (-not (Get-Command javac -ErrorAction SilentlyContinue)) {
    throw 'Java compiler javac was not found. Set JAVA_HOME or pass -JavaHome to a Java 8 JDK.'
}

New-Item -ItemType Directory -Path $DeployDirectory -Force | Out-Null

# Clear stale WildFly scanner status files so an old .failed marker does not
# collide with the fresh .dodeploy marker created by the Ant target.
foreach ($StatusSuffix in @('.deployed', '.failed', '.isdeploying', '.pending', '.undeployed', '.dodeploy')) {
    $StatusFile = Join-Path $DeployDirectory ("socobis.war$StatusSuffix")
    if (Test-Path -LiteralPath $StatusFile -PathType Leaf) {
        Remove-Item -LiteralPath $StatusFile -Force
    }
}

Write-Host 'Compiling and deploying Savonnerie...' -ForegroundColor Cyan
Push-Location $ProjectRoot
try {
    & $Ant.Source "-Ddeploy.dir=$DeployDirectory" -f $BuildFile deploy
    if ($LASTEXITCODE -ne 0) {
        throw "Ant compilation or deployment failed (exit code $LASTEXITCODE)."
    }
}
finally {
    Pop-Location
}

$DeploymentMarker = Join-Path $DeployDirectory 'socobis.war.dodeploy'
if (-not (Test-Path -LiteralPath $DeploymentMarker -PathType Leaf)) {
    throw "Ant finished without creating the expected deployment marker: $DeploymentMarker"
}

Write-Host 'Starting WildFly. Press Ctrl+C in this window to stop the server.' -ForegroundColor Cyan
Write-Host "Local URL: http://localhost:$HttpPort/socobis" -ForegroundColor Green

Push-Location (Join-Path $WildFlyHome 'bin')
try {
    & $Standalone -b 127.0.0.1 "-Djboss.http.port=$HttpPort"
    if ($LASTEXITCODE -ne 0) {
        throw "WildFly stopped with exit code $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}
