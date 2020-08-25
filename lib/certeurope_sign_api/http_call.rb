require "net/http"

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
            request(uri, method: method.to_s.upcase)
          end
        end
      end

      private

      def request(uri, body: nil, method: "GET")
        raise GemNotInitialized if CerteuropeSignAPI.base_uri.nil?

        full_path = "/#{uri}"
        url = URI.parse("#{CerteuropeSignAPI.base_uri}#{full_path}")
        data = CerteuropeSignAPI.camelize_hash_keys(body).to_json
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
        http =
          if CerteuropeSignAPI.proxy_url
            p_uri = URI.parse(CerteuropeSignAPI.proxy_url)
            Net::HTTP.new(uri.host, uri.port, p_uri.hostname, p_uri.port, p_uri.user, p_uri.password)
          else
            Net::HTTP.new(uri.host, uri.port)
          end

        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.cert = CerteuropeSignAPI.certificate
        http.key = CerteuropeSignAPI.key

        http
      end
    end
  end
end
