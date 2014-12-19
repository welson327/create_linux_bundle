// ===============================================================
// Purpose: 	Draw category sidebar, including HOMEPAGE, CATEGORY_LEVEL_1, CATEGORY_LEVEL_2, ... 
//				with different CSS
// Parameter:	$dom: jQuery DOM to append syntax
//				obj: ebookCategoryObject in ebook.category.object.js
//				type: 0,1,2,100 = HOMEPAGE, CATEGORY_LEVEL_1, CATEGORY_LEVEL_2, PRODUCT_PAGE
//				function item_click_cb(categoryId){}: click callback
//				focusId: active item
// Return:		
// Remark:		Your CSS should be loaded first!
// Author:		welson
// ===============================================================
function _drawCategorySidebar($dom, obj, type, subcategory_click_cb, focusId) {
	$dom.empty();
	
	var row = "";
	var publicNum = 0;
	var len = obj.getCategoryLength();
	
	if(type == null)
		type = 0;
	
	for(var i=0; i<len; ++i) {
		publicNum = obj.getNumberOfCategoryPublicBook(i);
		if(publicNum > 0) {
			var url = HOSTNAME + SITE + "/pages/category_level1_page.html?categoryId=" + obj.getCategoryId(i);
			var subrow = getSubCategoryItems(type, obj, i, focusId);
			var cssAttr = "";
			var title = getCagegoryDisplayText(obj.getCategoryName(i), null);
			
			switch(type) {
				case 1:// LEVEL-1
				case 2:// LEVEL-2
				case 100: // product_page
					if(focusId==obj.getCategoryId(i)  &&  isParentCategoryId(focusId)) {
						cssAttr = 'class="actived"';
					}
					row = 
						'<h3 ' + cssAttr + ' categoryId="' + obj.getCategoryId(i) + '">' + title + '</h3>' +
							'<ul>' +
							subrow +
							'</ul>';
					break;
				
				default://HOMEPAGE
					row = 
						'<div class="cateTitle">' +
							'<a href="' + url + '" categoryId="' + obj.getCategoryId(i) + '">' + title + '<img class="iconCate" src="' + SITE + '/img/iconCate.png" /></a>' +
						'</div>' +
						'<ul class="cate">' +
							subrow +
						'</ul>';
					break;
			}
	
			
			//$.log("queryCategoryId(" + focusId + "), drawId(" + obj.getCategoryId(i) + ")");
			if(focusId==obj.getCategoryId(i)  &&  isParentCategoryId(focusId)) // include util.js
				$dom.prepend(row);
			else
				$dom.append(row);
		}
	}
	
	// sub-level callback
	$("ul a", $dom).each(function(idx) {
		$(this).click(function() {
			var categoryId = Number($(this).attr('categoryId'));
			
			// callback
			if(subcategory_click_cb) {
				subcategory_click_cb(categoryId);
			}
		});
	});
}

function getSubCategoryItems(type, obj, i, focusId) {
	var subrow = "";
	var limit6 = false; // for homepage
	var len = obj.getSubCategoryLength(i);
	var publicNum = 0;
	var subcategoryCnt = 0;
	var subcategoryShowCnt = 0;
	
	for(var j=0; j<len; ++j) {
		if(obj.getNumberOfSubCategoryPublicBook(i, j) > 0)
			++subcategoryShowCnt;
	}
	
	for(var j=0; j<len; ++j) {
		publicNum = obj.getNumberOfSubCategoryPublicBook(i, j);
		if(publicNum > 0) {
			var title = getCagegoryDisplayText(obj.getSubCategoryName(i, j), null);
			var categoryId = obj.getSubCategoryId(i, j);
			var subUrl = HOSTNAME + SITE + "/pages/category_level2_page.html?categoryId=" + categoryId;
			
			++subcategoryCnt;
			
			switch(type) {
				// LEVEL-1
				case 1: 
					//if(j==len-1  &&  (subcategoryCnt&1)==1) // last & is odd
					if(subcategoryShowCnt==subcategoryCnt  &&  (subcategoryCnt&1)==1) // last-shown & is odd
						subrow += '<li class="last"><a href="' + subUrl + '" categoryId="' + categoryId + '" title="' + title + '">' + title + '</a></li>';
					else 
						subrow += '<li><a href="' + subUrl + '" categoryId="' + categoryId + '" title="' + title + '">' + title + '</a></li>';
					break;
				
				// LEVEL-2
				case 2:	
				case 100:	
					if(categoryId == focusId) // place first
						subrow = '<li class="actived"><a href="' + subUrl + '" categoryId="' + categoryId + '" title="' + title + '">' + title + '</a></li>' + subrow;
						//subrow = '<li class="actived">' + title + '</li>' + subrow;
					else
						subrow += '<li><a href="' + subUrl + '" categoryId="' + categoryId + '" title="' + title + '">' + title + '</a></li>';
					break;
				
				//HOMEPAGE
				default: 
					if(subcategoryCnt > 6)
						limit6 = true;
					else
						subrow += '<li><a href="' + subUrl + '" categoryId="' + categoryId + '" activeIndex="' + i + '" subActiveIndex="' + j + '" title="' + title + '">' + title + '</a></li>';
					break;
			}
		
			if(limit6)
				break;
		}
	}
	
	return subrow;
}

function getCagegoryDisplayText(name, publicNum) {
	if(publicNum)
		return name + " (" + publicNum + ")";
	else
		return name;
}

