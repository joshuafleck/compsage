# This worker finishes a survey.
class SurveyFinisher < BeanstalkWorker
  def finish(options)
    begin
      survey = Survey.find(options[:id])
      survey.finish! if survey && survey.running? 
    rescue ActiveRecord::RecordNotFound
      # Survey isn't there anymore, must have been deleted or somesuch.
    end
    job.delete
  end
end
