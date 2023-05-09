require_relative "./base_executor"

module QuietQuality
  module Executors
    class SerialExecutor < BaseExecutor
      def execute!
        pipelines.each do |pipeline|
          pipeline.outcome
          pipeline.messages
        end
        pipelines.none?(&:failure?)
      end
    end
  end
end
