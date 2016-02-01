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

debug=true;
syncExternalProjectScriptName="deploy_AsusLauncher_1.4.sh";
targetBranch="AsusLauncher_1.4_play";
asusLauncherBuildResult="./../asusLauncher_build_result.txt";
testBuildResult="./../asusLauncher_test_build_result.txt";
unitTestResults="./../test_results.txt";
unitTestResultsAdapter="./../test_results_adapter.txt"
git_logs="./../git_logs.txt"
apkPath="bin/AsusLauncher-release-unaligned.apk";

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
    if [ $1 == ERROR_CODE_LAUNCHER_BUILD_FAILED ]; then
        echo "Launcher build failed";
    elif [ $1 == ERROR_CODE_TEST_LAUNCHER_BUILD_FAILED ]; then
        echo "Test Launcher build failed";
    elif [ $1 == ERROR_CODE_UNABLE_TO_INSTALL ]; then
        echo "failed to install apk $2"
    elif [ $1 == ERROR_CODE_UNABLE_TO_READ_PARSE_RESULT_ADAPTER ]; then
        echo "unable to read parse result adapter";
    elif [ $1 == ERROR_CODE_UNABLE_TO_READ_GIT_LOGS ]; then
        echo "unable to read git logs";
    fi;
    exit 0;
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
                sqlite_insertNewTimeStamp ${timeStamp};
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

function parse_and_insert_git_logs() {
    if [ ! -f ${git_logs} ]; then
        exitWitherror ERROR_CODE_UNABLE_TO_READ_GIT_LOGS;
    fi;
    IFS=$'\n';
    local rawata=$(cat ${git_logs});
    local filteredData=();
    for next in $rawata
    do
        #echo $next;
        filteredData+=("$next");
    done
    for data in ${filteredData[@]}
    do
	    local change_subject="";
		local change_author="";
		local change_hash="";
		local change_author_email="";
		local counter=0;
        for column in $(echo ${data} | sed "s/$git_saperater/\n/g")
        do
			if [ $counter == 0 ]; then
			    change_subject=$column;
			elif [ $counter == 1 ]; then
			    change_author=$column;
			elif [ $counter == 2 ]; then
			    change_hash=$column;
            elif [ $counter == 3 ]; then
			    change_author_email=$column;
			fi;
			counter=$(($counter + 1));
        done
		#debugMessage "s: " $change_subject "a: " $change_author "h: " $change_hash "ae: " $change_author_email
		sqlite_insert_git_log $change_subject $change_author $change_hash $change_author_email;
    done
}

cd ~;
cd './AsusLauncherTest';
## in ./AsusLauncherTest
readSources;
#syncExternalProjects;

cd './AsusLauncher';
sqlite_changePath ${sqlitePathWhenInAsusLauncher};
## in ./AsusLauncherTest/AsusLauncher

#syncLauncher;
git_helper_syncDatabase $git_logs;
parse_and_insert_git_logs;
#buildLauncher;
#checkBuildLauncherResult;

#buildTestLauncher;
#checkBuildTestLauncherResult;

## install apk
#installLauncher;
#installTestLauncher;

## run all tests
#runAllTests;

## parse test results
#parseTestsResult;
#readTestResultAdapter;
#sqlite_removeOldTimeStamp

echo "666";
