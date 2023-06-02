module QuietQuality
  module Executors
    class BaseExecutor
      def initialize(tools:, changed_files: nil)
        @tools = tools
        @changed_files = changed_files
      end

      def execute!
        pipelines.none?(&:failure?)
      end

      def outcomes
        @_outcomes ||= pipelines.map(&:outcome)
      end

      def messages
        @_messages ||= Messages.new(pipelines.map(&:messages).map(&:all).reduce(&:+))
      end

      def any_failure?
        pipelines.any?(&:failure?)
      end

      def successful_outcomes
        @_successful_outcomes ||= outcomes.select(&:success?)
      end

      def failed_outcomes
        @_failed_outcomes ||= outcomes.select(&:failure?)
      end

      private

      attr_reader :tools, :changed_files

      def pipelines
        @_pipelines ||= tools.map do |topts|
          Pipeline.new(tool_options: topts, changed_files: changed_files)
        end
      end
    end
  end
end
