module QuietQuality
  module Tools
    module Standardrb
      class Parser < Rubocop::Parser
        def tool_name
          TOOL_NAME
        end
      end
    end
  end
end
