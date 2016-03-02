ENV['RACK_ENV'] = "production"

require File.expand_path '../app.rb', __FILE__

run Application
