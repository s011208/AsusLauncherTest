#!/bin/bash

##Error code
ERROR_CODE_LAUNCHER_BUILD_FAILED=-1;
ERROR_CODE_TEST_LAUNCHER_BUILD_FAILED=-2;
ERROR_CODE_UNABLE_TO_INSTALL=-3;
ERROR_CODE_UNABLE_TO_READ_PARSE_RESULT_ADAPTER=-4;
ERROR_CODE_UNABLE_TO_READ_GIT_LOGS=-5;

##Source
SOURCE_SQLITE="./AsusLauncherTest/sqlite_utilities.sh";
SOURCE_PARSE_TEST_RESULTS="./AsusLauncherTest/parse_test_results.sh";
SOURCE_UTILITIES="./AsusLauncherTest/utilities.sh";
SOURCE_GIT_HELPER="./AsusLauncherTest/git_helper.sh";
SOURCE_DEVICES_INFO_HELPER="./AsusLauncherTest/devices_info_helper.sh";

debug=true;
syncExternalProjectScriptName="deploy_AsusLauncher_1.4.sh";
targetBranch="AsusLauncher_1.4_play";
asusLauncherBuildResult="./../asusLauncher_build_result.txt";
testBuildResult="./../asusLauncher_test_build_result.txt";
unitTestResults="./../test_results.txt";
unitTestResultsAdapter="./../test_results_adapter.txt";
gitLogs="./../git_logs.txt";
adbLogcat="./../test_runners_logcat.txt";
apkPath="bin/AsusLauncher-release-unaligned.apk";

adbLogcatTerminalTitle="adb logcat by testing";

testDeviceId=0;

## TestRunner tags
TAG_CLASS="THRESHOLD_CLASS_TAG";
TAG_METHOD="THRESHOLD_METHOD_TAG";
TAG_VALUE="THRESHOLD_VALUE_TAG";
TAG_EXTRA_MESSAGES="EXTRA_MESSAGES_TAG";


## for django
sqlitePath="./AsusLauncherTest/TestResults/mysite/db.sqlite3";
sqlitePathWhenInAsusLauncher="./.././AsusLauncherTest/TestResults/mysite/db.sqlite3";

## for script only
#sqlitePath="./test_results.db";
#sqlitePathWhenInAsusLauncher="./../test_results.db";

function readSources() {
    initUtilities;
    initSqlite;
    initParser;
    initGitHelper;
	initDevicesInfoHelper;
}

function initDevicesInfoHelper() {
    source "${SOURCE_DEVICES_INFO_HELPER}";
}

function initGitHelper() {
    source "${SOURCE_GIT_HELPER}";
    git_helper_changePath ${sqlitePath};
}

function initUtilities() {
    source "${SOURCE_UTILITIES}";
}

function initParser() {
    source "${SOURCE_PARSE_TEST_RESULTS}";
    parser_init;
}

function initSqlite() {
    source "${SOURCE_SQLITE}";
    sqlite_init ${sqlitePath};
}

function debugMessage() {
    if [ $debug == true ]; then
        echo $1;
    fi;
}

function exitWitherror() {
    if (( $1 -eq ${ERROR_CODE_LAUNCHER_BUILD_FAILED} )); then
        handleErrors "Launcher build failed";
    elif (( $1 -eq ${ERROR_CODE_TEST_LAUNCHER_BUILD_FAILED} )); then
        handleErrors "Test Launcher build failed";
    elif (( $1 -eq ${ERROR_CODE_UNABLE_TO_INSTALL} )); then
        handleErrors "failed to install apk $2"
    elif (( $1 -eq ${ERROR_CODE_UNABLE_TO_READ_PARSE_RESULT_ADAPTER} )); then
        handleErrors "unable to read parse result adapter";
    elif (( $1 -eq ${ERROR_CODE_UNABLE_TO_READ_GIT_LOGS} )); then
        handleErrors "unable to read git logs";
    fi;
    exit 0;
}

## update test columns
function handleErrors() {
    echo "$1";
    sqlite_insertErrorTimeStamp "$(date "+%Y/%m/%d %H:%M:%S")" "$1" $(get_helper_getCurrentBranch) ${testDeviceId};
	sqlite_updateLastedUntestedHash;
}

function installApk() {
    echo "try to install $1";
    for i in {1..5}
    do
        installResult=$(adb install -r "$1" | tail -1);
        if [[ "$installResult" == *"Success"* ]]; then
            echo "$installResult";
            return;
        fi;
    done
    exitWitherror ERROR_CODE_UNABLE_TO_INSTALL $1;
}

function syncExternalProjects() {
    ## sync all external project
    debugMessage "sync all external project with $syncExternalProjectScriptName";
    ./${syncExternalProjectScriptName};
}

