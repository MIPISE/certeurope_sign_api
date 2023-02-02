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

    def init(base_uri:, certificate:, key:, proxy_url: nil, ssl_verification: OpenSSL::SSL::VERIFY_PEER)
      @base_uri = base_uri
      @certificate = OpenSSL::X509::Certificate.new(certificate)
      @key = OpenSSL::PKey.read(key)
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
