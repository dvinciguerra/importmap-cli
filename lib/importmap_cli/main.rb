# frozen_string_literal: true

require 'importmap_cli/commands/base_command'
require 'importmap_cli/commands/add'
require 'importmap_cli/commands/remove'
require 'importmap_cli/commands/json'
require 'importmap_cli/commands/audit'
require 'importmap_cli/commands/outdated'
require 'importmap_cli/commands/update'
require 'importmap_cli/commands/packages'

module ImportmapCLI
  # adr cli main command line entry point class
  class Main
    def add(packages:, options:)
      Commands::Add.new(packages:, options:).run
    end

    def remove(packages:, options:)
      Commands::Remove.new(packages:, options:).run
    end

    def json
      Commands::Json.new.run
    end

    def audit
      Commands::Audit.new.run
    end

    def outdated
      Commands::Outdated.new.run
    end

    def update
      Commands::Update.new.run
    end

    def packages
      Commands::Packages.new.run
    end
  end
end
