# This is the base class for our beanstalk workers.  Inherit from this bad boy
# to create a new worker.
class BeanstalkWorker
  def initialize(job)
    @job = job
  end
  
  # default work - just delete.
  def work(body)
    job.delete
  end
  
  private
  
  def job
    @job
  end
end