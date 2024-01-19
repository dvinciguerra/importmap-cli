# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('./', __dir__))

require 'logger'
require 'fileutils'

require 'importmap_cli/version'
require 'importmap_cli/roles/http_resource'
require 'importmap_cli/main'

# adr cli root module
module ImportmapCLI
  class Error < StandardError; end

  CURRENT_DIR = FileUtils.pwd.freeze

  class << self
    # application logger
    def logger
      @logger ||= Logger.new($stdout)
    end

    # current directory
    def current_dir
      ImportmapCLI::CURRENT_DIR
    end
  end
end
