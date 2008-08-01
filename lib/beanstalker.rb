module Beanstalker
  def self.run(worker, method, payload, delay = 0)
    BEANSTALK.yput({:worker => worker, :method => method, :payload => payload})
  end
end