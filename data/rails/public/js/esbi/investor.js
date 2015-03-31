
var g_loan = {
	rate: 2.0,			// annual percentage rate
	year: 20,
	gracePeroid: 0, 	// unit: year
	
	// http://terms.naer.edu.tw/detail/1607159/
	principal: 0.0,
	
	setRate: function(value) { this.rate = value; },
	setYear: function(value) { this.year = value; },
	setGracePeroid: function(value) { this.gracePeroid = value; },
	setPrincipal: function(value) { this.principal = value; },
	
	getRate: function() { return this.rate; },
	getYear: function() { return this.year; },
	getGracePeroid: function() { return this.gracePeroid; },
	getPrincipal: function() { return this.principal; },
	
	getPrincipalAndInterest: function() {
		var mRate = this.rate / 12 / 100; // monthly rate
		var n = (this.year - this.gracePeroid) * 12;
		//double principal = totalPrice * loadToValue/100;
		
		// monthly average Principal & Interest 
		var avgPI = (Math.pow(1+mRate, n) * mRate) / (Math.pow(1+mRate, n) - 1);
		return this.principal * avgPI;
	},
	getOnlyInterest: function() {
		var mRate = this.rate / 12 / 100;
		return this.principal * mRate;		
	}
}

var g_investor = {
	loan: null,
	
	totalPrice: 0,
	rent: 0,			// total rent per month
	rateOfRent: 100,	// 100%
	decorationCost: 0, 	// total decoration cost
	serviceCost: 2, 	// 2%
	tax: 5,
		
	// constructor
	init: function(Loan) {
		this.loan = Loan;
	},
	
	//---------------------------------------------------------------------
	setTotalPrice: function(value) {
		this.totalPrice = value;
	},	
	setRent: function(value) {
		this.rent = value; // if rentRate=100%
	},
	setRateOfRent: function(value) {
		this.rateOfRent = value;
	},
	setDecorationCost: function(value) {
		this.decorationCost = value;
	},
	setServiceCost: function(value) {
		this.serviceCost = value;
	},
	setTax: function(value) {
		this.tax = value;
	},

	
	setRate: function(value) {
		this.loan.setRate(value);
	},
	setYear: function(value) {
		this.loan.setYear(value);
	},
	setGracePeroid: function(value) {
		this.loan.setGracePeroid(value);
	},
	setPrincipal: function(value) {
		this.loan.setPrincipal(value);
	},
	
	
	//---------------------------------------------------------------------
	getTotalPrice: function() {
		return totalPrice;
	},
	getRent: function() {
		return this.rent;
	},
	getRateOfRent: function() {
        return this.rateOfRent;
    },
	getDecorationCost: function() {
        return this.decorationCost;
    },
	getServiceCost: function() {
        return this.serviceCost;
    },
	getTax: function() {
        return this.tax;
    },
	
	getROI: function() {
		return (this.rent*this._rentRate() - this.loan.getOnlyInterest()) * 12 / this.getPreCost();
	},
	
	getROI_ofPrincipalAndInterest: function() {
		return (this.rent*this._rentRate() - this.loan.getPrincipalAndInterest()) * 12 / this.getPreCost();
	},
	
	getROT: function() { // rate of total price
		return (this.rent*this._rentRate()*12 / this.totalPrice);
	},
	
	getCashFlowBeforeGracePeroid: function() {
		return (this.rent*this._rentRate() - this.loan.getOnlyInterest());
	},
	
	getCashFlowAfterGracePeroid: function() {
		return (this.rent*this._rentRate() - this.loan.getPrincipalAndInterest());
	},
	
    getPreCost: function() {
        var principal = this.loan.getPrincipal();
        return (this.totalPrice-principal + this.totalPrice*this.serviceCost/100 + this.tax + this.decorationCost);
    },
	
    _rentRate: function() {
    	return (this.rateOfRent/100);
    }
}

var LOAN_TYPE_LOAD_TO_VALUE = 0;
var LOAN_TYPE_AMOUNT = 1;
var loanType = 0;

