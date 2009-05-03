# document properties
pdf.font "Times-Roman"
pdf.font_size 12
outer_padding = 10
inner_padding = 5

# header
pdf.header pdf.margin_box.top_left do
  pdf.text "Report on #{@survey.job_title}\n", :size => 16
  pdf.stroke_horizontal_rule
end

# footer
pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom + 25] do
  pdf.stroke_horizontal_rule
  pdf.pad_top(inner_padding) do
    pdf.text "Survey conducted at CompSage.com on behalf of: #{@survey.sponsor.name_and_location(false)}", 
      :size => 10, 
      :style => :italic
    pdf.text "Page: #{pdf.page_count}", :align => :right
  end
end

# body
pdf.bounding_box(
  [pdf.margin_box.left, pdf.y - 60], 
  :width => pdf.margin_box.width,
  :height => pdf.margin_box.height - 60) do
  
  # start: survey metadata
  pdf.text "Job Description", :style => :bold
  pdf.text "#{@survey.description}"
  
  pdf.pad_top(outer_padding) do
    pdf.text "Effective Date", :style => :bold
  end 
  pdf.text "#{@survey.effective_date.to_s(:long_ordinal)}" 
  
  pdf.pad_top(outer_padding) do
    pdf.text "Completion Date", :style => :bold
  end
  pdf.text "#{@survey.end_date.to_date.to_s(:long_ordinal)}"

  pdf.pad_top(outer_padding) do 
    pdf.text "Invitation List", :style => :bold
  end    
  @invitations.each do |invitation| 
    if invitation.is_a?(SurveyInvitation) then
      pdf.text "#{invitation.invitee.name_and_location(false)}"
    else
      pdf.text "#{invitation.organization_name} (#{invitation.email})"
    end   
  end
  
  # end: survey metadata
  pdf.horizontal_rule 

  # questions
  @survey.questions.each do |question|
    pdf.pad_top(outer_padding) do   
      pdf.text "#{question.text}", :style => :bold
    end   
    if question.send(@adequate_responses_method) then
        pdf.pad_top(inner_padding) do
          render :partial=> "#{question.report_type}.pdf.prawn",  :locals=>{:p_pdf=>pdf, :question => question}
        end 
      if question.send(@qualifications_method).count > 0 then
        pdf.pad_top(inner_padding) do
          pdf.text "Comments", :style => :bold, :size => 10
          question.send(@qualifications_method).each do |qualification|          
            pdf.text "#{qualification}", :size => 10
          end
        end
      end
    else
      pdf.text "Results not available due to insufficient responses."
    end
  end

end

