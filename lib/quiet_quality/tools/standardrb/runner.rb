module QuietQuality
  module Tools
    module Standardrb
      class Runner < Rubocop::Runner
        def command_name
          "standardrb"
        end
      end
    end
  end
end
