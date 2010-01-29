class AddInvitationMessageToSurveys < ActiveRecord::Migration
  def self.up
    add_column :surveys, :custom_invitation_message, :text
  end

  def self.down
    remove_column :surveys, :custom_invitation_message
  end
end
