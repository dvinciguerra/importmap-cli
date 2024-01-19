# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'
require 'fileutils'

module ImportmapCLI
  module Commands
    class Add < BaseCommand
      include ImportmapCLI::Roles::HttpResource

      RESOURCE_URL = URI('https://api.jspm.io/generate').freeze

      def initialize(packages:, options:)
        @packages = packages
        @options = options
      end

      def run
        response = http_post(RESOURCE_URL, request_body)

        http_status?(response, 200) do
          payload = parse_importmap(response)

          # ensure vendor directory exists
          FileUtils.mkdir_p("#{ImportmapCLI.current_dir}/vendor/javascript")

          # ensure importmap.rb exists
          unless File.exist?("#{ImportmapCLI.current_dir}/config/importmap.rb")
            puts "[error] #{ImportmapCLI.current_dir}/config/importmap.rb file does not exist"
            exit 1
          end

          @importmap = File.read("#{ImportmapCLI.current_dir}/config/importmap.rb")

          payload.fetch(:imports, {}).each do |package, url|
            puts "[info] pinning #{package} to #{url}"

            unless @importmap.match?(/^pin\s+['"]#{package}["']/)
              @importmap = "#{@importmap}\npin '#{package}', to: '#{url}' # #{package_version_from(url)}"
            end
          end

          File.write("#{ImportmapCLI.current_dir}/config/importmap.rb", @importmap)
        end
      end

      private

      def same_filename?(package, filename)
        "#{package.gsub('/', '--')}.js" == filename
      end

      def package_version_from(url)
        url.scan(/@(\d+\.\d+.\d+)/)&.flatten&.first
      end

      def request_body
        {
          'install' => Array(@packages),
          'flattenScope' => true,
          'env' => ['browser', 'module', @options[:env]],
          'provider' => @options[:from].to_s
        }.to_json
      end

      def parse_importmap(response)
        JSON.parse(response.body, symbolize_names: true).fetch(:map, {})
      rescue StandardError
        puts '[error] unexpected error parsing importmap'
        exit(1)
      end
    end
  end
end
