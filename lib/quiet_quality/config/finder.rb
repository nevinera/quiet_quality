module QuietQuality
  module Config
    class Finder
      CONFIG_FILENAME = ".quiet_quality.yml"
      MAXIMUM_SEARCH_DEPTH = 100

      def initialize(from:)
        @from = from
      end

      def config_path
        return @_config_path if defined?(@_config_path)
        each_successive_enclosing_directory do |dir_path|
          file_path = dir_path.join(CONFIG_FILENAME)
          if file_path.exist?
            return @_config_path = file_path.to_s
          end
        end
        @_config_path = nil
      rescue Errno::EACCES
        @_config_path = nil
      end

      private

      attr_reader :from

      def config_path_within(dir)
        File.join(dir, CONFIG_FILENAME)
      end

      def each_successive_enclosing_directory(max_depth: 100, &block)
        d = Pathname.new(from)
        depth = 0
        MAXIMUM_SEARCH_DEPTH.times do
          block.call(d.expand_path)
          d = d.parent
          depth += 1
          return nil if d.root?
        end
        nil
      end
    end
  end
end
