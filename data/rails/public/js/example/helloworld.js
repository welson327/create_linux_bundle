$(function(){
	$("input").click(function() {
		var id = $(this).attr('id');
		switch(id) {
			case "btnGetToken":
				var postData = {
					keyword: $("#keyword").val(),
				};
				$.ajax({
					type: "POST",
					url: "/example/hash",
					contentType: "application/json",
					dataType: "json",
					data: JSON.stringify(postData),
					beforeSend: function(xhr) {
						xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
					},
					success: function(json) { 
						$("#keyword").val(json.after);
					},
					error: function() {
						$.log("FAIL");
					},
					complete:function(){
					}    				
				});
				break;
				
			case "btnGetTime":
				$("#time").val(new Date());
				break;
				
			default:
				break;
		}
	});
});
