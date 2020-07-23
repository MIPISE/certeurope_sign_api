require_relative "../../lib/certeurope_sign_api"
require "dotenv"
Dotenv.load(File.join(__dir__, ".env"))

def init_certeurope_sign_api
  CerteuropeSignAPI.init(
    base_uri:        ENV["CERTEUROPE_SIGN_API_URL"],
    pkcs12_path:     File.join(__dir__, "certificate.p12"),
    pkcs12_password: ENV["CERTEUROPE_SIGN_API_PKCS12_PASSWORD"]
  )
end
