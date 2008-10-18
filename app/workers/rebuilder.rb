require 'rake'
# rebuilds the sphinx indexes at a specified interval
class Rebuilder < BeanstalkWorker
  
  def rebuild_sphinx_indexes(payload)
    Rake::Task["ts:index"].invoke

    # rebuild every 60 minutes
    job.release(job.pri,3600)
  end
end
