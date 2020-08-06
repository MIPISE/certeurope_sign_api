module CerteuropeSignAPI
  module Ephemeral
    module Signatures
      extend Helpers

      class << self
        def create(order_request_id: nil, external_order_request_id: nil, body:)
          CerteuropeSignAPI::HTTPCall.post(
            generate_uri({
              order_request_id: order_request_id,
              external_order_request_id: external_order_request_id
            }),
            body
          )
        end

        def get(signature_request_id: nil, external_signature_request_id: nil)
          CerteuropeSignAPI::HTTPCall.get(
            generate_uri({
              id: signature_request_id,
              external_id: external_signature_request_id
            })
          )
        end
      end
    end
  end
end
