module QuietQuality
  class ChangedFiles
    attr_reader :files

    def initialize(files)
      @files = files
    end

    def paths
      @_paths ||= files.map(&:path)
    end

    def file(path)
      files_by_path.fetch(path, nil)
    end

    def include?(path)
      files_by_path.include?(path)
    end

    def merge(other)
      merged_files = []
      (files + other.files)
        .group_by(&:path)
        .each_pair { |_path, pfiles| merged_files << pfiles.reduce(&:merge) }
      self.class.new(merged_files)
    end

    private

    def files_by_path
      @_files_by_path ||= files.map { |f| [f.path, f] }.to_h
    end
  end
end
