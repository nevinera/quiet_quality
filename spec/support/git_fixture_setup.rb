require "fileutils"
require "open3"

module GitFixtureSetup
  REPO_PATH = File.join(TEMP_DIRECTORY, "repo")

  def self.install
    return if Dir.exist?(REPO_PATH)

    tgz_path = fixture_path("git-diff-parser", "repo.tgz")
    _out, err, stat = Open3.capture3("tar", "xvzf", tgz_path, "-C", TEMP_DIRECTORY)
    if stat.success?
      warn "extracted repo.tgz into tmp/repo/"
    else
      warn err
      fail "Failed status from tar: #{stat.exitstatus}"
    end
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    GitFixtureSetup.install
  end
end
