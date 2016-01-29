from django import template

register = template.Library()

def remove_pkg(string):
    return string.replace("com.asus.launcher.", "")
    
def get_test_result(test_results, test_case_id, test_time_id):
    for result in test_results:
        if int(result.get('test_case_id')) == int(test_case_id):
            if int(result.get('test_time_id')) == int(test_time_id):
                return result.get('test_result').replace("\r", "@@@")
    return "N/A"
    
def get_test_version(test_versions, test_time_id):
    for version in test_versions:
        if int(version.get('test_time_id')) == int(test_time_id):
            return version.get('test_version')
    return "N/A"
	
def get_test_tag(test_tags, test_time_id):
    for tag in test_tags:
        if int(tag.get('test_time_id')) == int(test_time_id):
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
    return int(round(1 - float(pass_results) / float(total_results), 2) * 100)

register.simple_tag(remove_pkg)
register.simple_tag(get_test_result)
register.simple_tag(get_test_version)
register.simple_tag(get_test_tag)
register.simple_tag(get_test_case_fail_rate)