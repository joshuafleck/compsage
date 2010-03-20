class AddBillingInstructionsToAssociation < ActiveRecord::Migration
  def self.up
    add_column :associations, 'billing_instructions', :text
  end

  def self.down
    remove_column :associations, 'billing_instructions'
  end
end
