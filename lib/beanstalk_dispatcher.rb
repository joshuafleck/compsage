if !defined?(RAILS_ROOT) then
  ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'development'
  require File.dirname(__FILE__) + '/../config/environment'
else
  # Get back to RAILS_ROOT.
  Dir.chdir(RAILS_ROOT)

  # Load our Rails environment.
  require File.join('config', 'environment')
end

loop do
  job = BEANSTALK.reserve
  body = job.ybody
  
  worker_klass = body[:worker].to_s.classify.constantize || BeanstalkWorker
  worker = worker_klass.new(job)
  
  if worker.respond_to?(body[:method]) then
    worker.send(body[:method], body[:payload])
  else
    worker.work(body[:payload])
  end
end
