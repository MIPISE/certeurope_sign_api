require_relative "helpers/hash"

require_relative "certeurope_sign_api/ephemeral/order"

module CerteuropeSignAPI
  module Init
    require "openssl"

    attr_reader :base_uri, :certificate, :key

    def init(base_uri:, pkcs12_path:, pkcs12_password:)
      pkcs12 = OpenSSL::PKCS12.new(File.read(File.open(pkcs12_path)), pkcs12_password)

      @base_uri = base_uri
      @certificate = pkcs12.certificate
      @key = pkcs12.key
    end
  end

  extend Init
end
