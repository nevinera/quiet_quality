require "rspec"
require "rspec/its"
require "pry"

if ENV["SIMPLECOV"]
  require "simplecov"

  class ProblemsFormatter
    def format(result)
      warn result.groups.map { |name, files| format_group(name, files) }
    end

    private

    def format_group(name, files)
      problem_files = files.select { |f| f.covered_percent < 100.0 }
      if problem_files.any?
        header = "#{name}: coverage missing\n"
        rows = problem_files.map { |f| "    #{f.filename} (#{f.covered_percent.round(2)}%)\n" }
        ([header] + rows).join
      else
        "#{name}: fully covered\n"
      end
    end
  end

  SimpleCov.start do
    formatter(ProblemsFormatter) if ENV["SIMPLECOV_TEXT"]
    add_group "Tools", "lib/quiet_quality/tools/"
    minimum_coverage line: 100
    add_filter "spec/"
  end
end

require File.expand_path("../../lib/quiet_quality", __FILE__)

gem_root = File.expand_path("../..", __FILE__)
FIXTURES_DIRECTORY = File.join(gem_root, "spec", "fixtures")
TEMP_DIRECTORY = File.join(gem_root, "tmp")

support_glob = File.join(gem_root, "spec", "support", "**", "*.rb")
Dir[support_glob].sort.each { |f| require f }

def fixture_path(*parts)
  File.join(FIXTURES_DIRECTORY, *parts)
end

def fixture_content(*parts)
  File.read(fixture_path(*parts))
end

def fixture_json(*parts)
  JSON.parse(fixture_content(*parts))
end

def tmp_path(*parts)
  File.join(TEMP_DIRECTORY, *parts)
end

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.mock_with :rspec
  config.order = "random"
  config.tty = true
end
