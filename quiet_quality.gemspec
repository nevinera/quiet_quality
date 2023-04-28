require_relative "lib/quiet_quality/version"

Gem::Specification.new do |spec|
  spec.name = "quiet_quality"
  spec.version = QuietQuality::VERSION
  spec.authors = ["Eric Mueller"]
  spec.email = ["nevinera@gmail.com"]

  spec.summary = "A system for comparing quality tool outputs against the forward diffs"
  spec.description = <<~DESC
    Allow your CI to notice and/or annotate new quality issues, despite the presences of
    many pre-existing issues in your codebase.
  DESC
  spec.homepage = "https://github.com/nevinera/quiet_quality"
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.require_paths = ["lib"]
  spec.bindir = "bin"
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`
      .split("\x0")
      .reject { |f| f.start_with?("spec") }
  end
  spec.executables = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z bin/`
      .split("\x0")
      .map { |path| path.sub(/^bin\//, "") }
  end

  spec.add_dependency "git", "~> 1.18"

  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency "simplecov", "~> 0.22.0"
  spec.add_development_dependency "pry", "~> 0.14"
  spec.add_development_dependency "standard", "~> 1.28"
  spec.add_development_dependency "rubocop", "~> 1.50"
end
