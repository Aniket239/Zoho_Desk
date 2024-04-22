# config/puma.rb
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }
