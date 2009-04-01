/*
 * inputMask creates a new mask object that will only allow certain inputs. Currently supports only currency, percent,
 * and plain number.
 * @element Form element to observe.
 * @data_type Expected data type for the form element. Must be one of 'currency', 'percent', or 'number'
 */
function inputMask(element, data_type) {
  var element = element;	
  var data_type = data_type;
  var char_mask	= /.*/;
  var last_valid = "";
  var data_template = "";	
  var precision = null;

  if(data_type == 'currency') {
    char_mask = /^\$?\d*\.?\d{0,2}$/;
    data_template = "$#{number}";
    precision = 2;
  } else if(data_type == 'percent') {
    char_mask = /^\d*\.?\d*\%?$/;
    data_template = "#{number}%";
  } else if(data_type == 'number') {
    char_mask = /^\d*\.?\d*$/;
    data_template = "#{number}";
  }
  
  element.observe('keyup', function(e) {
    var new_value = e.element().value;
    if(!new_value.match(char_mask)) {
      e.element().value = last_valid;
    } else {
      last_valid = e.element().value;
    }
  })

  element.observe('change', function(e) {
    var clean_value = e.element().value.match(/(\d+\.?\d*)|(\.\d+)/);
    var number = parseFloat(clean_value);

    if(precision)
      number = number.toFixed(precision);
    
    if(isNaN(number))
      e.element().value = "";
    else
      e.element().value = data_template.interpolate({'number': number});

    last_valid = e.element().value;
  })
}

/*
 * This will add observers to all form inputs that will call the specified method when enter is pushed
 * @form the form
 * @toCall the function that will be called
 */
function callFunctionOnEnterForm(f,toCall) {
  var inputs = f.select('input');
  inputs.each(function(s) {
    s.observe('keydown', callFunctionOnEnter.curry(toCall));
  });
}

/*
 * This will capture the enter key and call the provided function
 * @toCall the function to call
 * @e the event
 */
function callFunctionOnEnter(toCall,e) {
  if (!e) var e = window.event;
  if(e.keyCode==13){
    e.stop();
    toCall();
  }
  return false;
}

/*
 * This will make an anynchronous request to have an invitation created 
 * @organization the organization id of the invitee
 */
function sendInvitation(organization,path) {
  e = this;
	new Ajax.Request(path+'/'+$F(this)+'/invitations', {
		'method': 'post',
		'parameters': 'invite_organization['+organization+'][included]=1',
		'requestHeaders': {'Accept':'text/javascript'},
		'onSuccess': function(transport) {
			showInvitationResults(transport.responseText,e,organization);
		}
	});  
}

/**
 * This will render the response of the invitation request 
 * @response the response from the server
 * @elem the select element to be reset
 * @organization the organization id of the invitee
 */
function showInvitationResults(response,elem,organization) {
  elem.value = '';
  $('organization_'+organization+'_response').update(response);
}

/**
 * This will return true if the field is an email address, and false otherwise
 * @email the email string

 */
function isValidEmail(email) {
  var filter = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
  return filter.test(email);
}

/**
 * Tab javascript code from the highly regarded Dan Peverill.
 */
