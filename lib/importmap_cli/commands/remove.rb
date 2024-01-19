# frozen_string_literal: true

module ImportmapCLI
  module Commands
    class Remove
      def initialize(packages:, options:)
        @packages = packages
        @options = options
      end

      def run
        pp [:unpin, @packages, @options]
      end
    end
  end
end
