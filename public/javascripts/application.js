// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

/**
 * JF: This function will create an AJAX request.
 * This should be used if form_for_remote is not an option.
 * One example is if the request URL is dependent on what the
 * user selects in the form.
 *
 * invitee: the element containing the ID of the invitee
 * target: the html element containing the ID of the target of the invitation
 * url: the path for the request- this should be a template e.g. new Template(surveys/#{replacingID}/invitations)
 * container: the html element to update when the request has completed
 */
function buildAjaxInvitationRequest(invitee,target,url,container) { 
  if($F(target) == '') {
    return false
  }
  new Ajax.Updater(container,url.evaluate({replacingID: $F(target)}), {
    asynchronous:true, 
    evalScripts:true, 
    parameters:Form.serializeElements([invitee])
  }); 
  return false;
};

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
