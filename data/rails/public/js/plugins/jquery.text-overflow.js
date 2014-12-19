/*
 * MIT LICENSE
 * Copyright (c) 2009-2011 Devon Govett.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
 * documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
 * the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
 * and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions 
 * of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 
 * THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

(function($) {
	$.fn.ellipsis = function(enableUpdating){
		var s = document.documentElement.style;
		if (!('textOverflow' in s || 'OTextOverflow' in s)) {
			return this.each(function(){ // 'this' = jQuery object
				var el = $(this);
				if(el.css("overflow") == "hidden"){
					var originalText = el.html();
					var w = el.width();
					
					var t = $(this.cloneNode(true)).hide().css({
                        'position': 'absolute',
                        'width': 'auto',
                        'overflow': 'visible',
                        'max-width': 'inherit'
                    });
					el.after(t);
					
					var text = originalText;
					while(text.length > 0 && t.width() > el.width()){
						text = text.substr(0, text.length - 1);
						t.html(text + "...");
					}
					el.html(t.html());
					
					t.remove();
					
					if(enableUpdating == true){
						var oldW = el.width();
						setInterval(function(){
							if(el.width() != oldW){
								oldW = el.width();
								el.html(originalText);
								el.ellipsis();
							}
						}, 200);
					}
				}
			});
		} else return this;
	};
	
	
	// ==================================================================
	// Purpose:
	// Parameter:	
	// Return:		jQuery object
	// Remark:
	// Author:		welson
	// ==================================================================
	$.fn.ellipsisText = function(width, callback) {
		return this.each(function() { // 'this' = jQuery object
			var el = $(this);
			if(el.css("overflow") == "hidden"){
				var originalText = el.html();
				var w = el.width();
				
				var t = $(this.cloneNode(true)).hide().css({
                    'position': 'absolute',
                    'width': 'auto',
                    'overflow': 'visible',
                    'max-width': 'inherit'
                });
				el.after(t);
				
				var text = originalText;
				var originalTextLen = originalText.length;
				
				// welson improve
				var sliceLen = 0;
				var adj = 0;
				if(originalTextLen > 0) {
					adj = Math.floor(originalTextLen / 2);
					sliceLen = adj;
					do {
						if(adj <= 1)
							break;
						
						text = originalText.substr(0, sliceLen);
						t.html(text + "...");
						
						adj = Math.floor(adj / 2);
						
						if(text.length > 0 && t.width() < width) {
							sliceLen += adj;
						} else if(text.length > 0 && t.width() > width) {
							sliceLen -= adj;
						} else
							break;
					} while(true);
				}
				
				/* ori-plugin
				while(text.length > 0 && t.width() > width) { 
					text = text.substr(0, text.length - 1);
					t.html(text + "...");
					loopCnt++;
				}*/
				
				el.html(t.html());
				
				t.remove();

				if(callback) {
					callback($(this), el.html());
				}
			}
		});
	};
})(jQuery);