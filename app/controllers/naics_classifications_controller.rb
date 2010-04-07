class NaicsClassificationsController < ApplicationController

  # Gathers a list of child nodes of the current node, or the roots if no node is currently selected.
  # Also gathers a list of ancestors of the current node.
  def children_and_ancestors
    children  = []
    ancestors = []
    
    if !params[:id].blank? then
      naics_classification = NaicsClassification.find(params[:id])
      
      # Automatically drill down into nodes with only one child
      children = naics_classification.children 
      while children.size == 1 do
        naics_classification = children.first
        children             = naics_classification.children 
      end
        
      ancestors = naics_classification.self_and_ancestors
    else
      children = NaicsClassification.roots
    end
    
    respond_to do |wants|
      wants.json do
        render :json => { 
          :children => children.to_json(
            :only => [:code, :description], 
            :methods => [:children_count, :display_code]), 
          :ancestors => ancestors.to_json(
            :only => [:code, :description], 
            :methods => [:children_count, :display_code]) 
          }.to_json
      end
    end
  end
end
