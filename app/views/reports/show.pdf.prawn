require 'prawn/format'

# document properties
pdf.font "Times-Roman"
pdf.font_size 12
outer_padding = 10
inner_padding = 5

# header
pdf.header pdf.margin_box.top_left do
  pdf.text "CompSage survey for: #{@survey.job_title}", :size => 16
  pdf.stroke_horizontal_rule
end

# footer
pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom + 25] do
  pdf.stroke_horizontal_rule
  pdf.pad_top(inner_padding) do
    pdf.text "CompSage survey sponsored by: #{@survey.sponsor.name_and_location}", 
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

  pdf.pad_top(inner_padding) do
    pdf.text "Sponsor", :style => :bold
    pdf.text "#{@survey.sponsor.name_and_location}"
  end

  pdf.pad_top(inner_padding) do 
    pdf.text "Invitation List", :style => :bold
  end

  @invitations.each do |invitation| 
    pdf.text "#{format_invitation(invitation)}"
  end

  pdf.pad_top(inner_padding) do 
    pdf.text "#{@survey.participations.count} firms participating"
  end
  
    pdf.table(
      [[
        "<b>Effective Date</b>",
        " #{@survey.effective_date.to_s(:long_ordinal)}",
        "<b>Completion Date</b>",
        " #{@survey.end_date.to_date.to_s(:long_ordinal)}",
      ]],  
      :border_width => 0, 
      :horizontal_padding => 0, 
      :width => pdf.margin_box.width, 
      :align => { 0=> :left, 1 => :left, 2 => :right, 3 => :left},
      :column_widths => {0 => 73, 1 => 110, 2 => 90, 3 => 110})
  
  # end: survey metadata
  pdf.pad_top(inner_padding) do 
    pdf.horizontal_rule 
  end

  # questions
  @survey.questions.each do |question|
    pdf.pad_top(outer_padding) do   
      pdf.text "#{question.text}", :style => :bold
    end   
    if question.adequate_responses? then
      pdf.pad_top(inner_padding) do
        render :partial=> "#{question.report_type}.pdf.prawn",  :locals=>{:p_pdf=>pdf, :question => question, :format => @format}
      end 
      if question.comments.any? then
        pdf.pad_top(inner_padding) do
          pdf.text "Comments", :style => :bold, :size => 10
          question.comments.each do |comment|          
            pdf.text "#{comment}", :size => 10
          end
        end
      end
    else
      pdf.text "Results not available due to insufficient responses."
    end
  end

end


