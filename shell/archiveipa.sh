#!/bin/bash
IBUILD_HOME=`dirname $BASH_SOURCE`


FilePath="../archiveipa"

MoveToPath="../../epos-ipa/"

CurrentPath=`pwd`

# 文件名
ArchiveScheme=$2
Configution=$3
VERSION=$4
Message=$5
BUILD_DATE=`date '+%Y%m%d-%H:%M'`
FinallyFileName="${ArchiveScheme}-${VERSION}-${BUILD_DATE}+$Configution"


echo $CurrentPath

cd  $1

#cd $ArchiveScheme

xcodebuild clean


rm -rf  $FilePath
mkdir  $FilePath

xcodebuild archive -workspace ${ArchiveScheme}.xcworkspace -scheme $ArchiveScheme -configuration $Configution -archivePath "../archiveipa/${ArchiveScheme}.xcarchive"

xcodebuild -exportArchive -archivePath "$FilePath/${ArchiveScheme}.xcarchive" -exportPath $FilePath -exportOptionsPlist  ${CurrentPath}/shell/ExportOptions.plist 

ret=$?


if [ $ret == 0 ]
	then
	pwd
	mv "$FilePath/${ArchiveScheme}.ipa" "$FilePath/${FinallyFileName}.ipa"
	# zip -r "$FilePath/${FinallyFileName}.app.dSYM.zip" "$FilePath/${ArchiveScheme}.xcarchive/dSYMs/${ArchiveScheme}.app.dSYM" 
	echo "打包成功"
else
	echo "打包错误"
	exit
fi



