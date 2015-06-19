$nodeVersion = "0.12.2"
$npmVersion = "2.7.6"
$downloadDir = Join-Path (pwd) "download"

$x64 = [IntPtr]::Size -eq 8
$nodeArch = if ($x64) { "/x64" } else { "" }
$nodeUrl = "http://nodejs.org/dist/v$nodeVersion$nodeArch/node.exe"
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
$npmZip = Join-Path $nodeDir "npm.zip"
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

# Run npm install
Copy-Item (Join-Path (pwd) "package.templ.json") "package.json"
Copy-Item (Join-Path (pwd) "bower.templ.json") "bower.json"
& $npmCmd install

# Run grunt (pass through args to specify build tasks)
& $nodeExe build.js $args
exit $LastExitCode