function syncLauncher() {
    ## sync AsusLauncher with ${targetBranch}
    debugMessage "git reset --hard HEAD";
    git reset --hard HEAD^;
    debugMessage "git checkout ${targetBranch}";
    git checkout ${targetBranch};
    debugMessage "git pull --rebase";
    git pull --rebase;
}

function buildLauncher() {
    ## build AsusLauncher apk
    debugMessage "start to build AsusLauncher and write result into ${asusLauncherBuildResult}";
    ant clean release > ${asusLauncherBuildResult};
}

function checkBuildLauncherResult() {
    ## check AsusLauncher build result
    asusLauncherBuildResult=$(cat ${asusLauncherBuildResult} | tail -2 | head -1);
    #rm -f ${asusLauncherBuildResult};
    debugMessage "build AsusLauncher finished, result: ${asusLauncherBuildResult}"
    if [ "${asusLauncherBuildResult}" != "BUILD SUCCESSFUL" ]; then
        exitWitherror ERROR_CODE_LAUNCHER_BUILD_FAILED;
    fi;
}

function buildTestLauncher() {
    ## build Tests apk
    ./build_launcher_test.sh d k > ${testBuildResult};
}

function checkBuildTestLauncherResult() {
    ## check AsusLauncher Test build result
    asusLauncherTestBuildResult=$(cat ${testBuildResult} | tail -7 | head -1);
    #rm -f ${testBuildResult};
    debugMessage "build AsusLauncher TEST finished, result: ${asusLauncherTestBuildResult}"
    if [ "${asusLauncherTestBuildResult}" != "BUILD SUCCESSFUL" ]; then
        exitWitherror ERROR_CODE_TEST_LAUNCHER_BUILD_FAILED;
    fi;
}

function installLauncher() {
    debugMessage "uninstall launcher";
    adb uninstall com.asus.launcher;
    debugMessage "install launcher";
    installApk "./${apkPath}"
}

function installTestLauncher() {
    debugMessage "uninstall launcher tests";
    adb uninstall com.asus.launcher.tests;
    debugMessage "install launcher tests";
    installApk "./TestLauncher/${apkPath}"
}

function runAllTests() {
    #rm -f ${unitTestResults};
    debugMessage "start to run tests"
    ./TestLauncher/script/full_test.sh > ${unitTestResults};
}

function parseTestsResult() {
    parser_start ${unitTestResults} ${unitTestResultsAdapter};
}

function readTestResultAdapter() {
    if [ ! -f ${unitTestResultsAdapter} ]; then
        exitWitherror ERROR_CODE_UNABLE_TO_READ_PARSE_RESULT_ADAPTER;
    fi;
    IFS=$'\n';
    local rawata=$(cat ${unitTestResultsAdapter});
    local filteredData=();
    for next in $rawata
    do
        filteredData+=("$next");
    done

    local timeStamp="";
    local timeStampId=-1;
    local version="";
    local lastestTag="";
    local testCase="";
    local testCaseId=-1;
    local testResult="";
    local changeTag=true;
    local nextTag="";
    for next in ${filteredData[@]}
    do
        if [ "${next}" == "${TAG_TIME_STAMP}" ]; then
            nextTag=${TAG_TIME_STAMP};
            #debugMessage "${TAG_TIME_STAMP}";
            changeTag=true;
        elif [ "${next}" == "${TAG_TEST_VERSION}" ]; then
            nextTag=${TAG_TEST_VERSION};
            #debugMessage "${TAG_TEST_VERSION}";
            changeTag=true;
        elif [ "${next}" == "${TAG_TEST_LAUNCHER_TAG}" ]; then
            nextTag=${TAG_TEST_LAUNCHER_TAG};
            #debugMessage "${TAG_TEST_LAUNCHER_TAG}";
            changeTag=true;
        elif [ "${next}" == "${TAG_TEST_CASE}" ]; then
            nextTag=${TAG_TEST_CASE};
            #debugMessage "${TAG_TEST_CASE}";
            changeTag=true;
        elif [ "${next}" == "${TAG_TEST_RESULT}" ]; then
            nextTag=${TAG_TEST_RESULT};
            #debugMessage "${TAG_TEST_RESULT}";
            changeTag=true;
        else
            if [ "${nextTag}" == "${TAG_TIME_STAMP}" ]; then
                timeStamp="${next}";
                sqlite_insertNewTimeStamp "${timeStamp}" "$(git_helper_getCurrentBranch)" "${testDeviceId}";
                timeStampId=$(sqlite_getTimeStampId ${timeStamp});
                debugMessage "timeStamp: ${timeStamp}, id: ${timeStampId}";
            elif [ "${nextTag}" == "${TAG_TEST_VERSION}" ]; then
                version="${next}";
                sqlite_insertTestVersion ${version} ${timeStampId};
                debugMessage "version: ${version}"
            elif [ "${nextTag}" == "${TAG_TEST_LAUNCHER_TAG}" ]; then
                lastestTag="${next}";
                sqlite_insertTestTag ${lastestTag} ${timeStampId};
                debugMessage "lastestTag: ${lastestTag}"
            elif [ "${nextTag}" == "${TAG_TEST_CASE}" ]; then
                testCase="${next}";
                sqlite_insertNewTestcase ${testCase};
                testCaseId=$(sqlite_getTestCaseId ${testCase});
                debugMessage "test case: ${testCase}, id: ${testCaseId}" ;
            elif [ "${nextTag}" == "${TAG_TEST_RESULT}" ]; then
                testResult="$(echo ${next} | sed -e 's/@@@/\r/g')";
                sqlite_insertTestResult ${testCaseId} ${timeStampId} ${testResult};
            fi;
        fi;
    done
}

