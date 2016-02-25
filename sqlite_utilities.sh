#!/bin/bash

TABLE_TESTCASES="tests_test_cases";
COLUMN_TESTCASES_NAME="test_case";
COLUMN_TESTCASES_THRESHOLD="test_threshold";
COLUMN_TESTCASES_THRESHOLD_VALUE="test_threshold_value";

TABLE_TEST_THRESHOLD="tests_test_threshold";
COLUMN_TEST_THRESHOLD_TESTCASE_ID="test_case_id";
COLUMN_TEST_THRESHOLD_BRANCH="test_branch";
COLUMN_TEST_THRESHOLD_DISPLAY_ORDER="test_display_order";
COLUMN_TEST_THRESHOLD_NAME="test_threshold_name";
COLUMN_TEST_THRESHOLD_VALUE="test_threshold_value";
COLUMN_TEST_THRESHOLD_METHOD_NAME="test_method_name";

TABLE_TESTTIME="tests_test_times";
COLUMN_TESTTIME_TIME="test_time";
COLUMN_TESTTIME_TEST_DONE="test_done";
COLUME_GIT_LOG_ID="test_git_log_id";
COLUMN_TESTTIME_BRANCH="test_branch";
COLUMN_TEST_DEVICE_INFO_ID="test_device_info_id";
COLUMN_TESTTIME_NUMBER_OF_TEST_TIME="number_of_test_time";

TABLE_TESTVERSION="tests_test_versions";
COLUMN_TESTVERSION_VERSION="test_version";

TABLE_LAUNCHERTAG="tests_test_tags";
COLUMN_LAUNCHERTAG_TAG="test_tag";

TABLE_TESTRESULTS="tests_test_results";
COLUMN_TESTCASES_ID="test_case_id";
COLUMN_TESTTIME_ID="test_time_id";
COLUMN_TESTRESULTS_RESULTS="test_result";
COLUMN_TESTRESULTS_EXTRA_MESSAGES="test_extra_msgs";

TABLE_GIT_LOG="tests_test_git_log";
COLUMN_GIT_LOG_SUBJECT="git_subject";
COLUMN_GIT_LOG_AUTHOR_NAME="git_author_name";
COLUMN_GIT_LOG_AUTHOR_EMAIL="git_author_email";
COLUMN_GIT_LOG_HASH="git_hash_code";
COLUMN_GIT_LOG_TESTED="git_tested";
COLUMN_GIT_LOG_BRANCH="git_branch";

TABLE_DEVICE_INFO="tests_test_device_info";
COLUMN_DEVICE_INFO_VERSION_SDK="version_sdk";
COLUMN_DEVICE_INFO_VERSION_INCREMENTAL="version_incremental";
COLUMN_DEVICE_INFO_PRODUCT="product";
COLUMN_DEVICE_INFO_CSC_VERSION="csc_version";
COLUMN_DEVICE_INFO_CHARACRISTICS="characristics";
COLUMN_DEVICE_INFO_SKU="sku";
COLUMN_DEVICE_INFO_DEVICE_ID="device_id";

TABLE_EXTRA_MESSAGES="tests_test_extra_messages";
COLUMN_EXTRA_MESSAGES_TESTCASE_ID="test_case_id";
COLUMN_EXTRA_MESSAGES_TESTTIME_ID="test_time_id";
COLUMN_EXTRA_MESSAGES_TEST_MESSAGE_NAME="test_message_name";
COLUMN_EXTRA_MESSAGES_TEST_MESSAGE_VALUE="test_message_value";
COLUMN_EXTRA_MESSAGES_TEST_EXTRA_MESSAGES="test_message_extra_messages";
COLUMN_EXTRA_MESSAGES_METHOD_NAME="test_method_name";

