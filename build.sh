#!/bin/bash

nodeVersion=8.2.1
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

yarnUrl=https://yarnpkg.com/latest.tar.gz
yarnDl=$downloadDir/yarn.tar.gz

if [ ! -f $yarnDl ]; then
	echo Downloading $yarnUrl to $yarnDl
	curl -L -o $yarnDl $yarnUrl
fi

yarnDir=$downloadDir/yarn
mkdir -p $yarnDir
export PATH=$yarnDir/dist/bin:$PATH
yarnJs=$yarnDir/dist/bin/yarn.js
if [ ! -f $yarnJs ]; then
	echo Extracting yarn gz
	tar xzf $yarnDl -C $yarnDir/
fi

cp package.templ.json package.json

$nodeCmd $yarnJs install --scripts-prepend-node-path=true

exec $nodeCmd $yarnJs run --scripts-prepend-node-path=true grunt -- "$@"
