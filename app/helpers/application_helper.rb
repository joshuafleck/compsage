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
      link_to("Surveys", surveys_path) + if links.length > 0 then " < " else "" end + links.join(" < ")
    end
  end
  
  def highlight_tab(tab)
    content_for(:highlighted_tab) do
      "#{tab}"
    end
  end
  
  def link_to_organization(organization)
    link_to(organization.name_and_location, organization_path(organization),
      :title => "Contact: #{organization.contact_name} #{organization.city + ", " + organization.state unless organization.city.blank?}")
  end

  def link_to_network(network)
    link_to(network.name, network_path(network)) + " " +
      content_tag(:span, :class => "manager") do
        "managed by " + link_to_organization(network.owner)
      end
  end
  
  # Appends the required image to the text
  def required(text)
    text + image_tag("required.gif")
  end  

  # Simplifies making form items nested next to each other. Use in conjunction with form_block
  def form_row(&block)
    @template.concat @template.content_tag(:div, @template.capture(&block), :class => 'box_container')
  end

  def form_box(&block)
    @template.concat @template.content_tag(:div, @template.capture(&block), :class => 'box')
  end
end
