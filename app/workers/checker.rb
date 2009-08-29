# Checker checks for surveys that need to finish up and creates jobs for them.
class Checker < BeanstalkWorker
  def check_for_closed_surveys(payload)
    surveys = Survey.with_aasm_state(:running).find(:all, :conditions => ['end_date < ?', Time.now])
    
    surveys.each do |survey|
      # spin up a job for finishing the surveys.
      Beanstalker.run(:survey_finisher, :finish, :id => survey.id)
    end
    
    # check every 10 seconds
    job.release(job.pri, 10)
  end
end
