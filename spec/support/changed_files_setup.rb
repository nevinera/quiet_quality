module ChangedFilesSetup
  def generate_changed_file(path:, lines:)
    QuietQuality::ChangedFile.new(path: path, lines: lines)
  end

  def generate_changed_files(pairs)
    changed_file_objects = pairs.map { |path, lines| generate_changed_file(path: path, lines: lines) }
    QuietQuality::ChangedFiles.new(changed_file_objects)
  end

  def fully_changed_files(*paths)
    generate_changed_files(paths.map { |p| [p, :all] }.to_h)
  end

  def empty_changed_files
    QuietQuality::ChangedFiles.new([])
  end
end

RSpec.configure do |config|
  config.include ChangedFilesSetup
end
