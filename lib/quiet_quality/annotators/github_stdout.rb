module QuietQuality
  module Annotators
    class GithubStdout
      # github will only accept the first 10 annotations of each type in this form.
      MAX_ANNOTATIONS = 10

      def initialize(output_stream: $stdout)
        @output_stream = output_stream
      end

      def annotate!(messages)
        messages.first(MAX_ANNOTATIONS).each do |message|
          output_stream.puts self.class.format(message)
        end
      end

      # Example annotation output from github's docs:
      # ::warning file={name},line={line},title={title}::{message}
      # See https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-a-warning-message
      def self.format(message)
        title = message.tool_name.to_s
        title += " #{message.rule}" if message.rule
        attributes = {
          file: message.path,
          line: message.annotated_line || message.start_line,
          title: title
        }.compact

        attributes_string = attributes.map { |k, v| "#{k}=#{v}" }.join(",")
        "::warning #{attributes_string}::#{message.body}"
      end

      private

      attr_reader :output_stream
    end
  end
end
