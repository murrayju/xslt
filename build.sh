#!/bin/bash

nodeVersion=5.0.0
downloadDir=`pwd`/download
mkdir -p $downloadDir

if [ `getconf LONG_BIT` == "64" ]; then
	arch=x64
else
	arch=x86
fi
uname=`uname -s`
if [[ $uname =~ ^Darwin* ]]; then
	nodeName=node-v$nodeVersion-darwin-$arch
elif [[ $uname =~ ^Linux* ]]; then
	nodeName=node-v$nodeVersion-linux-$arch
else
	echo Unknown os: $uname
	exit
fi
nodeGz=$nodeName.tar.gz
nodeUrl=http://nodejs.org/dist/v$nodeVersion/$nodeGz
nodeDl=$downloadDir/$nodeGz

if [ ! -f $nodeDl ]; then
	echo Downloading $nodeUrl to $nodeDl
	curl -o $nodeDl $nodeUrl
fi

nodeDir=$downloadDir/$nodeName
export PATH=$nodeDir/bin:$PATH
nodeCmd=$nodeDir/bin/node
npmCmd=$nodeDir/bin/npm
if [ ! -f $npmCmd ]; then
	echo Extracting node gz
	tar xzf $nodeDl -C $downloadDir
fi

cp package.templ.json package.json
cp bower.templ.json bower.json
$npmCmd install

exec $nodeCmd build.js "$@"
