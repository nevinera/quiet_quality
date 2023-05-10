module QuietQuality
  module VersionControlSystems
    Error = Class.new(QuietQuality::Error)
  end
end

glob = File.expand_path("../version_control_systems/*.rb", __FILE__)
Dir[glob].sort.each { |file| require file }
