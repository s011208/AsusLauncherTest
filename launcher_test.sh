#!/bin/bash

##Error code
ERROR_CODE_LAUNCHER_BUILD_FAILED=-1;
ERROR_CODE_TEST_LAUNCHER_BUILD_FAILED=-2;
ERROR_CODE_UNABLE_TO_INSTALL=-3;
ERROR_CODE_UNABLE_TO_READ_PARSE_RESULT_ADAPTER=-4;

##Source
SOURCE_SQLITE="./AsusLauncherTest/sqlite_utilities.sh";
SOURCE_PARSE_TEST_RESULTS="./AsusLauncherTest/parse_test_results.sh";

debug=true;
syncExternalProjectScriptName="deploy_AsusLauncher_1.4.sh";
targetBranch="AsusLauncher_1.4_beta";
asusLauncherBuildResult="./../asusLauncher_build_result.txt";
testBuildResult="./../asusLauncher_test_build_result.txt";
unitTestResults="./../test_results.txt";
unitTestResultsAdapter="./../test_results_adapter.txt"
apkPath="bin/AsusLauncher-release-unaligned.apk";

sqlitePath="./test_results.db";
sqlitePathWhenInAsusLauncher="./../test_results.db";

function readSources() {
    initSqlite;
    initParser;
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
    sqlite_changePath ${sqlitePathWhenInAsusLauncher};
    IFS=$'\n';
    local rawata=$(cat ${unitTestResultsAdapter});
    local filteredData=();
    for next in $rawata
    do
        filteredData+=("$next");
    done

    local timeStamp="";
    local timeStampId=-1;
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

cd ~;
cd './AsusLauncherTest';
## in ./AsusLauncherTest
readSources;
#syncExternalProjects;

cd './AsusLauncher';
## in ./AsusLauncherTest/AsusLauncher

#syncLauncher;
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
parseTestsResult;
readTestResultAdapter;



echo "666";
