module HomeHelper
  def page_name(name)
    content_for(:page_name, name)
  end
end
