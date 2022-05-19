class Api::V1::DeviceResource < JSONAPI::Resource
    attributes :name, :mac_addr, :provisioned, :cert_active, :certificate_arn, :certificate_pem, :certificate_public_key, :certificate_private_key, :thing_name

    before_save do
        @model.user_id = context.current_user.id if @model.new_record?
    end

    def thing_name
      @model.thing_arn.split("thing/").last
    end

    def self.records(options={})
        context = options[:context]
        context.current_user.devices
    end

    def self.updatable_fields(context)
        super - [:mac_addr, :certificate_arn, :certificate_pem, :certificate_public_key, :certificate_private_key, :created_at, :updated_at, :thing_name]
    end

    def self.creatable_fields(context)
        super - [:certificate_arn, :certificate_pem, :certificate_public_key, :certificate_private_key, :created_at, :updated_at, :thing_name]
    end

    def fetchable_fields
        if context.controller.action_name == "create" and
            context.controller.controller_name == "devices" and
            context.controller.request.path == "/api/v1/devices"
            super - [:certificate_arn]
        else
            super - [:certificate_arn, :certificate_pem, :certificate_public_key, :certificate_private_key]
        end
    end
end
