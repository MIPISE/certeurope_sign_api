require "securerandom"
require "base64"

prepare do
  init_certeurope_sign_api
end

def create_order_request(external_request_uuid, client_identifier, holder_options)
  body = {
    external_order_request_id: external_request_uuid,
    holder: holder_options,
    proof_folder: {
      zip_files: ""
    },
    client_identifier: client_identifier,
    enable_otp: false,
    enable_email: false,
    enable_sharing: false
  }
  response = CerteuropeSignAPI::Ephemeral::Orders.create(body: body)
  CerteuropeSignAPI.parse_response(response)
end

def create_signature_request(external_order_request_id, order_request_id, document_path, signature_opts={})
  document = File.open(document_path, 'rb').read
  sign_content = Base64.strict_encode64(document)
  signature_options = CerteuropeSignAPI.signature_template.merge(signature_opts)
  unless signature_options[:image_path].nil?
    signature_image = File.open(signature_options[:image_path], 'rb').read
    sign_image_content = Base64.strict_encode64(signature_image)
  end

  if signature_opts.has_key?(:lines) && signature_opts[:lines].size > 0
    delta_line = (CerteuropeSignAPI.signature_template[:height] - 2) / signature_opts[:lines].size
    lines_options =
      signature_opts[:lines].inject([]) do |memo, line_opts|
        default_line_options = CerteuropeSignAPI.signature_template[:lines_default_options] || {}
        line_options = default_line_options.merge(line_opts)
        y_pos = CerteuropeSignAPI.signature_template[:height] - 1 - (memo.size * delta_line) - line_options[:line_font_size]
        memo << line_options.merge({ line_pos_y_in_image: y_pos })
        memo
      end
  end

  body =
    [
      {
        signature_options:
          {
            signature_type: "PAdES_BASELINE_LTA",
            digest_algorithm_name: "SHA256",
            signature_packaging_type: "ENVELOPED",
            document_type: "INLINE"
          },
        pdf_signature_options: {
          signature_image_content: sign_image_content,
          signature_pos_x: signature_options[:x],
          signature_pos_y: signature_options[:y],
          signature_page: signature_options[:page],
          "linesOptions": lines_options
        },
        enable_archive: false,
        to_sign_content: sign_content
      }
    ]
  response =
    CerteuropeSignAPI::Ephemeral::Signatures.create(
      body: body,
      external_order_request_id: external_order_request_id,
      order_request_id: order_request_id
    )
  CerteuropeSignAPI.parse_response(response)
end

def sign_signature_request(external_order_request_id, order_request_id, body)
  response =
    CerteuropeSignAPI::Ephemeral::Signatures::Sign
      .create(
        external_order_request_id: external_order_request_id,
        order_request_id: order_request_id,
        body: body
        )
  CerteuropeSignAPI.parse_response(response)
end

def get_signature_status(signature_request_id)
  response =
    CerteuropeSignAPI::Ephemeral::Signatures.get(
      signature_request_id: signature_request_id
    )

  CerteuropeSignAPI.parse_response(response)
end

test "full signature process" do
  client_identifier = SecureRandom.uuid
  external_order_request_id = "MIPISE-#{client_identifier}"
  holder_options =
    {
      firstname: "John",
      lastname: "DOE",
      email: "john.doe@example.fr",
      mobile: "0611111111",
      country: "FR"
    }
  document_to_sign_path = File.join(__dir__, "support", "contract.pdf")

  signature_options =
    {
      x: 50,
      y: 100,
      page: 2,
      lines:
        [
          { line_content: "Signé le #{Time.now.to_s}" },
          { line_content: "Par son altesse le sérénissime John DOE" },
          { line_content: "Qui sera bien avisé de continuer" }
        ]
    }

  # Create the order request
  order_request = create_order_request(external_order_request_id, client_identifier, holder_options)
  order_request_id = order_request[:body][:order_request_id]
  assert_equal order_request[:code], 200
  assert_equal order_request[:body][:external_order_request_id], external_order_request_id
  assert !order_request_id.nil?

  # Create the signature request
  #
  signature_request = create_signature_request(external_order_request_id, order_request_id, document_to_sign_path, signature_options)
  assert_equal signature_request[:code], 200

  signature = sign_signature_request(external_order_request_id, order_request_id, signature_request[:body])
  assert_equal signature[:code], 200
  assert_equal signature[:body].first[:status], "SIGNED"
  signature_request_id = signature[:body].first[:signature_request_id]
  assert !signature_request_id.nil?

  # Get the signature status
  signature_status = get_signature_status(signature_request_id)
  assert_equal signature_status[:code], 200
  assert !signature_status[:body][:signed_content].nil?

  File.open("#{Dir.pwd}/test/support/signed_document.pdf", "w") { |f| f << Base64.strict_decode64(signature_status[:body][:signed_content]) }
end
