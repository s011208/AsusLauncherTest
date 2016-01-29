#!/bin/bash

OK_PATTERN="OK (";
FAILURE_PATTERN="FAILURES!!!";
FAILURE_TEST_CASE_PATTERN="Failure in ";

TAG_TIME_STAMP="tag_TIME_STAMP";
TAG_TEST_CASE="tag_TEST_CASE";
TAG_TEST_RESULT="tag_TEST_RESULT";
TAG_TEST_VERSION="tag_TEST_VERSION";
TAG_TEST_LAUNCHER_TAG="tag_TEST_LAUNCHER_TAG";

function parser_init() {
    parser_sayHi;
}

function parser_sayHi() {
    debugMessage "hi! parse_test_results imported";
}

function parse_getLastestLauncherTag() {
    echo $(git describe --abbrev=0 --tags);
}

function parse_getLauncherVersionCode() {
    if [ ! -f "AndroidManifest.xml" ]; then
        echo "failed to find AndroidManifest.xml";
    else
        echo $(cat "AndroidManifest.xml" | grep "android:versionCode=" | sed 's/android:versionCode=//g' | sed 's/\"//g' | sed 's/ //g');
    fi;

}

# $1 = test result file
# $2 = output file
function parser_start() {
    debugMessage "start to parse";
    local rawata=$(cat "$1" | grep "com.asus.launcher\|(\|junit\|${FAILURE_TEST_CASE_PATTERN}\|${OK_PATTERN}\|${FAILURE_PATTERN}");
    IFS=$'\n';
    local filteredData=();
    for next in $rawata
    do
        filteredData+=("$next");
    done
    debugMessage "length of filtered data: ${#filteredData[@]}";
    local testCases=();
    local testResults=();
    local previousTestCase="";
    local previousTestResult="";

    local isTestResult=false;
    local isFailureMessage=false;

    for next in ${filteredData[@]}
    do
        #debugMessage "$next";
        if [ -z $(echo "$next" | grep "^com.asus.launcher.") ]; then
            if [ -z $(echo "$next" | grep "${OK_PATTERN}\|${FAILURE_PATTERN}") ]; then
                previousTestResult="$(echo ${previousTestResult}${next})";
            else
                local isOK=$(echo "$next" | grep "${OK_PATTERN}");
                if [ -z $isOK ]; then
                    # failure
                    echo ""  > "/dev/null";
                else
                    # ok
                    echo ""  > "/dev/null";
                fi;
            fi;
        else
            # test cases
            isTestResult=false;
            isFailureMessage=false;
            if [ ! -z $previousTestCase ]; then
                testCases+=("$previousTestCase");
                if [ -z $previousTestResult ]; then
                    testResults+=("OK");
                else
                    testResults+=("$previousTestResult");
                fi;
            fi;
            previousTestCase="$next";
            previousTestResult="";
        fi;
        #echo $isTestCase;
    done


    if [ ! -z $previousTestCase ]; then
        testCases+=("$previousTestCase");
        if [ -z $previousTestResult ]; then
            testResults+=("OK");
        else
            testResults+=("$previousTestResult");
        fi;
    fi;
    debugMessage "testCases length: ${#testCases[@]}";
    debugMessage "testResults length: ${#testResults[@]}";
    rm -f "$2";
    echo ${TAG_TIME_STAMP} >> "$2";
    echo $(date "+%Y/%m/%d %H:%M:%S") >> "$2";
    echo ${TAG_TEST_VERSION} >> "$2";
    echo $(parse_getLauncherVersionCode) >> "$2";
    echo ${TAG_TEST_LAUNCHER_TAG} >> "$2";
    echo $(parse_getLastestLauncherTag) >> "$2";
    for i in $(seq 0 $((${#testCases[@]}-1)))
    do
        echo ${TAG_TEST_CASE} >> "$2";
        echo $(echo "${testCases[$i]}" | sed -e 's/:.*//g') >> "$2";
        echo ${TAG_TEST_RESULT} >> "$2";
        echo "${testResults[$i]}" >> "$2";
    done
    debugMessage "finish parse task";
}

