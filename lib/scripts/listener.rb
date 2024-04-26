# config/initializers/listener.rb
require 'listen'

if Rails.env.development?
  listener = Listen.to('app/services', only: /\.rb$/) do |modified, added, removed|
    puts "Detected changes in services, restarting scheduler..."
    Thread.kill(@scheduler_thread) if @scheduler_thread
    @scheduler_thread = Thread.new { run_scheduler }
  end
  listener.start
end
