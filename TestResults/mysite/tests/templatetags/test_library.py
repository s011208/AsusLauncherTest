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
            return tag.get('test_version')
    return "N/A"
    
register.simple_tag(remove_pkg)
register.simple_tag(get_test_result)
register.simple_tag(get_test_version)
register.simple_tag(get_test_tag)