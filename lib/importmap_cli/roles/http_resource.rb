# frozen_string_literal: true

require 'net/http'

module ImportmapCLI
  module Roles
    # role that inject behaviour for http resources
    module HttpResource
      protected

      # performe a http post request
      def http_post(url, body, headers = { 'Content-Type' => 'application/json' })
        Net::HTTP.post(url, body, headers)
      rescue StandardError => e
        raise HTTPError, "[error] unexpected transport error (#{e.class}: #{e.message})"
      end

      # check http status code and performa a block
      def http_status?(response, code, &block)
        block.call if response.code == code.to_s
      end
    end
  end
end
