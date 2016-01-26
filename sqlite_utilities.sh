#!/bin/bash

TABLE_TESTCASES="test_cases";
COLUMN_TESTCASES_NAME="test_case";

TABLE_TESTTIME="test_times";
COLUMN_TESTTIME_TIME="test_time";

TABLE_TESTRESULTS="test_results";
COLUMN_TESTCASES_ID="test_case_id";
COLUMN_TESTTIME_ID="test_time_id";
COLUMN_TESTRESULTS_RESULTS="test_result";

sqlite_path="";

testCases=();

function sqlite_init() {
    sqlite_create "$1";
    sqlite_sayHi;
    sqlite_showAllTestCasesSize;
    sqlite_showAllTestCases;
}

function sqlite_sayHi() {
    debugMessage "hi! sqlite_utilities imported";
}

function sqlite_changePath() {
    sqlite_path="$1";
}

function sqlite_create() {
    sqlite_changePath "$1";
    # create table testcases
    sqlite3 "$sqlite_path" "CREATE TABLE IF NOT EXISTS ${TABLE_TESTCASES} (_id INTEGER PRIMARY KEY,${COLUMN_TESTCASES_NAME} TEXT NOT NULL);";
    sqlite3 "$sqlite_path" "CREATE TABLE IF NOT EXISTS ${TABLE_TESTTIME} (_id INTEGER PRIMARY KEY,${COLUMN_TESTTIME_TIME} TEXT NOT NULL);";
    sqlite3 "$sqlite_path" "CREATE TABLE IF NOT EXISTS ${TABLE_TESTRESULTS} (_id INTEGER PRIMARY KEY,${COLUMN_TESTCASES_ID} INTEGER NOT NULL,${COLUMN_TESTTIME_ID} INTEGER NOT NULL,${COLUMN_TESTRESULTS_RESULTS} TEXT NOT NULL);";
    sqlite_getAllTestCases;
}

function sqlite_getAllTestCases() {
    local query=$(sqlite3 "$sqlite_path" "select ${COLUMN_TESTCASES_NAME} from ${TABLE_TESTCASES};");
    readarray -t testCases <<<"$query"
}

function sqlite_showAllTestCasesSize() {
    debugMessage "number of test cases: ${#testCases[@]}";
}

function sqlite_showAllTestCases() {
    debugMessage "test cases: ${testCases[@]}";
}

function sqlite_insertNewTestcase() {
    found=false;
    for item in "${testCases[@]}"; do
        if [ "$item" == "$1" ]; then
            found=true;
            break;
        fi;
    done
    debugMessage "found: ${found}, case: $1";
    if [ $found == false ]; then
        sqlite3 "$sqlite_path" "insert into ${TABLE_TESTCASES} ('${COLUMN_TESTCASES_NAME}') values ('$1');";
        testCases+=($1);
    fi;
}

function sqlite_getTestCaseId() {
    sqlite3 "$sqlite_path" "select _id from ${TABLE_TESTCASES} where ${COLUMN_TESTCASES_NAME}='$1'";
}

function sqlite_insertNewTimeStamp() {
    sqlite3 "$sqlite_path" "insert into ${TABLE_TESTTIME} ('${COLUMN_TESTTIME_TIME}') values ('$1');";
}

function sqlite_getTimeStampId() {
    sqlite3 "$sqlite_path" "select _id from ${TABLE_TESTTIME} where ${COLUMN_TESTTIME_TIME}='$1'";
}

function sqlite_insertTestResult() {
    sqlite3 "$sqlite_path" "insert into ${TABLE_TESTRESULTS} ('${COLUMN_TESTCASES_ID}','${COLUMN_TESTTIME_ID}','${COLUMN_TESTRESULTS_RESULTS}') values ('$1', '$2', '$3');";
}