COLUMN_ID="id";

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
	sqlite3 "$sqlite_path" "CREATE TABLE IF NOT EXISTS ${TABLE_TEST_THRESHOLD} (${COLUMN_ID} INTEGER PRIMARY KEY,${COLUMN_TEST_THRESHOLD_TESTCASE_ID} INTEGER NOT NULL,${COLUMN_TEST_THRESHOLD_BRANCH} TEXT NOT NULL DEFAULT '',${COLUMN_TEST_THRESHOLD_DISPLAY_ORDER} INTEGER NOT NULL DEFAULT 0, ${COLUMN_TEST_THRESHOLD_NAME} TEXT, ${COLUMN_TEST_THRESHOLD_VALUE} INTEGER, ${COLUMN_TEST_THRESHOLD_METHOD_NAME} TEXT);";
    sqlite3 "$sqlite_path" "CREATE TABLE IF NOT EXISTS ${TABLE_TESTCASES} (${COLUMN_ID} INTEGER PRIMARY KEY,${COLUMN_TESTCASES_NAME} TEXT NOT NULL,${COLUMN_TESTCASES_THRESHOLD} TEXT NOT NULL DEFAULT '',${COLUMN_TESTCASES_THRESHOLD_VALUE} INTEGER NOT NULL DEFAULT -1);";
    sqlite3 "$sqlite_path" "CREATE TABLE IF NOT EXISTS ${TABLE_TESTTIME} (${COLUMN_ID} INTEGER PRIMARY KEY,${COLUMN_TESTTIME_TIME} TEXT NOT NULL, ${COLUME_GIT_LOG_ID} INTEGER NOT NULL DEFAULT -1, ${COLUMN_TESTTIME_TEST_DONE} TEXT NOT NULL DEFAULT 'False', ${COLUMN_TESTTIME_BRANCH} TEXT DEFAULT '', ${COLUMN_TEST_DEVICE_INFO_ID} INTEGER NOT NULL DEFAULT -1, ${COLUMN_TESTTIME_NUMBER_OF_TEST_TIME}  INTEGER NOT NULL DEFAULT 1);";
    sqlite3 "$sqlite_path" "CREATE TABLE IF NOT EXISTS ${TABLE_TESTVERSION} (${COLUMN_ID} INTEGER PRIMARY KEY,${COLUMN_TESTVERSION_VERSION} TEXT NOT NULL, ${COLUMN_TESTTIME_ID} INTEGER NOT NULL);";
    sqlite3 "$sqlite_path" "CREATE TABLE IF NOT EXISTS ${TABLE_LAUNCHERTAG} (${COLUMN_ID} INTEGER PRIMARY KEY,${COLUMN_LAUNCHERTAG_TAG} TEXT NOT NULL, ${COLUMN_TESTTIME_ID} INTEGER NOT NULL);";
    sqlite3 "$sqlite_path" "CREATE TABLE IF NOT EXISTS ${TABLE_TESTRESULTS} (${COLUMN_ID} INTEGER PRIMARY KEY,${COLUMN_TESTCASES_ID} INTEGER NOT NULL,${COLUMN_TESTTIME_ID} INTEGER NOT NULL,${COLUMN_TESTRESULTS_RESULTS} TEXT NOT NULL,${COLUMN_TESTRESULTS_EXTRA_MESSAGES} TEXT NOT NULL DEFAULT '');";
    sqlite3 "$sqlite_path" "CREATE TABLE IF NOT EXISTS ${TABLE_GIT_LOG} (${COLUMN_ID} INTEGER PRIMARY KEY, ${COLUMN_GIT_LOG_SUBJECT} TEXT NOT NULL, ${COLUMN_GIT_LOG_AUTHOR_NAME} TEXT NOT NULL, ${COLUMN_GIT_LOG_AUTHOR_EMAIL} TEXT NOT NULL, ${COLUMN_GIT_LOG_HASH} TEXT NOT NULL, ${COLUMN_GIT_LOG_TESTED} TEXT NOT NULL DEFAULT 'False', ${COLUMN_GIT_LOG_BRANCH} TEXT DEFAULT '');";
    sqlite3 "$sqlite_path" "CREATE TABLE IF NOT EXISTS ${TABLE_DEVICE_INFO} (${COLUMN_DEVICE_INFO_VERSION_SDK} TEXT NOT NULL, ${COLUMN_DEVICE_INFO_VERSION_INCREMENTAL} TEXT NOT NULL, ${COLUMN_DEVICE_INFO_PRODUCT} TEXT NOT NULL, ${COLUMN_DEVICE_INFO_CSC_VERSION} TEXT NOT NULL, ${COLUMN_DEVICE_INFO_CHARACRISTICS} TEXT NOT NULL, ${COLUMN_DEVICE_INFO_SKU} TEXT NOT NULL, ${COLUMN_DEVICE_INFO_DEVICE_ID} TEXT NOT NULL);";
	sqlite3 "$sqlite_path" "CREATE TABLE IF NOT EXISTS ${TABLE_EXTRA_MESSAGES} (${COLUMN_ID} INTEGER PRIMARY KEY,${COLUMN_EXTRA_MESSAGES_TESTCASE_ID} INTEGER NOT NULL,${COLUMN_EXTRA_MESSAGES_TESTTIME_ID} INTEGER NOT NULL,${COLUMN_EXTRA_MESSAGES_TEST_MESSAGE_NAME} TEXT NOT NULL DEFAULT '', ${COLUMN_EXTRA_MESSAGES_TEST_MESSAGE_VALUE} INTEGER NOT NULL DEFAULT -1,${COLUMN_EXTRA_MESSAGES_TEST_EXTRA_MESSAGES} TEXT NOT NULL DEFAULT '',${COLUMN_EXTRA_MESSAGES_METHOD_NAME} TEXT);";
    sqlite_getAllTestCases;
}

