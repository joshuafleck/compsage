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
      link_to("Dashboard", dashboard_path) + if links.length > 0 then " < " else "" end + links.join(" < ")
    end
  end
  
  def link_to_organization_with_logo(organization)
    
    if organization.logo.nil? then
      image_tag("tiny_thumbnail_placeholder.gif", :class => 'inline_logo') +
      link_to(organization.name, organization_path(organization))
    else
      content_tag(:a, :href => url_for(organization)) do
        image_tag(organization.logo.public_filename(:tiny_thumbnail), :class => 'inline_logo') +
        link_to(organization.name, organization_path(organization))
      end
    end
  end
end
