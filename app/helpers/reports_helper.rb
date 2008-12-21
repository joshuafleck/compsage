module ReportsHelper
  def chart(chart, source, options = {})
    options = {
      :classid => "clsid:D27CDB6E-AE6D-11cf-96B8-444553540000",
      :codebase => "http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0",
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
        :pluginspage => "http://www.macromedia.com/go/getflashplayer")
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
end
