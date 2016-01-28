$("tr.content_column").click(function () {
	$(this).find(".content_failure").each(function() {
		if($(this).height() == 100) {
			$(this).css('height', '100%');
		} else {
			$(this).css('height', '100px');
		}
	});
});

