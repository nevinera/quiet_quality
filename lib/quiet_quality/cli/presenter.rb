module QuietQuality
  module Cli
    class Presenter
      COLORS = {red: 31, green: 32, yellow: 33}.freeze

      def initialize(logger:, logging:, outcomes:, messages:)
        @logger = logger
        @logging = logging
        @outcomes = outcomes
        @messages = messages
      end

      def log_results
        return if logging.quiet?

        if logging.light?
          log_light_outcomes
        else
          log_outcomes
          log_messages
        end
      end

      private

      attr_reader :logger, :logging, :outcomes, :messages

      def failed_outcomes
        @_failed_outcomes ||= outcomes.select(&:failure?)
      end

      def successful_outcomes
        @_successful_outcomes ||= outcomes.select(&:success?)
      end

      def colorize(color, s)
        return s unless logging.colorize?
        color_code = COLORS.fetch(color)
        "\e[#{color_code}m#{s}\e[0m"
      end

      def failed_tools_text
        colorize(:red, " (#{failed_outcomes.map(&:tool).join(", ")})")
      end

      def log_light_outcomes
        line = "%d tools executed: %d passed, %d failed" % [
          outcomes.count,
          successful_outcomes.count,
          failed_outcomes.count
        ]
        line += failed_tools_text if failed_outcomes.any?
        logger.puts line
      end

      def log_outcomes
        outcomes.each do |outcome|
          if outcome.success?
            logger.puts "--- " + colorize(:green, "Passed: #{outcome.tool}")
          else
            logger.puts "--- " + colorize(:red, "Failed: #{outcome.tool}")
          end
        end
      end

      def log_messages
        return unless messages.any?
        logger.puts "\n\n#{messages.count} messages:"
        messages.each { |msg| log_message(msg) }
      end

      def line_range_for(msg)
        if msg.start_line == msg.stop_line
          msg.start_line.to_s
        else
          "#{msg.start_line}-#{msg.stop_line}"
        end
      end

      def reduce_text(s, length)
        s.gsub(/ *\n */, "\\n").slice(0, length)
      end

      def log_message(msg)
        tool = colorize(:yellow, msg.tool_name)
        line_range = line_range_for(msg)
        rule_string = msg.rule ? "  [#{colorize(:yellow, msg.rule)}]" : ""
        truncated_body = reduce_text(msg.body, 120)
        logger.puts "#{tool}  #{msg.path}:#{line_range}#{rule_string}  #{truncated_body}"
      end
    end
  end
end
