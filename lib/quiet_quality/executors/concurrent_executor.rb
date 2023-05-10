module QuietQuality
  module Executors
    class ConcurrentExecutor < BaseExecutor
      def execute!
        threads = pipelines.map { |pipeline| threaded_pipeline(pipeline) }
        threads.each(&:join)
        pipelines.none?(&:failure?)
      end

      private

      def threaded_pipeline(pipeline)
        Thread.new do
          pipeline.outcome
          pipeline.messages
        end
      end
    end
  end
end
