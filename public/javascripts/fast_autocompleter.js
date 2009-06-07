Autocompleter.Json = Class.create(Autocompleter.Base, {
  'initialize': function(element, update, lookupFunction, options) {
    options = options || {};
    this.baseInitialize(element, update, options);
    this.lookupFunction = lookupFunction;
    this.options.list_generator = options.list_generator.bind(this) || this.listGenerator.bind(this);
    this.options.choices = options.choices || 10;
  },
  
  'getUpdatedChoices': function() {
    this.lookupFunction(this.getToken().toLowerCase(), this.updateJsonChoices.bind(this));
  },
  
  'updateJsonChoices': function(choices) {
    list = this.options.list_generator(choices.slice(0, this.options.choices));
    this.updateChoices(list);
  },
  
  'listGenerator': function(choices) {
    return '<ul>' + choices.map(this.jsonChoiceToListChoice.bind(this)).join('') + '</ul>';
  },

  'jsonChoiceToListChoice': function(choice, mark) {
    return '<li>' + choice.escapeHTML() + '</li>';
  }
});

Autocompleter.Cache = Class.create({
  'initialize': function(backendLookup, options) {
    this.cache = new Hash();
    this.backendLookup = backendLookup;
    this.options = Object.extend({
      'choices': 10,
      'fuzzySearch': false,
      'dataToQueryParam': function(data){ data; }
    }, options || {});
  },
  
  'lookup': function(term, callback) {
    return this._lookupInCache(term, null, callback) || this.backendLookup(term, this._storeInCache.curry(term, callback).bind(this));
  },
  
  '_lookupInCache': function(fullTerm, partialTerm, callback) {
    var partialTerm = partialTerm || fullTerm;
    var result = this.cache[partialTerm];
    if (result == null) {
      if (partialTerm.length > 1) {
        return this._lookupInCache(fullTerm, partialTerm.substr(0, partialTerm.length - 1), callback);
      } else {
        return false;
      }
    } else {
      if (fullTerm != partialTerm) {
        result = this._localSearch(result, fullTerm);
        this._storeInCache(fullTerm, null, result);
      }
      callback(result.slice(0, this.options.choices));
      return true;
    }
  },
  
  '_localSearch': function(data, term) {
    var exp = this.options.fuzzySearch ? new RegExp(term.gsub(/./, ".*#{0}"), 'i') : new RegExp(term, 'i');
    var foundItems = new Array();
    
    //optimized for speed:
    var item = null;
    var name = null;
    for (var i = 0, len = data.length; i < len; ++i) {
      item = data[i];
      if (exp.test(this.options.dataToQueryParam(item))) {
        foundItems.push(item);
      }
    }
    
    return foundItems;
  },
  
  '_storeInCache': function(term, callback, data) {
    this.cache[term] = data;
    if (callback) {
      callback(data.slice(0, this.options.choices));
    }
  }
});
