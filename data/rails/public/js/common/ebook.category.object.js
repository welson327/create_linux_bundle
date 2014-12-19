/* =====================================================
 * Purpose:		for basic object
 * Parameter:
 * Return:
 * Remark:
		{
		    "Data": [
		        {
		            "id": 100000000,
		            "value": "漫畫書",
		            "subcategory": [
		                {
		                    "id": 101000000,
		                    "value": "社會、政治、職場"
		                },
		                {
		                    "id": 102000000,
		                    "value": "校園、運動"
		                }, ...
		            ]
		        }, ...
		    ]
		}
 * Author: welson
 * ===================================================== */ 
var ebookCategoryObject = {
		Data: [],
		hash: {}, // save key/value pair of categoryId/categoryName

		getData: function() {
			return this.Data;
		},
		setData: function(jsonarray) {
			this.Data = jsonarray;
			
			// create hash: O(n)
			this.hash = {};
			for(var i=0; i<this.getCategoryLength(); ++i) {
				var id = this.getCategoryId(i);
				
				/*
				this.hash[id.toString()] = {
					subcategory: this.getSubCategories(i),
					value: this.getCategoryName(i)
				};
				*/
				
				this.hash[id.toString()] = this.getCategoryName(i);
				
				for(var j=0; j<this.getSubCategoryLength(i); ++j) {
					var id2 = this.getSubCategoryId(i, j);
					this.hash[id2.toString()] = this.getSubCategoryName(i, j);
				}
			}
		},
		
		// query hash data
		getCategoryNameById: function(id) {
			return this.hash[id];
		},
		
		// category
		getCategoryLength : function() { 
			return this.Data.length; 
		},
		getCategoryName : function(index) { 
			return this.Data[index].value; 
		},
		getCategoryId : function(index) { 
			return this.Data[index].id; 
		},
		getNumberOfCategoryPublicBook : function(index) { 
			return this.Data[index].publicNum; 
		},
		getNumberOfCategoryPrivateBook : function(index) { 
			return this.Data[index].privateNum; 
		},
		
		// sub-category
		getSubCategoryLength : function(index) { 
			return this.Data[index].subcategory.length; 
		},		
		getSubCategories : function(index) { 
			return this.Data[index].subcategory; 
		},
		getSubCategoryName : function(categoryIndex, subCategoryIndex) { 
			return this.Data[categoryIndex].subcategory[subCategoryIndex].value;
		},		
		getSubCategoryId : function(categoryIndex, subCategoryIndex) { 
			return this.Data[categoryIndex].subcategory[subCategoryIndex].id;
		},
		getNumberOfSubCategoryPublicBook : function(categoryIndex, subCategoryIndex) { 
			return this.Data[categoryIndex].subcategory[subCategoryIndex].publicNum; 
		},
		getNumberOfSubCategoryPrivateBook : function(categoryIndex, subCategoryIndex) { 
			return this.Data[categoryIndex].subcategory[subCategoryIndex].privateNum; 
		}
};