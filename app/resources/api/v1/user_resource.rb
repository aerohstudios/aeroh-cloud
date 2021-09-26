class Api::V1::UserResource < JSONAPI::Resource
    attributes :email

    def self.records(options={})
        context = options[:context]
        User.where(id: context.current_user.id)
    end

    def self.updatable_fields(context)
        []
    end

    def self.creatable_fields(context)
        []
    end
end