$(function(){
	g_investor.init(g_loan);
	
	$('input[name=loan][value=LOAD_TO_VALUE]').attr('checked', true);
	$('input[name=loan]').live('change', function() { 
		var $loanPrompt = $("#loanPrompt");
		switch($(this).val()) {
		case "LOAD_TO_VALUE":
			$loanPrompt.text("成數(％)");
			loanType = LOAN_TYPE_LOAD_TO_VALUE;
			break;
		case "AMOUNT":
			$loanPrompt.text("額度(萬)");
			loanType = LOAN_TYPE_AMOUNT;
			break;		
		}
		switchLoanUiValue(loanType);
	});
	
	$("input").bind({
		keydown: function(evt) {
			var keycode = evt.which;
			//$.log("keycode=" + keycode);
			if(	(keycode>=48 && keycode<=57) ||	// 0-9
				(keycode==8 || keycode==46) ) {	// backspace, Del
				return true;
			} else if(keycode == 190) { 		// .
				var text = $(this).val();
				return !(text.lastIndexOf(".") > -1);
			} else if(keycode == 13) { 			// enter
				calc();
				return false;
			} else {
				return false; // block other key
			}
		},
		click: function() {
			$(this).select();
		}
	});
	
	
	$("#calc").click(function() {
		calc();
	});
});

function calc() {
	var totalPrice = parseInt($("#total").val());
	var uiLoanValue = parseFloat($("#loan").val());
	var principal = 0;
	switch(loanType) {
		case LOAN_TYPE_LOAD_TO_VALUE:
			//loadToValue = usrLoanValue;
			principal = totalPrice * uiLoanValue/100;
			break;
		case LOAN_TYPE_AMOUNT:
			//loadToValue = ((double)usrLoanValue/totalPrice) * 100;
			principal = uiLoanValue;
			break;
	}
	
	// loan
	var loan = g_loan;
	loan.setPrincipal(principal);
	loan.setGracePeroid(parseInt($("#gracePeroid").val()));
	loan.setYear(parseInt($("#year").val()));
	loan.setRate(parseFloat($("#rate").val()));
	
	// decoration cost
	var suiteNum = parseInt($("#suiteNum").val());
	var othersNum = parseInt($("#othersNum").val());
	var decorationCost = suiteNum * parseInt($("#suiteDecorationCost").val()) + 
			             othersNum * parseInt($("#othersDecorationCost").val());
	var totalRent = suiteNum * parseFloat($("#suiteRent").val()) + 
			        othersNum * parseFloat($("#othersRent").val());
	
	// Investor
	var investor = g_investor;
	investor.loan = loan;
	investor.setTotalPrice(totalPrice);
	investor.setRent(totalRent);
	investor.setRateOfRent(parseInt(100));
	investor.setServiceCost(parseFloat(2.0)); // 2% service
	investor.setTax(5);
	investor.setDecorationCost(decorationCost);
	
	$("#cf1").text(myFloat(investor.getCashFlowBeforeGracePeroid(), 3) + " 萬/月");
	$("#cf2").text(myFloat(investor.getCashFlowAfterGracePeroid(), 3) + " 萬/月");
	$("#rot").text(myFloat(100*investor.getROT(), 3) + " %");
	$("#roi").text(myFloat(100*investor.getROI(), 2) + " %, " + myFloat(100*investor.getROI_ofPrincipalAndInterest(), 2) + " %");
	$("#preCost").text(myFloat(investor.getPreCost(), 2) + " 萬");	
}

function switchLoanUiValue(loanType) {
	var totalPrice = parseInt($("#total").val());
	var uiLoanValue = parseFloat($("#loan").val());
	var setValue = "";
	switch(loanType) {
		case LOAN_TYPE_LOAD_TO_VALUE:
			setValue = myFloat((uiLoanValue/totalPrice * 100), 1);
			break;
		case LOAN_TYPE_AMOUNT:
			setValue = parseInt(uiLoanValue*totalPrice / 100);
			break;
	}
	$("#loan").val(setValue)
}

function myFloat(value, digit) {
	var div = Math.pow(10, digit);// digti=3, means %.3f
	return parseFloat(Math.round(value*div))/div;
}
