# This worker finishes a survey.
class SurveyFinisher < BeanstalkWorker
  def finish(options)
    survey = Survey.find(options[:id])
    
    survey.finish! if survey && survey.running? 
    
    job.delete
  end
end