function parseAndInsertGitLogs() {
    if [ ! -f ${gitLogs} ]; then
        exitWitherror ERROR_CODE_UNABLE_TO_READ_GIT_LOGS;
    fi;
    IFS=$'\n';
    local rawata=$(cat ${gitLogs});
    local filteredData=();
    for next in $rawata
    do
        #echo $next;
        filteredData+=("$next");
    done
	for (( index=${#filteredData[@]}-1 ; index>=0 ; index-- ));
    do
	    data_f=${filteredData[$index]};
	    local change_subject="";
		local change_author="";
		local change_hash="";
		local change_author_email="";
		local counter=0;
        for column in $(echo ${data_f} | sed "s/$git_saperater/\n/g")
        do
			if [ $counter == 0 ]; then
			    change_subject=$column;
				change_subject="$(echo $change_subject | sed "s/'//g")"
				#debugMessage "change_subject: $change_subject";
			elif [ $counter == 1 ]; then
			    change_author=$column;
				#debugMessage "change_author: $change_author";
			elif [ $counter == 2 ]; then
			    change_hash=$column;
				#debugMessage "change_hash: $change_hash";
            elif [ $counter == 3 ]; then
			    change_author_email=$column;
				#debugMessage "change_author_email: $change_author_email";
			fi;
			counter=$(($counter + 1));
        done
		#debugMessage $data_f;
		#debugMessage "s: " $change_subject "a: " $change_author "h: " $change_hash "ae: " $change_author_email
		sqlite_insertGitLog "$change_subject" "$change_author" "$change_hash" "$change_author_email";
    done
}

function resetToRightChange() {
    local last_untested_hash=$(sqlite_get_lastest_untested_hash);
	echo $last_untested_hash;
    git reset --hard $last_untested_hash;
}

function getTestingDeviceInfo() {
    local versionSdk=$(devices_info_helper_getVersionSdk);
	local versionIncremental=$(devices_info_helper_getVersionIncremental);
	local product=$(devices_info_helper_getBuildProduct);
	local cscVersion=$(devices_info_helper_getBuildCscVersion);
	local characteristics=$(devices_info_helper_getBuildCharacteristics);
	local sku=$(devices_info_helper_getBuildSku);
	local deviceId=$(devices_info_helper_getDeviceId);

    if [ -z  $(sqlite_getDeviceInfo ${versionSdk} ${versionIncremental} ${product} ${cscVersion} ${characteristics} ${sku} ${deviceId}) ]; then
	    sqlite_insertDeviceInfo ${versionSdk} ${versionIncremental} ${product} ${cscVersion} ${characteristics} ${sku} ${deviceId};
	fi;
	testDeviceId=$(sqlite_getDeviceInfoId ${versionSdk} ${versionIncremental} ${product} ${cscVersion} ${characteristics} ${sku} ${deviceId});
	debugMessage "testing device id:" ${testDeviceId};
}

function updateTestCasesThreshold() {
    local class='';
	local thresholdMsgs=();

	IFS=$'\n'$'\r';
    local rawata="$(cat ${adbLogcat} | grep "\[THRESHOLD.*\]")";
	for next in $rawata
    do
	    local classRaw="$(echo ${next} | grep "\[${TAG_CLASS}\]")";
		local methodRaw="$(echo ${next} | grep "\[${TAG_METHOD}\]")";
		local valueRaw="$(echo ${next} | grep "\[${TAG_VALUE}\]")";
		if [ ! -z ${classRaw} ]; then
			if [ ${#thresholdMsgs[@]} != 0 ]; then
				local finalMsg='';
				for msg in ${thresholdMsgs[@]}
				do
				    if [ -z "${finalMsg}" ]; then
					    finalMsg="${msg}";
					else
				        finalMsg="$(echo -e "${finalMsg}" \\n "${msg}")";
					fi;
				done
				sqlite_updateTestCaseThreshold "${class}" "${finalMsg}";
			fi;
			class="$(echo ${classRaw} | sed 's/.*]//')";
			thresholdMsgs=();
			#debugMessage ${class};
		elif [ ! -z ${methodRaw} ]; then
			thresholdMsgs+=("$(echo ${methodRaw} | sed 's/.*]//')");
	    elif [ ! -z ${valueRaw} ]; then
		    thresholdMsgs+=("$(echo ${valueRaw} | sed 's/.*]//')");
		fi;
	done
	if [ ${#thresholdMsgs[@]} != 0 ]; then
        local finalMsg='';
        for msg in ${thresholdMsgs[@]}
        do
            finalMsg="$(echo -e "${finalMsg}" \\n "${msg}")";
        done
        sqlite_updateTestCaseThreshold "${class}" "${finalMsg}";
    fi;
}

function insertExtraMessages() {
    local class='';
	local method='';
	local extraMsgs=();
	
	IFS=$'\n'$'\r';
    local rawata="$(cat ${adbLogcat} | grep "\[${TAG_EXTRA_MESSAGES}.*\]\|started:")";
	for next in $rawata
    do
	    local classRaw="$(echo ${next} | grep ": started: ")";
		local methodRaw="${classRaw}";
		local extraMsg="$(echo ${next} | grep "\[${TAG_EXTRA_MESSAGES}\]")";
		if [ ! -z ${classRaw} ]; then
		    if [ ${#extraMsgs[@]} != 0 ]; then
			    local time_id="$(sqlite_getLastTimeStampId)";
				local test_case_id="$(sqlite_getTestCaseId ${class})";
			    local finalMsg='';
				for msg in ${extraMsgs[@]}
				do
				    if [ -z "${finalMsg}" ]; then
					    finalMsg="${msg}";
					else
				        finalMsg="$(echo -e "${finalMsg}" \\n "${msg}")";
					fi;
				done
				sqlite_updateTestResultExtraMessages "${time_id}" "${test_case_id}" "${finalMsg}";
			fi;
			if [ "${class}" !=  "$(echo ${classRaw} | sed 's/.*(//' | sed 's/)//')" ]; then
			    extraMsgs=();
		        class="$(echo ${classRaw} | sed 's/.*(//' | sed 's/)//')";
				debugMessage "class: ${class}";
			fi;
			method="$(echo ${methodRaw} | sed 's/.*started: //' | sed 's/(.*//') :";
			extraMsgs+=(${method});
		elif [ ! -z ${extraMsg} ]; then
		    extraMsgs+=("$(echo ${extraMsg} | sed 's/.*]//')");
			debugMessage "extraMsg: ${extraMsg}";
		fi;
	done
	if [ ${#extraMsgs[@]} != 0 ]; then
        local time_id="$(sqlite_getLastTimeStampId)";
        local test_case_id="$(sqlite_getTestCaseId ${class})";
        local finalMsg='';
        for msg in ${extraMsgs[@]}
        do
            if [ -z "${finalMsg}" ]; then
                finalMsg="${msg}";
            else
                finalMsg="$(echo -e "${finalMsg}" \\n "${msg}")";
            fi;
        done
        sqlite_updateTestResultExtraMessages "${time_id}" "${test_case_id}" "${finalMsg}";
    fi;
}

function parseTestRunnerLogs() {
    updateTestCasesThreshold;
	insertExtraMessages;
}

## main
cd ~;
cd './AsusLauncherTest';
## in ./AsusLauncherTest
readSources;
#syncExternalProjects;

cd './AsusLauncher';
sqlite_changePath ${sqlitePathWhenInAsusLauncher};
## in ./AsusLauncherTest/AsusLauncher

#syncLauncher;

#getTestingDeviceInfo;

## checkout to right commit
#git_helper_syncDatabase $gitLogs;
#parseAndInsertGitLogs;
#resetToRightChange;

#buildLauncher;
#checkBuildLauncherResult;

#buildTestLauncher;
#checkBuildTestLauncherResult;

## install apk
#installLauncher;
#installTestLauncher;

## clear logcat files & cache
#rm -f "${adbLogcat}";
#adb logcat -c;

## open new terminal & log to file
#gnome-terminal -t "${adbLogcatTerminalTitle}" -x sh -c "adb logcat | grep TestRunner > ${adbLogcat};bash";

## run all tests
#runAllTests;

## install wmctrl in advance
## close logcat terminal
#sleep 5000;
#wmctrl -F -c "${adbLogcatTerminalTitle}";

## parse test results
#parseTestsResult;
#readTestResultAdapter;

## parse test thresholds
parseTestRunnerLogs;

#sqlite_updateLastedUntestedHash;
#sqlite_removeOldTimeStamp;

echo "66666666";
