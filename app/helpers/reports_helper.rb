module ReportsHelper
  def chart(chart, source, options = {})
    options = {
      :classid => "clsid:D27CDB6E-AE6D-11cf-96B8-444553540000",
      :codebase => "https://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0",
      :height => 300,
      :width => 500,
      :id => 'chart',
      :dimensions => 2
    }.merge(options)
    
    flash_path = "/charts/FCF_#{chart.capitalize}#{options[:dimensions]}D.swf"
    flash_params = "&dataURL=#{source}&chartWidth=#{options[:width]}&chartHeight=#{options[:height]}"
    content_tag(:object, options.except(:dimensions)) do
      tag(:param, :name => 'movie', :value => flash_path) +
      tag(:param, :name => 'FlashVars', :value => flash_params) + 
      tag(:param, :name => 'quality', :value => 'high') + 
      tag(:embed,
        :src => flash_path,
        :flashVars => flash_params,
        :quality => 'high',
        :width => options[:width],
        :height => options[:height],
        :name => options[:id],
        :type => "application/x-shockwave-flash",
        :pluginspage => "https://www.macromedia.com/go/getflashplayer")
    end
  end

  # Works similar to Rails' cycle, except it cycles through the steps of the defined gradient.
  # Takes some options. Start color and end color are required and define the gradient you want
  # to interpolate. You can optionally pass a count that defines how many steps in the gradient
  # to cycle through, which defaults to 4.

  def cycle_gradient(options)
    raise ArgumentError unless options.include?(:start_color) && options.include?(:end_color)
    count = options.delete(:count) || 4
    steps = count - 1
    @_current_step = 0 unless defined? @_current_step
    
    # First line splits the hex string into channels for each color and zips the two together,
    # resulting in an array of ranges for each channel, eg [[0, 255], [0,255], [0,255]]. The
    # second line then does the interpolation on each channel, formats the string into the
    # proper hex, and joins it all together.

    current_color = options.delete(:start_color).scan(/../).collect{|b| b.hex}.zip(options.delete(:end_color).scan(/../).collect{|b| b.hex}).
      collect { |r| "%02x"%(r.first + ((r.last - r.first) / steps) * @_current_step) }.join
    @_current_step = (@_current_step + 1) % count
    
    current_color
  end


  # Creates a paragraph in a WordML document. Can be called with a block with an optional options param hash, or can be
  # called with the content directly as the first argument, followed by an optional params hash.
  # Example:
  #   <%= word_p "Bold text!", :bold => true %>
  #   <% word_p :style => "Heading1" do %>
  #     Big header!
  #   <% end %>
  #
  # Available options are:
  # * :no_keep - Set to true to not tell the paragraph to hold on to the next paragraph, preventing a line break
  #   between them.
  # * :style - Set the style of the paragraph. Example: Heading1.
  # * :justify - Justify the text left, center, or right.
  # * :bold - Make the text bold.
  # * :italic - Make the text italic.
  #
  def word_p(*args, &block)
    content = if block_given? then
      capture(&block).strip
    else
      args.shift.to_s
    end

    options = args.shift || {}

    xml = "<w:p><w:pPr>"
    
    unless no_keep = options.delete(:no_keep) then
      xml += "<w:keepLines/><w:keepNext/>"
    end

    if style = options.delete(:style) then
      xml += "<w:pStyle w:val=\"#{style}\"/>"
    end

    if justification = options.delete(:justify) then
      xml += "<w:jc w:val=\"#{justification}\"/>"
    end
    xml += "</w:pPr><w:r>"
    
    bold = options.delete(:bold)
    italic = options.delete(:italic)

    if bold || italic then
      xml += "<w:rPr>"
      xml += "<w:b/>" if bold
      xml += "<w:i/>" if italic
      xml += "</w:rPr>"
    end

    xml += "<w:t>" + content + "</w:t></w:r></w:p>"

    if block_given? then
      concat xml
    else
      return xml
    end
  end

  def word_table(options = {}, &block)
    header = options.delete(:header)
    concat <<-TBL
    <w:tbl>
      <w:tblPr>
        <w:tblStyle w:val="TableElegant"/>
        <w:tblW w:w="0" w:type="auto"/>
        <w:tblLook w:val="#{ header ? "01E0" : "01C0" }"/>
      </w:tblPr>
      #{capture(&block).strip}
    </w:tbl>
    TBL
  end

  def word_tr(&block)
    concat <<-TBL
    <w:tr>
      #{capture(&block).strip}
    </w:tr>
    TBL
  end

  def word_td(&block)
    concat <<-TBL
    <w:tc>
      #{capture(&block).strip}
    </w:tc>
    TBL
  end

  def word_section(&block)
    concat <<-TBL
    <wx:sub-section>
      #{capture(&block).strip}
      <w:p/>
    </wx:sub-section>
    TBL
  end
end
