$nodeVersion = "6.11.1"
$npmVersion = "5.3.0"
$rootDir = (pwd)
$downloadDir = Join-Path (pwd) "download"

$x64 = [IntPtr]::Size -eq 8
$nodeArch = if ($x64) { "x64" } else { "x86" }
$nodeUrl = "http://nodejs.org/dist/v$nodeVersion/win-$nodeArch/node.exe"
$npmUrl = "https://github.com/npm/npm/archive/v$npmVersion.zip"
$nodeDir = Join-Path $downloadDir "node-v$nodeVersion$nodeArch"

if (![System.IO.Directory]::Exists($nodeDir)) {[System.IO.Directory]::CreateDirectory($nodeDir)}

# Download node
$nodeExe = Join-Path $nodeDir "node.exe"
if (![System.IO.File]::Exists($nodeExe)) {
	Write-Host "Downloading $nodeUrl to $nodeExe"
	$downloader = new-object System.Net.WebClient
	$downloader.DownloadFile($nodeUrl, $nodeExe)
}

# add node to the path
$env:Path += ";$nodeDir"

# Download npm
$npmZip = Join-Path $nodeDir "npm.$npmVersion.zip"
if (![System.IO.File]::Exists($npmZip)) {
	Write-Host "Downloading $npmUrl to $npmZip"
	$downloader = new-object System.Net.WebClient
	$downloader.DownloadFile($npmUrl, $npmZip)
}

# unzip the package
$modulesDir = Join-Path $nodeDir "node_modules"
if (![System.IO.Directory]::Exists($modulesDir)) {[System.IO.Directory]::CreateDirectory($modulesDir)}
$npmDir = Join-Path $modulesDir "npm"

if (![System.IO.Directory]::Exists($npmDir)) {
	Write-Host "Extracting $npmZip to $modulesDir..."
	$shell = new-object -com shell.application
	$zip = $shell.nameSpace($npmZip)
	foreach($item in $zip.items()) {
		$shell.nameSpace($modulesDir).copyHere($item, 1564)
	}
	Rename-Item "$modulesDir/npm-$npmVersion" "npm"
}

$npmCmd = Join-Path $nodeDir "npm.cmd"
if (![System.IO.File]::Exists($npmCmd)) {
	Copy-Item (Join-Path $modulesDir "npm/bin/npm.cmd") $npmCmd
}

# Download yarn
$yarnJs = Join-Path $nodeDir "node_modules/yarn/bin/yarn.js"
if (![System.IO.File]::Exists($yarnJs)) {
	Set-Location $nodeDir
	& $npmCmd install yarn@0.27
	Set-Location $rootDir
}

# Run npm install
& $nodeExe $yarnJs install --scripts-prepend-node-path=true

# Run grunt (pass through args to specify build tasks)
& $nodeExe $yarnJs run --scripts-prepend-node-path=true grunt -- $args
exit $LastExitCode

