require "securerandom"
require "base64"
require "digest/sha1"

prepare do
  init_certeurope_sign_api
end

def create_order_request(user_id)
  body = {
    external_order_request_id: "MIPISE-#{user_id}",
    holder: {
      firstname: "John",
      lastname: "DOE",
      email: "john.doe@example.fr",
      # mobile: "0611111111",
      country: "FR",
      # id_number: "1234567890",
      id_type: "IDCARD"
    },
    # proof_folder: {
    #   zip_files: ""
    # },
    # client_identifier: user_id,
    # otp_contact: "0611111111",
    enable_otp: false,
    enable_email: false,
    enable_sharing: false
  }

  response = CerteuropeSignAPI::Ephemeral::Orders.create(body: body)

  CerteuropeSignAPI.parse_response(response)
end

def create_signature_request(external_order_request_id)
  path = File.join(__dir__, "support", "contract.pdf")
  document = File.open(path).read
  hash = Digest::SHA1.file(path).hexdigest

  # body = [
  #   {
  #     signature_options: {
  #       signature_type: "PAdES_BASELINE_LTA",
  #       digest_algorithm_name: "SHA256",
  #       signature_packaging_type: "ENVELOPED",
  #       document_type: "INLINE"
  #     },
  #     pdf_signature_options: {
  #       signature_text_color: 8998,
  #       signature_text_font_size: 8.1,
  #       font_family: "Courier",
  #       font_style: "Normal",
  #       signature_text: "NEW_sign",
  #       signature_posX: 10.1,
  #       signature_posY: 10.1,
  #       signature_page: 1
  #     },
  #     enable_archive: false,
  #     archiver_names: ["depositaccounttest"],
  #     to_sign_content: Base64.encode64(document)
  #   }
  # ]

  body = [
    {
      signature_options: {},
      enable_archive: false,
      hash: hash,
      to_sign_content: Base64.encode64(document)
    }
  ]

  response =
    CerteuropeSignAPI::Ephemeral::Signatures.create(
      body: body,
      external_order_request_id: external_order_request_id
    )

  CerteuropeSignAPI.parse_response(response)
end

def sign_signature_request(external_order_request_id)
  response =
    CerteuropeSignAPI::Ephemeral::Signatures::Sign.create(
      external_order_request_id: external_order_request_id
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
  user_id = SecureRandom.uuid
  external_order_request_id = "MIPISE-#{user_id}"

  # Create the order request
  order_request = create_order_request(user_id)
  assert_equal order_request[:code], 200
  assert_equal order_request[:body][:external_order_request_id], external_order_request_id

  # Create the signature request
  signature_request = create_signature_request(external_order_request_id)
  puts(signature_request[:body].inspect)
  assert_equal signature_request[:code], 200

  # Launch the signature process
  signature = sign_signature_request(external_order_request_id)
  assert_equal signature[:code], 200
  assert_equal signature[:status], "SIGNED"
  signature_request_id = signature[:signature_request_id]
  assert !signature_request_id.nil?

  # Get the signature status
  signature_status = get_signature_status(signature_request_id)
  assert_equal signature_status[:code], 200
  assert !signature_status[:signed_content].nil?
end
