require 'rubygems'
require 'webrat'

# This module impelments the webrat API. If we are testing javascript, then we implement the webrat method on the
# browser session. Otherwise we super.
#
module DomInterfaceHelper
  def dom_interface=(interface)
    case interface
    when :firewatir
      self.extend FirewatirMethods
    when :webrat
      self.extend WebratMethods
    end
    
    @_browser = nil
  end

  def dom_browser=(browser)
    @_browser = browser
  end

  # The following are some wrappers that will be reimplemented if we use firewatir (see below)
  def response_body
    response.body
  end

  def div(name)
    ::Webrat::XML.css_search(webrat_session.dom, "div##{name}, div.#{name}").first
  end

  # This method will work to verify content, but will not work to do things like click as it returns a
  # nokogiri node rather than a webrat object of the proper type for the element.
  def get_element_by_xpath(xpath)
    ::Webrat::XML.xpath_search(webrat_session.dom, xpath).first
  end

  module FirewatirMethods 
    def response_body
      @_browser.js_eval("document.documentElement.innerHTML")
    end

    def attach_file(locator, path, content_type = nil)
      raise RuntimeException, "Not Implemented"
    end
    
    def check(locator)
      FirewatirUtils.locate_element(@_browser, :checkbox, locator).click
    end

    def choose(locator)
      FirewatirUtils.locate_element(@_browser, :radio, locator).set
    end

    def click_area(area_name)
      raise RuntimeException, "Not Implemented"
    end

    def click_button(locator)
      FirewatirUtils.locate_element(@_browser, :button, locator).click
    end

    def click_link(locator, options = {})
      FirewatirUtils.locate_element(@_browser, :link, locator).click 
    end

    def div(locator)
      FirewatirUtils.locate_element(@_browser, :div, locator)
    end

    def field_named(locator)
      FirewatirUtils.locate_element(@_browser, :text_field, locator)
    end

    def field_labeled(locator)
      raise RuntimeException, "Not Implemented"
    end
    
    def fill_in(locator, options = {})
      method = options.delete(:method) || :value=
      with   = options.delete(:with)
      FirewatirUtils.locate_element(@_browser, :text_field, locator).send(method, with)
    end

    def select(value, options)
      FirewatirUtils.locate_element(@_browser, :select_list, options[:from]).select_value(value)
    end

    def select_date(*args)
      raise RuntimeException, "Not Implemented"
    end

    def select_datetime(*args)
      raise RuntimeException, "Not Implemented"
    end

    def select_time(*args)
      raise RuntimeException, "Not Implemented"
    end

    def visit(url)
      @_browser.goto(url.gsub('http://www.example.com', @base_url))
    end

    def set_hidden_field(locator, options)
      raise RuntimeException, "Not Implemented"
    end

    def submit_form(id)
      raise RuntimeException, "Not Implemented"
    end

    def uncheck(locator)
      FirewatirUtils.locate_element(@_browser, :radio, locator).clear
    end

    def get_element_by_xpath(path)
      elem = @_browser.element_by_xpath(path)
      if !elem.exists?
        return nil
      else
        elem
      end
    end
  end

  module FirewatirUtils
    def self.locate_element(browser, type, locator)
      methods = [:id, :name, :value, :class, :content]
      val     = nil

      begin
        val = browser.send(type, methods.shift, locator)
      end while !val.exists? && methods.any?

      return val
    end
  end
end
