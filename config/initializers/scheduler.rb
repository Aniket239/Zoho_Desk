require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '1m' do
    tickets_closure_path
    p "Hello, World2!"
  end