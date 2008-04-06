class DashboardsController < ApplicationController
  before_filter :login_required
  def show
    @recent_survey_invitations = current_organization.survey_invitations.find(:all, :order => 'created_at DESC', :limit => 10)
    @recent_network_invitations = current_organization.network_invitations.find(:all, :order => 'created_at DESC', :limit => 10)
    @recent_running_surveys = Survey.find( :all,
      :order => 'created_at DESC',
      :limit => 10,
      :include => :survey_invitations,
      :conditions => ['surveys.end_date >= ? AND (surveys.sponsor_id = ? OR (survey_invitations.invitee_id = ? AND survey_invitations.accepted=true))', Time.now, current_organization.id, current_organization.id])

    @recent_completed_surveys = Survey.find( :all,
      :order => 'created_at DESC',
      :limit => 10,
      :include => :survey_invitations,
      :conditions => ['surveys.end_date < ? AND (surveys.sponsor_id = ? OR (survey_invitations.invitee_id = ? AND survey_invitations.accepted=true))', Time.now, current_organization.id, current_organization.id])

  end
end
