module QuietQuality
  module Tools
    module HamlLint
    end
  end
end

glob = File.expand_path("../haml_lint/*.rb", __FILE__)
Dir.glob(glob).sort.each { |f| require f }