function sqlite_getAllTestCases() {
    local query=$(sqlite3 "$sqlite_path" "select ${COLUMN_TESTCASES_NAME} from ${TABLE_TESTCASES};");
    if [ ${ENV_MAC} == true ]; then
        echo "start to print";
        IFS=$'\n';
        for next in ${query}
        do
            testCases+=("${next}");
        done
    else
        readarray -t testCases <<<"$query"
    fi;
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

## $1=test_case_name
function sqlite_getTestCaseId() {
    sqlite3 "$sqlite_path" "select ${COLUMN_ID} from ${TABLE_TESTCASES} where ${COLUMN_TESTCASES_NAME}='$1'";
}

#find the same data in table ${TABLE_TESTTIME} with value ${COLUME_GIT_LOG_ID} & ${COLUMN_TESTTIME_BRANCH}
function sqlite_getDuplicatedTests() {
    sqlite3 "$sqlite_path" "select id, ${COLUME_GIT_LOG_ID}, ${COLUMN_TESTTIME_BRANCH}, ${COLUMN_TESTTIME_NUMBER_OF_TEST_TIME} from ${TABLE_TESTTIME} where ${COLUME_GIT_LOG_ID} in (select ${COLUME_GIT_LOG_ID} from ${TABLE_TESTTIME} group by ${COLUME_GIT_LOG_ID} having count(id)>1) order by id desc";
}

function sqlite_getDataFromTestExtraMessagesByTimeId() {
    sqlite3 "$sqlite_path" "select id, ${COLUMN_EXTRA_MESSAGES_TESTCASE_ID}, ${COLUMN_EXTRA_MESSAGES_TESTTIME_ID}, ${COLUMN_EXTRA_MESSAGES_TEST_MESSAGE_NAME}, ${COLUMN_EXTRA_MESSAGES_TEST_MESSAGE_VALUE}, ${COLUMN_EXTRA_MESSAGES_TEST_EXTRA_MESSAGES}, ${COLUMN_EXTRA_MESSAGES_METHOD_NAME} from ${TABLE_EXTRA_MESSAGES} where ${COLUMN_EXTRA_MESSAGES_TESTTIME_ID}=$1"; 
}

## $1=test_case_id, $2=test_time_id, $3=test_message_name, $4=test_method_name
function sqlite_getTestValueFromExtraMessagesByTimeId() {
    sqlite3 "$sqlite_path" "select ${COLUMN_EXTRA_MESSAGES_TEST_MESSAGE_VALUE} from ${TABLE_EXTRA_MESSAGES} where ${COLUMN_EXTRA_MESSAGES_TESTCASE_ID}=$1 and ${COLUMN_EXTRA_MESSAGES_TESTTIME_ID}=$2 and ${COLUMN_EXTRA_MESSAGES_TEST_MESSAGE_NAME}='$3' and ${COLUMN_EXTRA_MESSAGES_METHOD_NAME}='$4'";
}

## $1=id, $2=newValue
function sqlite_updateTestValueById() {
    sqlite3 "$sqlite_path" "update ${TABLE_EXTRA_MESSAGES} set ${COLUMN_EXTRA_MESSAGES_TEST_MESSAGE_VALUE}=$2 where id=$1";
}

## $1=test_time_id
function sqlite_getNumberOfTestTimeByTestTimeId() {
    sqlite3 "$sqlite_path" "select ${COLUMN_TESTTIME_NUMBER_OF_TEST_TIME} from ${TABLE_TESTTIME} where id=$1";
}

## $1=id, $2=git_log_id, $3=test_branch, $4=number_of_test_time
function sqlite_combineDataRowsWithTheDuplicatedTests() {
    local duplicatedTestTimeId=$(sqlite3 "$sqlite_path" "select id from ${TABLE_TESTTIME} where id!=$1 and ${COLUME_GIT_LOG_ID}=$2 and ${COLUMN_TESTTIME_BRANCH}='$3' order by id desc limit 1");
	if [ ! -z "${duplicatedTestTimeId}" ]; then
	    echo "duplicatedTestTimeId: ${duplicatedTestTimeId}";
		local numberOfDuplicatedTestTime="$(sqlite_getNumberOfTestTimeByTestTimeId ${duplicatedTestTimeId})";
		local lastestData=$(sqlite_getDataFromTestExtraMessagesByTimeId $1);
		local lastestDataArray=();
		IFS=$'\n'$'\r';
		for row in "${lastestData}"
		do
		    lastestDataArray+=("${row}");
		done
		for row in ${lastestDataArray[@]}
		do
		    IFS='|';
			rowsData=();
			for column in ${row};
			do
			    rowsData+=("${column}");
			done
			local id=${rowsData[0]};
			local testCaseId=${rowsData[1]};
			local testTimeId=${rowsData[2]};
			local testMsgName=${rowsData[3]};
			local testMsgValue=${rowsData[4]};
			local testMsgExtraMsgs=${rowsData[5]};
			local testMethodName=${rowsData[6]};
			local newTestMsgValue=${testMsgValue};
			# find value of $duplicatedTestTimeId
			echo "select ${COLUMN_EXTRA_MESSAGES_TEST_MESSAGE_VALUE} from ${TABLE_EXTRA_MESSAGES} where ${COLUMN_EXTRA_MESSAGES_TESTCASE_ID}=${testCaseId} and ${COLUMN_EXTRA_MESSAGES_TESTTIME_ID}=${duplicatedTestTimeId} and ${COLUMN_EXTRA_MESSAGES_TEST_MESSAGE_NAME}='${testMsgName}' and ${COLUMN_EXTRA_MESSAGES_METHOD_NAME}='${testMethodName}'";
			local valueOfDuplicatedTest=$(sqlite_getTestValueFromExtraMessagesByTimeId ${testCaseId} ${duplicatedTestTimeId} "${testMsgName}" "${testMethodName}");
			#echo "valueOfDuplicatedTest: ${valueOfDuplicatedTest}";
			if [ $(echo ${valueOfDuplicatedTest} | wc -l) -eq 1 ]; then
			    valueOfDuplicatedTest="$(echo ${valueOfDuplicatedTest} | sed 's/[^0-9]*//g')";
				#echo "re-format: ${valueOfDuplicatedTest}";
			fi;
			#echo "line number: " $(echo ${valueOfDuplicatedTest} | wc -l);
			#echo "char count: " $(echo ${valueOfDuplicatedTest} | wc -m);
			#echo "word count: " $(echo ${valueOfDuplicatedTest} | wc -w);
			if [ -z "${valueOfDuplicatedTest}" -o "${#valueOfDuplicatedTest}" == 0 ]; then
			    newTestMsgValue=${testMsgValue};
			elif [ ${valueOfDuplicatedTest} -le -1 ]; then
			     newTestMsgValue=${testMsgValue};
			else
			    #echo "find new ${testMsgValue}, $4, ${valueOfDuplicatedTest}";
			    newTestMsgValue=$(((${testMsgValue}*$4+${valueOfDuplicatedTest})/($4+1)));
			fi;
			sqlite_updateTestValueById ${id} ${newTestMsgValue};
			#echo ${id}: ${newTestMsgValue};
		done
		sqlite3 "$sqlite_path" "delete from ${TABLE_EXTRA_MESSAGES} where ${COLUMN_EXTRA_MESSAGES_TESTTIME_ID}=${duplicatedTestTimeId}";
		sqlite3 "$sqlite_path" "delete from ${TABLE_TESTTIME} where id=${duplicatedTestTimeId}"
		sqlite3 "$sqlite_path" "update ${TABLE_TESTTIME} set ${COLUMN_TESTTIME_NUMBER_OF_TEST_TIME}=${COLUMN_TESTTIME_NUMBER_OF_TEST_TIME}+${numberOfDuplicatedTestTime} where id=$1";
		debugMessage "merge ${duplicatedTestTimeId} to $1 completed"
	fi;
}

function sqlite_computeAverageTimeOfTheDuplicatedTests() {
	local duplicatedItems=$(sqlite_getDuplicatedTests);
	while [ ! -z "${duplicatedItems}" ];
	do
		IFS=$'\n'$'\r';
		for row in ${duplicatedItems}
		do
			IFS='|';
			local columns=();
			for column in ${row}
			do
			    #echo "${column}";
				columns+=("${column}");
			done
			#echo "size: ${#columns[@]}";
			local id=${columns[0]};
			local gitLogId=${columns[1]};
			local branchName=${columns[2]};
			local numberOfTestTime=${columns[3]};
			#echo "id: ${id}";
			sqlite_combineDataRowsWithTheDuplicatedTests ${id} ${gitLogId} "${branchName}" ${numberOfTestTime};
			break;
		done
		duplicatedItems=$(sqlite_getDuplicatedTests);
	done
}

## $1=test_case, $2=threshold
function sqlite_updateTestCaseThreshold() {
    if [ -z "$1" -o -z "$2" ]; then
	    return;
	fi;
    sqlite3 "$sqlite_path" "update ${TABLE_TESTCASES} set ${COLUMN_TESTCASES_THRESHOLD}='$2' where ${COLUMN_TESTCASES_NAME}='$1'"
	test_case_id=$(sqlite_getTestCaseId $1);
	#debugMessage "$1 ${test_case_id}";
}

## $1=branch
function sqlite_removeOldThreshold() {
    sqlite3 "$sqlite_path" "delete from ${TABLE_TEST_THRESHOLD} where ${COLUMN_TEST_THRESHOLD_BRANCH}='$1'";
}

## $1=test_case_name, $2=branch $3=display_order, $4=threshold_name, $5=threshold_value, $6=method_name
function sqlite_updateThreshold() {
    #debugMessage "$1, $2, $3, $4, $5, $6";
    if [ -z "$1" -o -z "$2" -o -z "$3" -o -z "$4" -o -z "$5" -o -z "$6" ]; then
	    return;
	fi;
	test_case_id=$(sqlite_getTestCaseId $1);
	
	if [ -z $(sqlite_queryThreshold ${test_case_id} $2 $6 $4) ]; then
	    ##insert
		sqlite3 "$sqlite_path" "insert into ${TABLE_TEST_THRESHOLD} (${COLUMN_TEST_THRESHOLD_TESTCASE_ID},${COLUMN_TEST_THRESHOLD_BRANCH},${COLUMN_TEST_THRESHOLD_DISPLAY_ORDER},${COLUMN_TEST_THRESHOLD_NAME}, ${COLUMN_TEST_THRESHOLD_VALUE}, ${COLUMN_TEST_THRESHOLD_METHOD_NAME}) values (${test_case_id}, '$2', $3, '$4', $5, '$6')";
	else
	    ##update
		sqlite3 "$sqlite_path" "update ${TABLE_TEST_THRESHOLD} set ${COLUMN_TEST_THRESHOLD_VALUE}=$5, ${COLUMN_TEST_THRESHOLD_DISPLAY_ORDER}=$3 where ${COLUMN_TEST_THRESHOLD_TESTCASE_ID}=${test_case_id} and ${COLUMN_TEST_THRESHOLD_BRANCH}='$2' and ${COLUMN_TEST_THRESHOLD_NAME}='$4' and ${COLUMN_TEST_THRESHOLD_METHOD_NAME}='$6'";
	fi;
}

## $1=test_case_id, $2=test_time_id, $3=test_message_name, $4=test_message_value, $5=test_message_extra_messages, $6=test_method_name
function sqlite_insertTestExtraMessages() {
    #debugMessage "$1, $2, $3, $4, $5, $6";
	if [ -z "$1" -o -z "$2" -o -z "$3" -o -z "$4" -o -z "$5" -o -z "$6" ]; then
	    return;
	fi;
	sqlite3 "$sqlite_path" "insert into ${TABLE_EXTRA_MESSAGES} (${COLUMN_EXTRA_MESSAGES_TESTCASE_ID}, ${COLUMN_EXTRA_MESSAGES_TESTTIME_ID}	, ${COLUMN_EXTRA_MESSAGES_TEST_MESSAGE_NAME}, ${COLUMN_EXTRA_MESSAGES_TEST_MESSAGE_VALUE}, ${COLUMN_EXTRA_MESSAGES_TEST_EXTRA_MESSAGES}, ${COLUMN_EXTRA_MESSAGES_METHOD_NAME}) values ($1, $2, '$3', $4, '$5', '$6')";
}

## $1=COLUMN_TEST_THRESHOLD_TESTCASE_ID, $2=COLUMN_TEST_THRESHOLD_BRANCH, $3=COLUMN_TEST_THRESHOLD_METHOD_NAME, $4=COLUMN_TEST_THRESHOLD_NAME
function sqlite_queryThreshold() {
    sqlite3 "$sqlite_path" "select ${COLUMN_ID} from ${TABLE_TEST_THRESHOLD} where ${COLUMN_TEST_THRESHOLD_TESTCASE_ID}=$1 and ${COLUMN_TEST_THRESHOLD_BRANCH}='$2' and ${COLUMN_TEST_THRESHOLD_METHOD_NAME}='$3' and ${COLUMN_TEST_THRESHOLD_NAME}='$4'";
}

## $1=test time, $2=error reason, $3=branch name, $4=device id
function sqlite_insertErrorTimeStamp() {
    local unTestedId=$(sqlite_getLastestUntestedId "$3");
	if [ -z ${unTestedId} ]; then
	    unTestedId=$(sqlite_getLastId "$3");
	fi;
	if [ -z "$1" -o -z "$2" -o -z "$3" -o -z "$4" ]; then
	    return;
	fi;
	#debugMessage "sqlite_insertNewTimeStamp: ${unTestedId}";
    sqlite3 "$sqlite_path" "insert into ${TABLE_TESTTIME} ('${COLUMN_TESTTIME_TIME}','${COLUME_GIT_LOG_ID}','${COLUMN_TESTTIME_TEST_DONE}','${COLUMN_TESTTIME_BRANCH}', '${COLUMN_TEST_DEVICE_INFO_ID}', '${COLUMN_TESTTIME_NUMBER_OF_TEST_TIME}') values ('$1',($unTestedId),'$2','$3','$4', 0);";
}

## $1=test time, $2=branch name, $3=device id
function sqlite_insertNewTimeStamp() {
    local unTestedId=$(sqlite_getLastestUntestedId "$2");
	if [ -z ${unTestedId} ]; then
	    unTestedId=$(sqlite_getLastId "$2");
	fi;
	if [ -z "$1" -o -z "$2" -o -z "$3" ]; then
	    return;
	fi;
	#debugMessage "sqlite_insertNewTimeStamp: ${unTestedId}";
    sqlite3 "$sqlite_path" "insert into ${TABLE_TESTTIME} ('${COLUMN_TESTTIME_TIME}','${COLUME_GIT_LOG_ID}','${COLUMN_TESTTIME_TEST_DONE}','${COLUMN_TESTTIME_BRANCH}', '${COLUMN_TEST_DEVICE_INFO_ID}', '${COLUMN_TESTTIME_NUMBER_OF_TEST_TIME}') values ('$1',($unTestedId),'Done','$2','$3', 1);";
}

function sqlite_getTimeStampId() {
    sqlite3 "$sqlite_path" "select ${COLUMN_ID} from ${TABLE_TESTTIME} where ${COLUMN_TESTTIME_TIME}='$1'";
}

function sqlite_getLastTimeStampId() {
    sqlite3 "$sqlite_path" "select ${COLUMN_ID} from ${TABLE_TESTTIME} order by id desc limit 1";
}

## $1=test_time_id, $2=test_case_id, $3=extra_msg
function sqlite_updateTestResultExtraMessages() {
    if [ -z "$1" -o -z "$2" ]; then
	    return;
	fi;
    sqlite3 "$sqlite_path" "update ${TABLE_TESTRESULTS} set ${COLUMN_TESTRESULTS_EXTRA_MESSAGES}='$3' where ${COLUMN_TESTTIME_ID}=$1 and ${COLUMN_TESTCASES_ID}=$2";
}


function sqlite_insertTestResult() {
    sqlite3 "$sqlite_path" "insert into ${TABLE_TESTRESULTS} ('${COLUMN_TESTCASES_ID}','${COLUMN_TESTTIME_ID}','${COLUMN_TESTRESULTS_RESULTS}') values ('$1', '$2', '$3');";
}

## with $1=test_time_id
function sqlite_getTestVersion() {
    if [ -z "$1" ]; then
	    return;
	fi;
    sqlite3 "$sqlite_path" "select ${COLUMN_TESTVERSION_VERSION} from ${TABLE_TESTVERSION} where ${COLUMN_TESTTIME_ID}='$1'";
}

## with $1=test_version, $2=test_time_id
function sqlite_insertTestVersion() {
    if [ -z "$1" -o -z "$2" ]; then
	    return;
	fi;
    sqlite3 "$sqlite_path" "insert into ${TABLE_TESTVERSION} ('${COLUMN_TESTVERSION_VERSION}','${COLUMN_TESTTIME_ID}') values ('$1', '$2');";
}

## with $1=test_time_id
function sqlite_getTestTag() {
    if [ -z "$1" ]; then
	    return;
	fi;
    sqlite3 "$sqlite_path" "select ${COLUMN_LAUNCHERTAG_TAG} from ${TABLE_LAUNCHERTAG} where ${COLUMN_TESTTIME_ID}='$1'";
}

## with $1=test_tag, $2=test_time_id
function sqlite_insertTestTag() {
    if [ -z "$1" -o -z "$2" ]; then
	    return;
	fi;
    sqlite3 "$sqlite_path" "insert into ${TABLE_LAUNCHERTAG} ('${COLUMN_LAUNCHERTAG_TAG}','${COLUMN_TESTTIME_ID}') values ('$1', '$2');";
}

## $1=branch_name
## update tests_test_git_log set git_tested='True' where git_hash_code in (select git_hash_code from tests_test_git_log where git_tested='False' order by id limit 1) and branch name = branch_name
function sqlite_updateLastedUntestedHash() {
    sqlite3 "$sqlite_path" "update ${TABLE_GIT_LOG} set ${COLUMN_GIT_LOG_TESTED}='True' where ${COLUMN_GIT_LOG_HASH}='$(sqlite_getLastestUntestedHash $1)' and ${COLUMN_GIT_LOG_BRANCH}='$1'"
}

## $1=branch_name
function sqlite_getLastestUntestedId() {
    sqlite3 "$sqlite_path" "select ${COLUMN_ID} from ${TABLE_GIT_LOG} where ${COLUMN_GIT_LOG_TESTED}='False' and ${COLUMN_GIT_LOG_BRANCH}='$1' order by ${COLUMN_ID} limit 1";
}

## $1=branch_name
function sqlite_getLastId() {
    sqlite3 "$sqlite_path" "select ${COLUMN_ID} from ${TABLE_GIT_LOG} where ${COLUMN_GIT_LOG_BRANCH}='$1' order by ${COLUMN_ID} desc limit 1";
}

## $1=branch_name
## select git_hash_code from tests_test_git_log where git_tested='False' order by id limit 1
function sqlite_getLastestUntestedHash() {
    sqlite3 "$sqlite_path" "select ${COLUMN_GIT_LOG_HASH} from ${TABLE_GIT_LOG} where ${COLUMN_GIT_LOG_TESTED}='False' and ${COLUMN_GIT_LOG_BRANCH}='$1' order by ${COLUMN_ID} limit 1";
}

## $1=hash, $2=branch_name
function sqlite_getGitLog() {
    sqlite3 "$sqlite_path" "select ${COLUMN_GIT_LOG_HASH} from ${TABLE_GIT_LOG} where ${COLUMN_GIT_LOG_HASH}='$1' and ${COLUMN_GIT_LOG_BRANCH}='$2'";
}

## with $1=subject, $2=author, $3=hash, $4=author_email, $5=branch_name
function sqlite_insertGitLog() {
    if [ -z "$1" -o -z "$2" -o -z "$3" -o -z "$4" ]; then
	    return;
	fi;
	## do not add duplicate git log
    local result="$(sqlite_getGitLog $3 $5)";
	if [ -z $result ]; then
	    sqlite3 "$sqlite_path" "insert into ${TABLE_GIT_LOG} ('${COLUMN_GIT_LOG_SUBJECT}','${COLUMN_GIT_LOG_AUTHOR_NAME}','${COLUMN_GIT_LOG_HASH}','${COLUMN_GIT_LOG_AUTHOR_EMAIL}','${COLUMN_GIT_LOG_TESTED}','${COLUMN_GIT_LOG_BRANCH}') values ('$1', '$2', '$3', '$4', 'False', '$5');";
	fi;
}

## $1=COLUMN_DEVICE_INFO_VERSION_SDK, $2=COLUMN_DEVICE_INFO_VERSION_INCREMENTAL, $3=COLUMN_DEVICE_INFO_PRODUCT, $4=COLUMN_DEVICE_INFO_CSC_VERSION, $5=COLUMN_DEVICE_INFO_CHARACRISTICS, $6=COLUMN_DEVICE_INFO_SKU, $7=COLUMN_DEVICE_INFO_DEVICE_ID
function sqlite_getDeviceInfo() {
    sqlite3 "$sqlite_path" "select * from ${TABLE_DEVICE_INFO} where ${COLUMN_DEVICE_INFO_VERSION_SDK}='$1' and ${COLUMN_DEVICE_INFO_VERSION_INCREMENTAL}='$2' and ${COLUMN_DEVICE_INFO_PRODUCT}='$3' and ${COLUMN_DEVICE_INFO_CSC_VERSION}='$4' and ${COLUMN_DEVICE_INFO_CHARACRISTICS}='$5' and ${COLUMN_DEVICE_INFO_SKU}='$6' and ${COLUMN_DEVICE_INFO_DEVICE_ID}='$7'";
}

## $1=COLUMN_DEVICE_INFO_VERSION_SDK, $2=COLUMN_DEVICE_INFO_VERSION_INCREMENTAL, $3=COLUMN_DEVICE_INFO_PRODUCT, $4=COLUMN_DEVICE_INFO_CSC_VERSION, $5=COLUMN_DEVICE_INFO_CHARACRISTICS, $6=COLUMN_DEVICE_INFO_SKU, $7=COLUMN_DEVICE_INFO_DEVICE_ID
function sqlite_getDeviceInfoId() {
    sqlite3 "$sqlite_path" "select id from ${TABLE_DEVICE_INFO} where ${COLUMN_DEVICE_INFO_VERSION_SDK}='$1' and ${COLUMN_DEVICE_INFO_VERSION_INCREMENTAL}='$2' and ${COLUMN_DEVICE_INFO_PRODUCT}='$3' and ${COLUMN_DEVICE_INFO_CSC_VERSION}='$4' and ${COLUMN_DEVICE_INFO_CHARACRISTICS}='$5' and ${COLUMN_DEVICE_INFO_SKU}='$6' and ${COLUMN_DEVICE_INFO_DEVICE_ID}='$7'";
}

## $1=COLUMN_DEVICE_INFO_VERSION_SDK, $2=COLUMN_DEVICE_INFO_VERSION_INCREMENTAL, $3=COLUMN_DEVICE_INFO_PRODUCT, $4=COLUMN_DEVICE_INFO_CSC_VERSION, $5=COLUMN_DEVICE_INFO_CHARACRISTICS, $6=COLUMN_DEVICE_INFO_SKU, $7=COLUMN_DEVICE_INFO_DEVICE_ID
function sqlite_insertDeviceInfo() {
    sqlite3 "$sqlite_path" "insert into ${TABLE_DEVICE_INFO} ('${COLUMN_DEVICE_INFO_VERSION_SDK}','${COLUMN_DEVICE_INFO_VERSION_INCREMENTAL}','${COLUMN_DEVICE_INFO_PRODUCT}','${COLUMN_DEVICE_INFO_CSC_VERSION}','${COLUMN_DEVICE_INFO_CHARACRISTICS}','${COLUMN_DEVICE_INFO_SKU}','${COLUMN_DEVICE_INFO_DEVICE_ID}') values ('$1', '$2', '$3', '$4', '$5', '$6', '$7');";
}

## remain latest 500 test results
function sqlite_removeOldTimeStamp() {
    remainItems=500;
    deleteTimeCmd="(SELECT id FROM ${TABLE_TESTTIME} ORDER BY ROWID DESC LIMIT -1 OFFSET ${remainItems})";
    sqlite3 "$sqlite_path" "DELETE FROM ${TABLE_TESTVERSION} WHERE ${COLUMN_TESTTIME_ID} in ${deleteTimeCmd};";
    sqlite3 "$sqlite_path" "DELETE FROM ${TABLE_LAUNCHERTAG} WHERE ${COLUMN_TESTTIME_ID} in ${deleteTimeCmd};";
    sqlite3 "$sqlite_path" "DELETE FROM ${TABLE_TESTRESULTS} WHERE ${COLUMN_TESTTIME_ID} in ${deleteTimeCmd};";
    sqlite3 "$sqlite_path" "DELETE FROM ${TABLE_TESTTIME} WHERE ROWID in (SELECT ROWID FROM ${TABLE_TESTTIME} ORDER BY ROWID DESC LIMIT -1 OFFSET ${remainItems});";
    sqlite3 "$sqlite_path" "delete from ${TABLE_TESTCASES} where id not in (select distinct ${COLUMN_TESTCASES_ID} from ${TABLE_TESTRESULTS});";
	sqlite3 "$sqlite_path" "DELETE FROM ${TABLE_EXTRA_MESSAGES}} WHERE ${COLUMN_EXTRA_MESSAGES_TESTTIME_ID}} in ${deleteTimeCmd};";
}

