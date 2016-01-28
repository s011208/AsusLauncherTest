$(document).ready(function(){
	$("tr.content_column").click(function () {
		$(this).find(".content_failure").each(function() {
			if($(this).height() == 70) {
				$(this).css('height', '100%');
			} else {
				$(this).css('height', '70px');
			}
		});
	});
});
