module CerteuropeSignAPI
  module Ephemeral
    module Orders
      class << self
        def create(params)
          validate_create_params(params)
        end

        private

        def validate_create_params(params)
          params.validate_keys(%i[external_order_request_id holder proof_folder client_identifier])
          params[:holder].validate_keys(%i[first_name last_name email mobile country id_number id_type])
          params[:proof_folder].validate_keys(%i[zip_files])
        end
      end
    end
  end
end
