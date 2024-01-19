# frozen_string_literal: true

module ImportmapCLI
  module Commands
    # Class that generates importmap in json format
    class Json < BaseCommand
      def run
        # ensure importmap.rb exists
        unless File.exist?("#{ImportmapCLI.current_dir}/config/importmap.rb")
          puts "[error] #{ImportmapCLI.current_dir}/config/importmap.rb file does not exist"
          exit 1
        end

        imports = {}

        importmap_each_pin do |_line, matcher|
          package, url = matcher.values_at(:package, :url)

          imports.update(package => url)
        end

        puts JSON.pretty_generate({ imports: imports })
      end

      private

      def importmap_each_pin(&block)
        File.readlines("#{ImportmapCLI.current_dir}/config/importmap.rb").each do |line|
          line.chomp!
          next if line.empty? || !line.match(/^pin\s+["'](?<package>.*)['"],\s+to:\s+["'](?<url>.*)['"]/)

          block.call(line, Regexp.last_match)
        end
      end
    end
  end
end
