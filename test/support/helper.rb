require_relative "../../lib/certeurope_sign_api"
require "dotenv"
Dotenv.load(File.join(__dir__, ".env"))

def init_certeurope_sign_api
  CerteuropeSignAPI.init(
    base_uri: ENV["CERTEUROPE_SIGN_API_URL"],
    certificate: ENV["CERTEUROPE_SIGN_API_CERTIFICATE"],
    key: ENV["CERTEUROPE_SIGN_API_KEY"]
  )

  CerteuropeSignAPI.set_default_pdf_signature_options(
    {
      width: 250,
      height: 40,
      x: 50,
      y: 200,
      image_path: File.join(__dir__, "signature_template.png"),
      lines_default_options: {
        line_color: 0,
        line_font_size: 8,
        line_font: "Times_roman",
        line_pos_x_in_image: 45
      }
    }
  )
end
