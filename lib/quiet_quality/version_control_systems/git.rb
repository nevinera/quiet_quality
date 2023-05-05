module QuietQuality
  module VersionControlSystems
    class Git
      attr_reader :git

      #
      # Initializer
      #
      # @param [String] path Path to git repository
      #
      def initialize(path)
        @git = ::Git.open(path)
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
    end
  end
end
