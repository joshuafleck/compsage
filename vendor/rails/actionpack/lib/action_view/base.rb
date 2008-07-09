module ActionView #:nodoc:
  class ActionViewError < StandardError #:nodoc:
  end

  class MissingTemplate < ActionViewError #:nodoc:
  end

  # Action View templates can be written in three ways. If the template file has a <tt>.erb</tt> (or <tt>.rhtml</tt>) extension then it uses a mixture of ERb
  # (included in Ruby) and HTML. If the template file has a <tt>.builder</tt> (or <tt>.rxml</tt>) extension then Jim Weirich's Builder::XmlMarkup library is used.
  # If the template file has a <tt>.rjs</tt> extension then it will use ActionView::Helpers::PrototypeHelper::JavaScriptGenerator.
  #
  # = ERb
  #
  # You trigger ERb by using embeddings such as <% %>, <% -%>, and <%= %>. The <%= %> tag set is used when you want output. Consider the
  # following loop for names:
  #
  #   <b>Names of all the people</b>
  #   <% for person in @people %>
  #     Name: <%= person.name %><br/>
  #   <% end %>
  #
  # The loop is setup in regular embedding tags <% %> and the name is written using the output embedding tag <%= %>. Note that this
  # is not just a usage suggestion. Regular output functions like print or puts won't work with ERb templates. So this would be wrong:
  #
  #   Hi, Mr. <% puts "Frodo" %>
  #
  # If you absolutely must write from within a function, you can use the TextHelper#concat.
  #
  # <%- and -%> suppress leading and trailing whitespace, including the trailing newline, and can be used interchangeably with <% and %>.
  #
  # == Using sub templates
  #
  # Using sub templates allows you to sidestep tedious replication and extract common display structures in shared templates. The
  # classic example is the use of a header and footer (even though the Action Pack-way would be to use Layouts):
  #
  #   <%= render "shared/header" %>
  #   Something really specific and terrific
  #   <%= render "shared/footer" %>
  #
  # As you see, we use the output embeddings for the render methods. The render call itself will just return a string holding the
  # result of the rendering. The output embedding writes it to the current template.
  #
  # But you don't have to restrict yourself to static includes. Templates can share variables amongst themselves by using instance
  # variables defined using the regular embedding tags. Like this:
  #
  #   <% @page_title = "A Wonderful Hello" %>
  #   <%= render "shared/header" %>
  #
  # Now the header can pick up on the <tt>@page_title</tt> variable and use it for outputting a title tag:
  #
  #   <title><%= @page_title %></title>
  #
  # == Passing local variables to sub templates
  #
  # You can pass local variables to sub templates by using a hash with the variable names as keys and the objects as values:
  #
  #   <%= render "shared/header", { :headline => "Welcome", :person => person } %>
  #
  # These can now be accessed in <tt>shared/header</tt> with:
  #
  #   Headline: <%= headline %>
  #   First name: <%= person.first_name %>
  #
  # If you need to find out whether a certain local variable has been assigned a value in a particular render call,
  # you need to use the following pattern:
  #
  #   <% if local_assigns.has_key? :headline %>
  #     Headline: <%= headline %>
  #   <% end %>
  #
  # Testing using <tt>defined? headline</tt> will not work. This is an implementation restriction.
  #
  # == Template caching
  #
  # By default, Rails will compile each template to a method in order to render it. When you alter a template, Rails will
  # check the file's modification time and recompile it.
  #
  # == Builder
  #
  # Builder templates are a more programmatic alternative to ERb. They are especially useful for generating XML content. An XmlMarkup object
  # named +xml+ is automatically made available to templates with a <tt>.builder</tt> extension.
  #
  # Here are some basic examples:
  #
  #   xml.em("emphasized")                              # => <em>emphasized</em>
  #   xml.em { xml.b("emph & bold") }                   # => <em><b>emph &amp; bold</b></em>
  #   xml.a("A Link", "href"=>"http://onestepback.org") # => <a href="http://onestepback.org">A Link</a>
  #   xml.target("name"=>"compile", "option"=>"fast")   # => <target option="fast" name="compile"\>
  #                                                     # NOTE: order of attributes is not specified.
  #
  # Any method with a block will be treated as an XML markup tag with nested markup in the block. For example, the following:
  #
  #   xml.div {
  #     xml.h1(@person.name)
  #     xml.p(@person.bio)
  #   }
  #
  # would produce something like:
  #
  #   <div>
  #     <h1>David Heinemeier Hansson</h1>
  #     <p>A product of Danish Design during the Winter of '79...</p>
  #   </div>
  #
  # A full-length RSS example actually used on Basecamp:
  #
  #   xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  #     xml.channel do
  #       xml.title(@feed_title)
  #       xml.link(@url)
  #       xml.description "Basecamp: Recent items"
  #       xml.language "en-us"
  #       xml.ttl "40"
  #
  #       for item in @recent_items
  #         xml.item do
  #           xml.title(item_title(item))
  #           xml.description(item_description(item)) if item_description(item)
  #           xml.pubDate(item_pubDate(item))
  #           xml.guid(@person.firm.account.url + @recent_items.url(item))
  #           xml.link(@person.firm.account.url + @recent_items.url(item))
  #
  #           xml.tag!("dc:creator", item.author_name) if item_has_creator?(item)
  #         end
  #       end
  #     end
  #   end
  #
  # More builder documentation can be found at http://builder.rubyforge.org.
  #
  # == JavaScriptGenerator
  #
  # JavaScriptGenerator templates end in <tt>.rjs</tt>. Unlike conventional templates which are used to
  # render the results of an action, these templates generate instructions on how to modify an already rendered page. This makes it easy to
  # modify multiple elements on your page in one declarative Ajax response. Actions with these templates are called in the background with Ajax
  # and make updates to the page where the request originated from.
  #
  # An instance of the JavaScriptGenerator object named +page+ is automatically made available to your template, which is implicitly wrapped in an ActionView::Helpers::PrototypeHelper#update_page block.
  #
  # When an <tt>.rjs</tt> action is called with +link_to_remote+, the generated JavaScript is automatically evaluated.  Example:
  #
  #   link_to_remote :url => {:action => 'delete'}
  #
  # The subsequently rendered <tt>delete.rjs</tt> might look like:
  #
  #   page.replace_html  'sidebar', :partial => 'sidebar'
  #   page.remove        "person-#{@person.id}"
  #   page.visual_effect :highlight, 'user-list'
  #
  # This refreshes the sidebar, removes a person element and highlights the user list.
  #
  # See the ActionView::Helpers::PrototypeHelper::GeneratorMethods documentation for more details.
  class Base
    include ERB::Util

    attr_accessor :base_path, :assigns, :template_extension, :first_render
    attr_accessor :controller

    attr_writer :template_format
    attr_accessor :current_render_extension

    attr_accessor :output_buffer

    class << self
      delegate :erb_trim_mode=, :to => 'ActionView::TemplateHandlers::ERB'
    end

    # Specify whether templates should be cached. Otherwise the file we be read everytime it is accessed.
    @@cache_template_loading = false
    cattr_accessor :cache_template_loading

    def self.cache_template_extensions=(*args)
      ActiveSupport::Deprecation.warn("config.action_view.cache_template_extensions option has been deprecated and has no affect. " <<
                                       "Please remove it from your config files.", caller)
    end

    # Specify whether RJS responses should be wrapped in a try/catch block
    # that alert()s the caught exception (and then re-raises it).
    @@debug_rjs = false
    cattr_accessor :debug_rjs

    attr_internal :request

    delegate :request_forgery_protection_token, :template, :params, :session, :cookies, :response, :headers,
             :flash, :logger, :action_name, :controller_name, :to => :controller

    module CompiledTemplates #:nodoc:
      # holds compiled template code
    end
    include CompiledTemplates

    # Cache public asset paths
    cattr_reader :computed_public_paths
    @@computed_public_paths = {}

    def self.helper_modules #:nodoc:
      helpers = []
      Dir.entries(File.expand_path("#{File.dirname(__FILE__)}/helpers")).sort.each do |file|
        next unless file =~ /^([a-z][a-z_]*_helper).rb$/
        require "action_view/helpers/#{$1}"
        helper_module_name = $1.camelize
        if Helpers.const_defined?(helper_module_name)
          helpers << Helpers.const_get(helper_module_name)
        end
      end
      return helpers
    end

    def initialize(view_paths = [], assigns_for_first_render = {}, controller = nil)#:nodoc:
      @assigns = assigns_for_first_render
      @assigns_added = nil
      @controller = controller
      self.view_paths = view_paths
    end

    attr_reader :view_paths

    def view_paths=(paths)
      @view_paths = ViewLoadPaths.new(Array(paths))
    end

    # Renders the template present at <tt>template_path</tt> (relative to the view_paths array).
    # The hash in <tt>local_assigns</tt> is made available as local variables.
    def render(options = {}, local_assigns = {}, &block) #:nodoc:
      if options.is_a?(String)
        render_file(options, nil, local_assigns)
      elsif options == :update
        update_page(&block)
      elsif options.is_a?(Hash)
        options = options.reverse_merge(:locals => {})

        if partial_layout = options.delete(:layout)
          if block_given?
            wrap_content_for_layout capture(&block) do
              concat(render(options.merge(:partial => partial_layout)))
            end
          else
            wrap_content_for_layout render(options) do
              render(options.merge(:partial => partial_layout))
            end
          end
        elsif options[:file]
          render_file(options[:file], nil, options[:locals])
        elsif options[:partial] && options[:collection]
          render_partial_collection(options[:partial], options[:collection], options[:spacer_template], options[:locals], options[:as])
        elsif options[:partial]
          render_partial(options[:partial], options[:object], options[:locals])
        elsif options[:inline]
          render_inline(options[:inline], options[:locals], options[:type])
        end
      end
    end

    # Returns true is the file may be rendered implicitly.
    def file_public?(template_path)#:nodoc:
      template_path.split('/').last[0,1] != '_'
    end

    # The format to be used when choosing between multiple templates with
    # the same name but differing formats.  See +Request#template_format+
    # for more details.
    def template_format
      return @template_format if @template_format

      if controller && controller.respond_to?(:request)
        @template_format = controller.request.template_format
      else
        @template_format = :html
      end
    end

    def file_exists?(template_path)
      view_paths.template_exists?(template_file_from_name(template_path))
    end

    # Gets the extension for an existing template with the given template_path.
    # Returns the format with the extension if that template exists.
    #
    #   pick_template_extension('users/show')
    #   # => 'html.erb'
    #
    #   pick_template_extension('users/legacy')
    #   # => "rhtml"
    #
    def pick_template_extension(template_path)
      if template = template_file_from_name(template_path)
        template.extension
      end
    end

    private
      # Renders the template present at <tt>template_path</tt>. The hash in <tt>local_assigns</tt>
      # is made available as local variables.
      def render_file(template_path, use_full_path = nil, local_assigns = {}) #:nodoc:
        if defined?(ActionMailer) && defined?(ActionMailer::Base) && controller.is_a?(ActionMailer::Base) && !template_path.include?("/")
          raise ActionViewError, <<-END_ERROR
  Due to changes in ActionMailer, you need to provide the mailer_name along with the template name.

    render "user_mailer/signup"
    render :file => "user_mailer/signup"

  If you are rendering a subtemplate, you must now use controller-like partial syntax:

    render :partial => 'signup' # no mailer_name necessary
          END_ERROR
        end

        Template.new(self, template_path, use_full_path, local_assigns).render_template
      end

      def render_inline(text, local_assigns = {}, type = nil)
        InlineTemplate.new(self, text, local_assigns, type).render
      end

      def wrap_content_for_layout(content)
        original_content_for_layout, @content_for_layout = @content_for_layout, content
        yield
      ensure
        @content_for_layout = original_content_for_layout
      end

      # Evaluate the local assigns and pushes them to the view.
      def evaluate_assigns
        unless @assigns_added
          assign_variables_from_controller
          @assigns_added = true
        end
      end

      # Assigns instance variables from the controller to the view.
      def assign_variables_from_controller
        @assigns.each { |key, value| instance_variable_set("@#{key}", value) }
      end

      def execute(template)
        send(template.method, template.locals) do |*names|
          instance_variable_get "@content_for_#{names.first || 'layout'}"
        end
      end

      def template_file_from_name(template_name)
        template_name = TemplateFile.from_path(template_name)
        pick_template(template_name) unless template_name.extension
      end

      def pick_template(file)
        if f = self.view_paths.find_template_file_for_path(file.dup_with_extension(template_format)) || file_from_first_render(file)
          f
        elsif template_format == :js && f = self.view_paths.find_template_file_for_path(file.dup_with_extension(:html))
          @template_format = :html
          f
        else
          nil
        end
      end

      # Determine the template extension from the <tt>@first_render</tt> filename
      def file_from_first_render(file)
        if extension = File.basename(@first_render.to_s)[/^[^.]+\.(.+)$/, 1]
          file.dup_with_extension(extension)
        end
      end
  end
end
