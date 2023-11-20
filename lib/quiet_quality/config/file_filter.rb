module QuietQuality
  module Config
    class FileFilter
      # * regex is a regex string
      # * excludes is an array of regex strings OR a single regex string
      def initialize(regex: nil, excludes: nil)
        @regex_string = regex
        @excludes_strings = excludes
      end

      attr_reader :regex_string, :excludes_strings

      def regex
        return nil if @regex_string.nil?
        @_regex ||= Regexp.new(@regex_string)
      end

      def excludes
        return @_excludes if defined?(@_excludes)

        @_excludes =
          if @excludes_strings.nil?
            nil
          elsif @excludes_strings.is_a?(String)
            [Regexp.new(@excludes_strings)]
          else
            @excludes_strings.map { |xs| Regexp.new(xs) }
          end
      end

      # The filter _overall_ matches if:
      # (a) the regex either matches or is not supplied AND
      # (b) either none of the excludes match or none are supplied
      def match?(s)
        regex_match?(s) && !excludes_match?(s)
      end

      def ==(other)
        regex_string == other.regex_string && excludes_strings.sort == other.excludes_strings.sort
      end

      private

      # The regex is an allow-match - if it's not supplied, treat everything as matching.
      def regex_match?(s)
        return true if regex.nil?
        regex.match?(s)
      end

      # The excludes are a list of deny-matches - if they're not supplied, treat _nothing_
      # as matching.
      def excludes_match?(s)
        return false if excludes.nil? || excludes.empty?
        excludes.any? { |exclude| exclude.match?(s) }
      end
    end
  end
end
