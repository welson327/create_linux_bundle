
function attachAutoResizeTask(input, new_width, new_height) {
	console.log("0000");
	
	
		var fr = new FileReader();
		fr.onload = function(e) {
			
			var img = new Image();
		    img.onload = function() {
		    	//console.log(">>>>>>>>>>>>> image on load");
		    	console.log("333");
			    //var MAXWidthHeight = 64;
			    //var r = MAXWidthHeight/Math.max(this.width, this.height);
			    //w = Math.round(this.width*r),
			    //h = Math.round(this.height*r),
			    c = document.createElement("canvas");
			    c.width = new_width; 
			    c.height = new_height;
			    c.getContext("2d").drawImage(this, 0, 0, new_width, new_height);
			    this.src = c.toDataURL();
			    //document.body.appendChild(this);
			    console.log("over");
			    
			    //instance.send(canvas.base64);
		    };
		    console.log("2222, e.target.result=" + e.target.result);
		    img.src = e.target.result;
		    input.files[0] = e.target.result;
		};
		
		console.log("111");
		fr.readAsDataURL(input.files[0]);
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	/*
	var file = input.value;
	var img = new Image();
	img.src = file;

	    var MAXWidthHeight = 64;
	    //var r = MAXWidthHeight/Math.max(this.width, this.height);
	    //w = Math.round(this.width*r),
	    //h = Math.round(this.height*r),
	    var c = document.createElement("canvas");
	    c.width = new_width; 
	    c.height = new_height;
	    //c.getContext("2d").drawImage(img, 0, 0, new_width, new_height);
	    c.getContext("2d").drawImage(img, 0, 0, 50, 50);
	    img.src = c.toDataURL();
	
	    console.log("2222 resize: c.toDataURL()=" + c.toDataURL());
*/	    
	
	
	
	
	
	
	
	
	
	
	
	
	/*
	var img = new Image();
    img.onload = function() {
    	//console.log(">>>>>>>>>>>>> image on load");
    	console.log("2222");
	    var MAXWidthHeight = 64;
	    var r = MAXWidthHeight/Math.max(this.width, this.height);
	    w = Math.round(this.width*r),
	    h = Math.round(this.height*r),
	    c = document.createElement("canvas");
	    c.width = w; c.height = h;
	    c.getContext("2d").drawImage(this, 0, 0, new_width, new_height);
	    this.src = c.toDataURL();
	    //document.body.appendChild(this);
    };
    console.log("1111");
    img.src = file;
	*/
	
	    /*
    console.log("arg1=" + file);
	
    var fr = new FileReader();
	fr.onload = function(readerEvt) {
		var img = new Image();
		img.src = file;
	    //img.onload = function() {
	    	//console.log(">>>>>>>>>>>>> image on load");
	    	console.log("2222 resize");
		    var MAXWidthHeight = 64;
		    //var r = MAXWidthHeight/Math.max(this.width, this.height);
		    //w = Math.round(this.width*r),
		    //h = Math.round(this.height*r),
		    c = document.createElement("canvas");
		    c.width = new_width; 
		    c.height = new_height;
		    c.getContext("2d").drawImage(img, 0, 0, new_width, new_height);
		    img.src = c.toDataURL();
		    //document.body.appendChild(this);
	    //};
	    console.log("1111 fr.onload");
	    //img.src = file;
	};
	fr.readAsDataURL(img.src);
	*/
	
	
	
	
	
	
	
	
	/*
	var task = function(e) {
		var fr = new FileReader();
		fr.onload = function(e) {
			
			
			
			var img = new Image();
		    img.onload = function() {
		    	//console.log(">>>>>>>>>>>>> image on load");
		    	console.log("2222");
			    var MAXWidthHeight = 64;
			    var r = MAXWidthHeight/Math.max(this.width, this.height);
			    w = Math.round(this.width*r),
			    h = Math.round(this.height*r),
			    c = document.createElement("canvas");
			    c.width = w; c.height = h;
			    c.getContext("2d").drawImage(this, 0, 0, new_width, new_height);
			    this.src = c.toDataURL();
			    document.body.appendChild(this);
		    };
		    console.log("1111");
		    img.src = e.target.result;
		    
		    
		    
		};
		console.log("3333");
		fr.readAsDataURL(e.target.files[0]);
	};
	
	window.onload = function() {
		console.log(">>>>>>>>>>>>> add resize task:" + domId);
		document.getElementById(domId).addEventListener('change', task, false);	
	};*/
}
