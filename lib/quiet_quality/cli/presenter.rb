module QuietQuality
  module Cli
    class Presenter
      def initialize(stream:, options:, outcomes:, messages:)
        @stream = stream
        @options = options
        @outcomes = outcomes
        @messages = messages
      end

      def log_results
        return if options.quiet?

        if options.light?
          log_light_outcomes
        else
          log_outcomes
          log_messages
        end
      end

      private

      attr_reader :stream, :options, :outcomes, :messages

      def failed_outcomes
        @_failed_outcomes ||= outcomes.select(&:failure?)
      end

      def successful_outcomes
        @_successful_outcomes ||= outcomes.select(&:success?)
      end

      def colorize(color_name, s)
        return s unless options.colorize?
        Colorize.colorize(s, color: color_name)
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
        stream.puts line
      end

      def log_outcomes
        outcomes.each do |outcome|
          if outcome.success?
            stream.puts "--- " + colorize(:green, "Passed: #{outcome.tool}")
          else
            stream.puts "--- " + colorize(:red, "Failed: #{outcome.tool}")
          end
        end
      end

      def log_messages
        return unless messages.any?
        stream.puts "\n\n#{messages.count} messages:"
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

      def locally_formatted_message(msg)
        tool = colorize(:yellow, msg.tool_name)
        line_range = line_range_for(msg)
        rule_string = msg.rule ? "  [#{colorize(:yellow, msg.rule)}]" : ""
        truncated_body = reduce_text(msg.body, 120)
        "#{tool}  #{msg.path}:#{line_range}#{rule_string}  #{truncated_body}"
      end

      def loggable_message(msg)
        if options.message_format
          message_formatter.format(msg)
        else
          stream.puts locally_formatted_message(msg)
        end
      end

      def log_message(msg)
        stream.puts loggable_message(msg)
      end

      def message_formatter
        @_message_formatter ||= MessageFormatter.new(message_format: options.message_format)
      end
    end
  end
end
