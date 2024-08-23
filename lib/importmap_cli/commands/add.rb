# frozen_string_literal: true

require 'uri'
require 'yaml'
require 'json'
require 'net/http'
require 'fileutils'

module ImportmapCLI
  module Commands
    class Add < BaseCommand
      include ImportmapCLI::Roles::HttpResource

      RESOURCE_URL = URI('https://api.jspm.io/generate').freeze

      def initialize(packages:, options:)
        @options = Hash(options)
        @packages = current_packages + packages
      end

      def run
        response = http_post(RESOURCE_URL, request_body)

        http_status?(response, 200) do
          payload = parse_importmap(response)

          # ensure vendor directory exists
          FileUtils.mkdir_p("#{ImportmapCLI.current_dir}/vendor/javascript")

          # ensure importmap.rb exists
          unless File.exist?("#{ImportmapCLI.current_dir}#{filename}")
            puts "[error] #{ImportmapCLI.current_dir}#{filename} file does not exist"
            exit 1
          end

          importmap_generated = build_importmap(payload)
          File.write("#{ImportmapCLI.current_dir}#{filename}", importmap_generated)
        end
      end

      private

      def filename
        @filename ||= "/config/importmap.#{file_extension}"
      end

      def file_extension
        @file_extension ||= Hash(@options).fetch('format', 'rb')
      end

      def same_filename?(package, filename)
        "#{package.gsub('/', '--')}.js" == filename
      end

      def package_version_from(url)
        url.scan(/@(\d+\.\d+.\d+)/)&.flatten&.first
      end

      def current_packages
        file_content = File.read("#{ImportmapCLI.current_dir}#{filename}")

        case file_extension
        when 'json'
          JSON.parse(file_content, symbolize_names: true).fetch(:imports, {}).keys
        when 'yaml'
          YAML.load(file_content).fetch(:imports, {}).keys
        else
          file_content.scan(/pin\s+['"](.+)['"],?.*/).flatten
        end
      end

      def build_importmap(payload)
        case file_extension
        when 'json'
          JSON.pretty_generate(payload)
        when 'yaml'
          YAML.dump(payload)
        else
          importmap = ''

          payload.fetch(:imports, {}).each do |package, url|
            puts "[info] pinning #{package} to #{url}"
            importmap += "#{importmap}\npin '#{package}', to: '#{url}' # #{package_version_from(url)}"
          end

          importmap
        end
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
