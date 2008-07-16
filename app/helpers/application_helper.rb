# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def flash_messages
    [:notice, :error, :message].collect do |key|
      content_tag(:div, flash[key], :class => "flash_#{key}") unless flash[key].blank?
    end.join
  end
  
  def title(title)
    content_for(:title) do
      "#{title}"
    end
  end
  
  def breadcrumbs(*links)
    content_for(:breadcrumbs) do
      link_to("Dashboard", dashboard_path) + " < " + links.join(" < ")
    end
  end
  
end
