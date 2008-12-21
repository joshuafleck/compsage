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
end