var Tabs = {
	className: "tabs",
	activeClass: "active",
	
	addLoadEvent: function(event) {
		var oldLoad = window.onload;
		
		window.onload = function() {
			event();
			if (oldLoad) oldLoad();
		}
	},
	
	create: function(tabs, callbacks) {
		if (!tabs.length)
			this.createSingle(tabs, callbacks);
		else
			this.createGroup(tabs, callbacks);
	},
	
	createSingle: function(tab, callbacks) {
		if (this.Element.hasClass(tab, this.activeClass))
			this.Element.show(this.getTarget(tab));
	
		this.Element.addClickEvent(tab, function(e) {
			if (!Tabs._callback(this, callbacks, "click", e))
				return false;	// Cancel event.
			
			Tabs.Element.toggleClass(this, Tabs.activeClass);
			
			if (!Tabs._callback(this, callbacks, "show", e))
				return false;	// Callback handled visibility change.
			
			Tabs.Element.toggleVisibility(Tabs.getTarget(this));
		});
	},
	
	createGroup: function(tabs, callbacks) {
		var active;
		
		for (var i = 0; i < tabs.length; i++) {
			var tab = tabs[i];
			if (this.Element.hasClass(tab, this.activeClass)) {
				active = tab;
				this.Element.addClass(tab);
				this.Element.show(this.getTarget(tab));
			}
			else {
				this.Element.hide(this.getTarget(tab));
			}

			Tabs.Element.addClickEvent(tab, function(e) {
				if (!Tabs._callback(this, callbacks, "click", e, active))
					return false;	// Cancel event.
					
				Tabs.Element.removeClass(active, Tabs.activeClass);
				Tabs.Element.addClass(this, Tabs.activeClass);
				
				var from = active;
				active = this;
				
				if (!Tabs._callback(this, callbacks, "show", e, from))
					return false;	// Callback handled visibility change.
				
				Tabs.Element.hide(Tabs.getTarget(from));
				Tabs.Element.show(Tabs.getTarget(this));
			});
		}
		
		if (!active) {
			var tab = tabs[0];
			active = tab;
			
			this.Element.addClass(tab, this.activeClass);
			this.Element.show(this.getTarget(tab));
		}
	},
	
	_callback: function(element, callbacks, type, e, active) {
		if (callbacks && callbacks[type] && callbacks[type].call(element, e, active) === false)
			return false;
		
		return true;
	},
	
	getTarget: function(tab) {
		var match = /#(.*)$/.exec(tab.href);
		var target;
		
		if (match && (target = document.getElementById(match[1])))
			return target;
	},
	
	getElementsByClassName: function(className, tag) {
		var elements = document.getElementsByTagName(tag || "*");
		var list = new Array();
		
		for (var i = 0; i < elements.length; i++) {
			if (this.Element.hasClass(elements[i], this.className))
				list.push(elements[i]);
		}
		
		return list;
	}
};

Tabs.Element = {
	addClickEvent: function(element, callback) {
		var oldClick = element.onclick;
		
		element.onclick = function(e) {
			callback.call(this, e);
			if (oldClick) oldClick.call(this, e);	// Play nice with others.
			
			return false;
		}
	},
	
	addClass: function(element, className) {
		element.className += (element.className ? " " : "") + className;
	},
	
	removeClass: function(element, className) {
		element.className = element.className.replace(new RegExp("(^|\\s)" + className + "(\\s|$)"), "$1");
		if (element.className == " ")
			element.className = "";
	},

	hasClass: function(element, className) {
		return element.className && (new RegExp("(^|\\s)" + className + "(\\s|$)")).test(element.className);
	},
	
	toggleClass: function(element, className) {
		if (this.hasClass(element, className))
			this.removeClass(element, className);
		else
			this.addClass(element, className);
	},
	
	getStyle: function(element, property) {
		if (element.style[property]) return element.style[property];
		
		if (element.currentStyle)	// IE.
			return element.currentStyle[property];
			
		property = property.replace(/([A-Z])/g, "-$1").toLowerCase();	// Turns propertyName into property-name.
		var style = document.defaultView.getComputedStyle(element, "");
		if (style)
			return style.getPropertyValue(property);
	},
	
	show: function(element) {
		element.style.display = "";
		if (this.getStyle(element, "display") == "none")
			element.style.display = "block";
	},
	
	hide: function(element) {
		element.style.display = "none";
	},
	
	isVisible: function(element) {
		return this.getStyle(element, "display") != "none";
	},
	
	toggleVisibility: function(element) {
		if (this.isVisible(element))
			this.hide(element);
		else
			this.show(element);
	}
};

Tabs.addLoadEvent(function() {
	var elements = Tabs.getElementsByClassName(Tabs.className);
	for (var i = 0; i < elements.length; i++) {
		var element = elements[i];
			
		if (element.tagName == "A") {
			Tabs.create(element);
		}
		else {	// Group
			var tabs = element.getElementsByTagName("a");
			var group = new Array();
				
			for (var t = 0; t < tabs.length; t++) {
				if (Tabs.getTarget(tabs[t]))
					group.push(tabs[t]);	// Only group actual tab links.
			}

			if (group.length) Tabs.create(group);
		}
	}
});
