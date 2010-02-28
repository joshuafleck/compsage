# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include BetterDateHelper
  
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
  
  def link_to_organization(organization, options = {})
    include_location = options.delete(:include_location) != false
    if current_survey_invitation then
      @path = organization_path(organization, :survey_id => current_survey_invitation.survey.id)
    else
      @path = organization_path(organization)
    end
    link_to(include_location ? organization.name_and_location : organization.name, @path,
        :title => "Contact: #{organization.contact_name} #{organization.city + ", " + organization.state unless organization.city.blank?}")
  end

  def link_to_network(network)
    link_to(network.name, network_path(network)) + " " +
      content_tag(:span, :class => "manager") do
        if current_organization != network.owner then
         "managed by #{link_to_organization(network.owner)}"
        end
      end
  end
  
  # Determines how to display the invitation, depending on the invitation type.
  # Options:
  #   :link_to_invitation - will link to the invitee show page (for internal invitations)
  #   :expose_external_invitation_email - will expose the external invitee's email (should only be exposed to sponsor)
  def format_invitation(invitation, options = {}) 
    expose_external_invitation_email = options.delete(:expose_external_invitation_email) || false
    link_to_invitation = options.delete(:link_to_invitation) || false
    
    if invitation.is_a? SurveyInvitation || NetworkInvitation then
      if link_to_invitation then
        link_to_organization(invitation.invitee)
      else
        invitation.invitee.name_and_location
      end
    else
      if expose_external_invitation_email then
        invitation.organization_name_and_email
      else
        invitation.organization_name
      end
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
    
  # Passes text through a gauntlet of functions to improve the results for an end user
  # Used for description fields.
  def link_and_format(text, options = {})
    simple_format(auto_link(text, :html => {:target => '_blank'}), options)
  end

  # Auto links with links opening in a new window.
  def auto_link_new_window(text)
    auto_link(text, :html => {:target => '_blank'})
  end
  
  # Determines the subdomain that should be used when creating a CS link for the organization
  # Checks to see if the email address passed belongs to an uninitialized association member
  def subdomain_for(params)
  
    organization = params[:organization]
    email        = params[:email]
    
    organization = Organization.find_by_email(email) if email
    
    if organization && organization.association then
      organization.association.subdomain      
    else
      ''
    end
  end
end
