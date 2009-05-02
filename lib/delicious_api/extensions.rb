require 'active_support'

Dir[File.dirname(__FILE__) + "/extensions/*.rb"].sort.each do |path|
  require path
end