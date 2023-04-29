module QuietQuality
  class ChangedFiles
    attr_reader :files

    def initialize(files)
      @files = files
    end

    def file(path)
      files_by_path.fetch(path, nil)
    end

    def include?(path)
      files_by_path.include?(path)
    end

    private

    def files_by_path
      @_files_by_path ||= files.map { |f| [f.path, f] }.to_h
    end
  end
end
