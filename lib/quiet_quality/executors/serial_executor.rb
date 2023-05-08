module QuietQuality
  module Executors
    class SerialExecutor
      def initialize(tools:, changed_files: nil)
        @tools = tools
        @changed_files = changed_files
      end

      def execute!
        pipelines.each do |pipeline|
          pipeline.outcome
          pipeline.messages
        end
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

      private

      attr_reader :tools, :changed_files

      def pipelines
        @_pipelines ||= tools.map do |topts|
          Pipeline.new(tool_options: topts, changed_files: changed_files)
        end
      end

      def pipeline_by_tool
        @_pipeline_by_tool ||= pipelines
          .map { |p| [p.tool_name, p] }
          .to_h
      end

      def pipeline_for(tool)
        pipeline_by_tool.fetch(tool.to_sym)
      end
    end
  end
end
