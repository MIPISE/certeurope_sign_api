require "net/http"
require "base64"

module CerteuropeSignAPI
  module HTTPCall
    class << self
      {
        delete: false,
        get: false,
        patch: true,
        post: true
      }.each do |method, include_data|
        if include_data
          define_method(method.to_s) do |uri, body|
            request(uri, body: body, method: method.to_s.upcase)
          end
        else
          define_method(method.to_s) do |uri|
            request(uri, method: method_name.to_s.upcase)
          end
        end
      end

      private

      def request(uri, body: nil, method: "GET")
        raise GemNotInitialized if CerteuropeSignAPI.base_uri.nil?

        full_path = "/#{uri}"
        url = URI.parse("#{CerteuropeSignAPI.base_uri}#{full_path}")
        data = body.camelize_hash_keys.to_json
        headers = request_headers

        prepare_http_request(url)
          .send_request(method, full_path, data, headers)
      end

      def request_headers
        {
          "Content-Type" => "application/json"
        }
      end

      def prepare_http_request(uri)
        http = Net::HTTP.new(uri.host, uri.port)

        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.cert = CerteuropeSignAPI.certificate
        http.key = CerteuropeSignAPI.key

        http
      end
    end
  end
end
