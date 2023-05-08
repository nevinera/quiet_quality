module QuietQuality
  module VersionControlSystems
    class Git
      attr_reader :git

      #
      # Initializer
      #
      # @param [String] path Path to git repository
      #
      def initialize(path = ".")
        @git = ::Git.open(path)
      end

      # Retrieves the files changed in the given commit compared to the base. When no base is given,
      # the default branch is used as the base. When no sha is given, the HEAD commit is used.
      # Optionally, uncommitted changes can be included in the result, as well as untracked files.
      #
      # @param [String] base The base commit to compare against
      # @param [String] sha The commit to compare
      # @param [Boolean] include_uncommitted Whether to include uncommitted changes
      # @param [Boolean] include_untracked Whether to include untracked files
      #
      # @return [Hash] A hash of file paths and the files changed in those files as a Set
      def changed_files(base: nil, sha: "HEAD", include_uncommitted: true, include_untracked: false)
        base_commit = comparison_base(sha: sha, comparison_branch: base || default_branch)
        [
          committed_changed_files(base_commit, sha),
          include_uncommitted ? uncommitted_changed_files : nil,
          include_untracked ? untracked_changed_files : nil
        ].compact.reduce(&:merge)
      end

      #
      # The default branch for the default remote for the local git repository
      #
      # @return [String] Branch name
      def default_branch
        self.class.default_branch(remote: git.remote.url)
      end

      #
      # The default branch for the given remote
      #
      # @param [String] remote The remote repository url
      # @return [String] Branch name
      #
      def self.default_branch(remote:)
        ::Git.default_branch(remote)
      end

      #
      # Determines the nearest common ancestor for the given `sha` compared to the `branch`.
      #
      # @param [String] sha The git SHA of the commit
      # @param [String] comparison_branch The comparison branch
      #
      # @return [String] The nearest common ancestor (SHA)
      #
      def comparison_base(sha:, comparison_branch:)
        git.merge_base(comparison_branch, sha).first.sha
      end

      private

      def changed_lines_for(diff)
        GitDiffParser.parse(diff).flat_map do |parsed_diff|
          parsed_diff.changed_line_numbers.to_set
        end
      end

      def committed_changed_files(base, sha)
        ChangedFiles.new(committed_changes(base, sha))
      end

      def committed_changes(base, sha)
        patch = git.diff(base, sha).patch
        GitDiffParser.parse(patch).map { to_changed_file(_1) }
      end

      def to_changed_file(patch_file)
        ChangedFile.new(path: patch_file.file, lines: patch_file.changed_line_numbers.to_set)
      end

      def uncommitted_changed_files
        ChangedFiles.new(uncommitted_changes)
      end

      def uncommitted_changes
        patch = git.diff.patch
        GitDiffParser.parse(patch).map { to_changed_file(_1) }
      end

      def untracked_changed_files
        ChangedFiles.new(untracked_changes)
      end

      def untracked_changes
        git.status.untracked.map { |status| status[0] }.map do |file_path|
          ChangedFile.new(path: file_path, lines: :all)
        end
      end
    end
  end
end
