module CerteuropeSignAPI
  module Ephemeral
    module Trigger
      module Signatures
        module Validate
          extend Helpers

          class << self
            def create(external_order_request_id:, order_request_id:, body: {})
              CerteuropeSignAPI::HTTPCall.post(
                generate_uri({
                  external_order_request_id: external_order_request_id,
                  order_request_id: order_request_id,
                }),
                body
              )
            end
          end
        end
      end
    end
  end
end
