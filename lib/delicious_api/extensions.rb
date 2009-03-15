require 'active_support'

Dir[File.dirname(__FILE__) + "/extensions/*.rb"].sort.each do |path|
  filename = File.basename(path, '.rb')
  require "extensions/#{filename}"
end