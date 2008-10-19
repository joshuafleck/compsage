require 'rake'
# rebuilds the sphinx indexes at a specified interval
class Rebuilder < BeanstalkWorker
  
  def rebuild_sphinx_indexes(payload)
    Rake::Task["ts:index"].invoke

    # rebuild once a day
    job.release(job.pri,86400)
  end
end
