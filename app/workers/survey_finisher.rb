# This worker finishes a survey.
class SurveyFinisher < BeanstalkWorker
  def finish(options)
    survey = Survey.find(options[:id])
    
    survey.finish! unless (survey.nil? || survey.finished?)
    
    job.delete
  end
end