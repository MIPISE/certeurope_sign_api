require "json"

require_relative "certeurope_sign_api/errors"
require_relative "certeurope_sign_api/helpers"
require_relative "certeurope_sign_api/http_call"

require_relative "certeurope_sign_api/ephemeral/orders"
require_relative "certeurope_sign_api/ephemeral/signatures"
require_relative "certeurope_sign_api/ephemeral/signatures/sign"

module CerteuropeSignAPI
  module Init
    require "openssl"

    attr_reader :base_uri, :certificate, :key, :default_pdf_signature_options, :proxy_url, :ssl_verification

    def init(base_uri:, pkcs12_path:, pkcs12_password:, proxy_url: nil, ssl_verification: OpenSSL::SSL::VERIFY_PEER)
      pkcs12 = OpenSSL::PKCS12.new(File.read(File.open(pkcs12_path)), pkcs12_password)

      @base_uri = base_uri
      @certificate = pkcs12.certificate
      @key = pkcs12.key
      @default_pdf_signature_options = {}
      @proxy_url = proxy_url
      @ssl_verification = ssl_verification
    end

    def set_default_pdf_signature_options(options)
      @default_pdf_signature_options = options
    end
  end
  extend Init
  extend Helpers
end
