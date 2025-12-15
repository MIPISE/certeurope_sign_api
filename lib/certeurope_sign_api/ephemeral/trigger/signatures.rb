module CerteuropeSignAPI
  module Ephemeral
    module Trigger
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
        end
      end
    end
  end
end
