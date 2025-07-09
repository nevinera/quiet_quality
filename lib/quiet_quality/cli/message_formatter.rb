module QuietQuality
  module Cli
    class MessageFormatter
      TOKEN_MATCHING_REGEX = %r{%[a-z]*-?\d+(?:tool|loc|level|path|lines|rule|body)}

      def initialize(message_format:)
        @message_format = message_format
      end

      def format(message)
        formatted_tokens = parsed_tokens.map { |pt| FormattedToken.new(parsed_token: pt, message: message) }
        formatted_tokens.reduce(message_format) do |interpolating, ftok|
          interpolating.gsub(ftok.token, ftok.formatted_token)
        end
      end

      private

      attr_reader :message_format

      def tokens
        @_tokens ||= message_format.scan(TOKEN_MATCHING_REGEX)
      end

      def parsed_tokens
        @_parsed_tokens ||= tokens.map { |tok| ParsedToken.new(tok) }
      end

      class ParsedToken
        TOKEN_PARSING_REGEX = %r{
          %                                               # start the interplation token
          (?<just>[lr])?                                  # specify the justification
          (?<trunc>[bem])?                                # where to truncate from
          (?<color>yellow|red|green|blue|cyan|none)?      # what color
          (?<size>-?\d+)                                  # string size (may be negative)
          (?<source>tool|loc|level|path|lines|rule|body)  # data source name
        }x

        COLORS = {
          "yellow" => :yellow,
          "red" => :red,
          "green" => :green,
          "blue" => :light_blue,
          "cyan" => :light_cyan,
          "none" => nil
        }.freeze

        JUSTIFICATIONS = {"l" => :left, "r" => :right}.freeze
        TRUNCATIONS = {"b" => :beginning, "m" => :middle, "e" => :ending}.freeze

        def initialize(token)
          @token = token
        end

        attr_reader :token

        def justification
          JUSTIFICATIONS.fetch(token_pieces[:just]&.downcase, :left)
        end

        def truncation
          TRUNCATIONS.fetch(token_pieces[:trunc]&.downcase, :ending)
        end

        def color
          COLORS.fetch(token_pieces[:color]&.downcase, nil)
        end

        def size
          raw_size.abs
        end

        def source
          token_pieces[:source]
        end

        def allow_pad?
          raw_size.positive?
        end

        def allow_truncate?
          !raw_size.zero?
        end

        private

        def token_pieces
          @_token_pieces ||= token.match(TOKEN_PARSING_REGEX)
        end

        def raw_size
          @_raw_size ||= token_pieces[:size].to_i
        end
      end
      private_constant :ParsedToken

      class FormattedToken
        def initialize(parsed_token:, message:)
          @parsed_token = parsed_token
          @message = message
        end

        def formatted_token
          colorized(padded(truncated(base_string)))
        end

        def token
          parsed_token.token
        end

        private

        attr_reader :parsed_token, :message

        def line_range
          if message.start_line == message.stop_line
            message.start_line.to_s
          else
            "#{message.start_line}-#{message.stop_line}"
          end
        end

        def base_value
          case parsed_token.source
          when "tool" then message.tool_name
          when "loc" then location_string
          when "level" then message.level
          when "path" then message.path
          when "lines" then line_range
          when "rule" then message.rule
          when "body" then flattened_body
          end
        end

        def base_string
          base_value.to_s
        end

        def location_string
          "#{message.path}:#{line_range}"
        end

        def flattened_body
          message.body.gsub(/ *\n */, "\\n")
        end

        def truncated(s)
          return s unless parsed_token.allow_truncate?
          return s if s.length <= parsed_token.size
          size = parsed_token.size

          case parsed_token.truncation
          when :beginning then truncate_beginning(s, size)
          when :middle then truncate_middle(s, size)
          when :ending then truncate_ending(s, size)
          end
        end

        def truncate_beginning(s, size)
          "…" + s.slice(1 - size, size - 1)
        end

        def truncate_middle(s, size)
          front_len = (size / 2.0).floor
          back_len = (size / 2.0).ceil - 1
          s.slice(0, front_len) + "…" + s.slice(-back_len, back_len)
        end

        def truncate_ending(s, size)
          s.slice(0, size - 1) + "…"
        end

        def padded(s)
          return s unless parsed_token.allow_pad?
          return s if s.length >= parsed_token.size

          case parsed_token.justification
          when :left then s.ljust(parsed_token.size)
          when :right then s.rjust(parsed_token.size)
          end
        end

        def colorized(s)
          if parsed_token.color.nil?
            s
          else
            Colorize.colorize(s, color: parsed_token.color)
          end
        end
      end
      private_constant :FormattedToken
    end
  end
end
