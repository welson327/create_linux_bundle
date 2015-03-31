;(function(ns){
	/**
	 * mb_strwidth
	 * @param String
	 * @return int
	 * @see http://php.net/manual/ja/function.mb-strwidth.php
	 */
	var mb_strwidth = function(str){
		var i=0,l=str.length,c='',length=0;
		for(;i<l;i++){
			c=str.charCodeAt(i);
			if(0x0000<=c&&c<=0x0019){
				length += 0;
			}else if(0x0020<=c&&c<=0x1FFF){
				length += 1;
			}else if(0x2000<=c&&c<=0xFF60){
				length += 2;
			}else if(0xFF61<=c&&c<=0xFF9F){
				length += 1;
			}else if(0xFFA0<=c){
				length += 2;
			}
		}
		return length;
	};
	
	/**
	 * mb_strimwidth
	 * @param String
	 * @param int
	 * @param int
	 * @param String
	 * @return String
	 * @see http://www.php.net/manual/ja/function.mb-strimwidth.php
	 */
	var mb_strimwidth = function(str,start,width,trimmarker){
		if(typeof trimmarker === 'undefined') trimmarker='';
		var trimmakerWidth = mb_strwidth(trimmarker),i=start,l=str.length,trimmedLength=0,trimmedStr='';
		for(;i<l;i++){
			var charCode=str.charCodeAt(i),c=str.charAt(i),charWidth=mb_strwidth(c),next=str.charAt(i+1),nextWidth=mb_strwidth(next);
			trimmedLength += charWidth;
			trimmedStr += c;
			if(trimmedLength+trimmakerWidth+nextWidth>width){
				trimmedStr += trimmarker;
				break;
			}
		}
		return trimmedStr;
	};
	ns.mb_strwidth   = mb_strwidth;
	ns.mb_strimwidth = mb_strimwidth;
})(window);