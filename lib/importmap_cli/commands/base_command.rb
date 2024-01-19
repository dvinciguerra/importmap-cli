# frozen_string_literal: true

module ImportmapCLI
  module Commands
    # Base class for all commands
    class BaseCommand
      protected

      def current_dir
        ImportmapCLI.current_dir
      end
    end
  end
end
