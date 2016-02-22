from django import template

register = template.Library()

def remove_pkg(string):
    return string.replace("com.asus.launcher.", "")
    
def get_test_result(test_results, test_case_id, test_time_id):
    for result in test_results:
        if int(result.get('test_case_id')) == int(test_case_id):
            if isinstance(result.get('test_time_id'), int) and int(result.get('test_time_id')) == int(test_time_id):
                if not result.get('test_result'):
                    return "N/A"
                return result.get('test_result').replace("\r", "@@@")
    return "N/A"
	
def get_test_result_extra_message(test_results, test_case_id, test_time_id):
    for result in test_results:
        if int(result.get('test_case_id')) == int(test_case_id):
            if isinstance(result.get('test_time_id'), int) and int(result.get('test_time_id')) == int(test_time_id):
                if not result.get('test_extra_msgs'):
                    return "N/A"
                return result.get('test_extra_msgs').replace("\n", "@@@")
    return ""
    
def get_test_version(test_versions, test_time_id):
    for version in test_versions:
        if isinstance(version.get('test_time_id'), int) and int(version.get('test_time_id')) == int(test_time_id):
            return version.get('test_version')
    return "N/A"
	
def get_test_tag(test_tags, test_time_id):
    for tag in test_tags:
        if isinstance(tag.get('test_time_id'), int) and int(tag.get('test_time_id')) == int(test_time_id):
            return tag.get('test_tag')
    return "N/A"
	
def get_test_case_fail_rate(test_results, test_case_id):
    total_results = 0
    pass_results = 0
    for result in test_results:
        if int(result.get('test_case_id')) == int(test_case_id):
           total_results += 1
           if result.get('test_result') == 'OK':
               pass_results += 1
    if total_results == 0:
	    return 0
    return int(round(1 - float(pass_results) / float(total_results), 2) * 100)

def get_git_log_subject_from_time_stamp(git_logs, test_time_git_id):
    if isinstance(test_time_git_id, int) or test_time_git_id.isdigit():
        for git_log in git_logs:
	        if int(git_log.get('id')) == int(test_time_git_id):
		        return git_log.get('git_subject')
        return "N/A"
    return test_time_git_id
	
def get_git_log_author_name_from_time_stamp(git_logs, test_time_git_id):
    if isinstance(test_time_git_id, int) or test_time_git_id.isdigit():
        for git_log in git_logs:
	        if int(git_log.get('id')) == int(test_time_git_id):
		        return git_log.get('git_author_name')
        return "N/A"
    return test_time_git_id
	
def get_git_log_hash_code_from_time_stamp(git_logs, test_time_git_id):
    if isinstance(test_time_git_id, int) or test_time_git_id.isdigit():
        for git_log in git_logs:
	        if int(git_log.get('id')) == int(test_time_git_id):
		        return git_log.get('git_hash_code')
        return "N/A"
    return test_time_git_id

def get_test_threshold(test_thresholds, branch, test_case_id):
    rtn = ""
    for test_threshold in test_thresholds:
        if int(test_threshold.get('test_case_id')) == int(test_case_id) and test_threshold.get('test_branch') == branch:
            rtn += "[" + test_threshold.get('test_method_name') + "] " + test_threshold.get('test_threshold_name') + ": " + str(test_threshold.get('test_threshold_value')) + "\n";
    return rtn

def get_test_extra_messages(tests_extra_messages, test_case_id, test_time_id):
    rtn = ""
    for tests_extra_message in tests_extra_messages:
        if int(test_time_id) == int(tests_extra_message.get('test_time_id')) and int(test_case_id) == int(tests_extra_message.get('test_case_id')):
            rtn += "[" + tests_extra_message.get('test_method_name') + "]" + tests_extra_message.get('test_message_name') + ": " + str(tests_extra_message.get('test_message_value')) + "@@@";
    return rtn

def get_is_result_pass(test_thresholds, test_extra_messages, test_case_id, test_time_id, branch):
## -1=failed to find thresholds, 0=pass, 1=failed
    rtn = -1;
    failedToFind = 0;
    for test_extra_message in test_extra_messages:
        if int(test_time_id) == int(test_extra_message.get('test_time_id')) and int(test_case_id) == int(test_extra_message.get('test_case_id')):
            thresholdName = test_extra_message.get('test_message_name');
            thresholdValue = test_extra_message.get('test_message_value');
            testMethod = test_extra_message.get('test_method_name');
            isFind = False;
            for test_threshold in test_thresholds:
                if test_threshold.get('test_branch') == branch and test_threshold.get('test_threshold_name') == thresholdName and test_threshold.get('test_method_name') == testMethod and test_case_id == int(test_threshold.get('test_case_id')):
                    isFind = True;
                    if int(test_threshold.get('test_threshold_value')) > thresholdValue:
                        if rtn == -1:
                            rtn = 0;
                    else:
                        rtn = 1;
            if isFind == False:
                rtn = -1;
                break;
    return rtn;		


register.simple_tag(remove_pkg)
register.simple_tag(get_test_result)
register.simple_tag(get_test_version)
register.simple_tag(get_test_tag)
register.simple_tag(get_test_case_fail_rate)
register.simple_tag(get_git_log_subject_from_time_stamp)
register.simple_tag(get_git_log_author_name_from_time_stamp)
register.simple_tag(get_git_log_hash_code_from_time_stamp)
register.simple_tag(get_test_result_extra_message)
register.simple_tag(get_test_threshold)
register.simple_tag(get_test_extra_messages)
register.simple_tag(get_is_result_pass)