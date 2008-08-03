require 'rubygems'
require 'daemons'

Daemons.run(File.join(File.dirname(__FILE__), 'beanstalk_dispatcher.rb'),
  :backtrace => true,
  :dir => '../log',
  :dir_mode => :script,
  :log_output => true,
  :monitor => true
)
