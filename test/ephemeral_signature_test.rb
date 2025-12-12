require "securerandom"
require "base64"

prepare do
  init_certeurope_sign_api
end

def create_order_request(external_request_uuid, client_identifier, holder_options, enable_otp: false, contact: nil)
  body = {
    external_order_request_id: external_request_uuid,
    holder: holder_options,
    proof_folder: {
      zip_files: ""
    },
    client_identifier: client_identifier,
    enable_otp: enable_otp,
    enable_email: enable_otp,
    enable_sharing: false
  }
  body[:otp_contact] = contact if enable_otp
  response = CerteuropeSignAPI::Ephemeral::Orders.create(body: body)
  CerteuropeSignAPI.parse_response(response)
end

def create_signature_request(external_order_request_id, order_request_id, document_path, signature_opts = {}, trigger: false)
  api_module = trigger ? CerteuropeSignAPI::Ephemeral::Trigger::Signatures : CerteuropeSignAPI::Ephemeral::Signatures

  to_sign_content = Base64.strict_encode64(File.read(document_path, mode: "rb"))
  sig_opts = CerteuropeSignAPI.default_pdf_signature_options.merge(signature_opts)

  signature_image_content = sig_opts[:image_path] ? Base64.strict_encode64(File.read(sig_opts[:image_path], mode: "rb")) : nil

  lines_options =
    if signature_opts[:lines]&.any?
      delta_line = (sig_opts[:height] - 2).to_f / signature_opts[:lines].size
      signature_opts[:lines].each_with_index.map do |line_opts, idx|
        line_defaults = sig_opts[:lines_default_options] || {}
        line_opts_merged = line_defaults.merge(line_opts)
        y_pos = sig_opts[:height] - 1 - (idx * delta_line) - line_opts_merged[:line_font_size]
        line_opts_merged.merge(line_pos_y_in_image: y_pos)
      end
    end

  body = [{
    signature_options: {
      signature_type: "PAdES_BASELINE_LTA",
      digest_algorithm_name: "SHA256",
      signature_packaging_type: "ENVELOPED",
      document_type: "INLINE"
    },
    pdf_signature_options: {
      signature_image_content: signature_image_content,
      signature_pos_x: sig_opts[:x],
      signature_pos_y: sig_opts[:y],
      signature_page: sig_opts[:page],
      "linesOptions": lines_options
    },
    enable_archive: false,
    to_sign_content: to_sign_content
  }]

  CerteuropeSignAPI.parse_response(
    api_module.create(body:, external_order_request_id:, order_request_id:)
  )
end

def sign_signature_request(external_order_request_id, order_request_id, body, otp: nil)
  klass = otp ? CerteuropeSignAPI::Ephemeral::Trigger::Signatures::Sign : CerteuropeSignAPI::Ephemeral::Signatures::Sign
  params = {external_order_request_id:, order_request_id:, body:}
  params[:otp] = otp if otp

  CerteuropeSignAPI.parse_response(klass.create(**params))
end

def validate_trigger_signature_request(external_order_request_id, order_request_id, body)
  response = CerteuropeSignAPI::Ephemeral::Trigger::Signatures::Validate.create(
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

test "full trigger signature process" do
  client_identifier = SecureRandom.uuid
  external_order_request_id = "MIPISE-#{client_identifier}"
  holder_options =
    {
      firstname: "John",
      lastname: "DOE",
      email: "john.doe@example.fr",
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
  # Define here your contact to receive otp : contact = your_phone_number or your email
  binding.irb
  contact ||= "0611111111"

  order_request = create_order_request(
    external_order_request_id,
    client_identifier,
    holder_options,
    enable_otp: true,
    contact: contact
  )

  order_request_id = order_request[:body][:order_request_id]
  assert_equal order_request[:code], 200
  assert_equal order_request[:body][:external_order_request_id], external_order_request_id
  assert !order_request_id.nil?

  # Create the signature request
  #
  signature_request = create_signature_request(external_order_request_id, order_request_id, document_to_sign_path, signature_options, trigger: true)
  assert_equal signature_request[:code], 200

  validate_trigger_signature_request(external_order_request_id, order_request_id, signature_request[:body])

  # Define here received OTP code : otp = "received_code"
  binding.irb
  otp ||= "0000"
  signature = sign_signature_request(external_order_request_id, order_request_id, signature_request[:body], otp: otp)
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
