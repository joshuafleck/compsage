class Breadcrumbs
  def initialize(root_path)
    @crumbs = [root_path]
  end
  
  def <<(link)
    @crumbs.push(link)
    return self
  end
  
  def links(page_title = "", sep = ">")
    unless page_title == @crumbs.first[0]
      @crumbs.collect{|crumb| crumb.is_a?(Array) ? "<a href=\"#{crumb[1]}\">#{crumb[0]}</a>" : crumb}.join(" #{sep} ") + " #{sep} #{page_title}"
    end
  end
end