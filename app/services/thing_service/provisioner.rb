module ThingService
    # This Service uses AWS IoT Core
    # API Documentation - https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/IoT/Client.html


    class Provisioner < ThingService::Base
        attr_reader :identifier, :thing, :policy_name, :certificate

        def initialize(identifier)
            super()

            @identifier = identifier
            @thing = nil
            @policy_name = "#{Rails.env.capitalize}_Aeroh_Device_Access"
            @certificate = nil
        end

        def execute
            create_thing
            create_certificate

            attach_thing_to_certificate
            attach_policy_to_certificate

            return {
                thing_arn: @thing.thing_arn,
                certificate_arn: @certificate.certificate_arn,
                certificate_pem: @certificate.certificate_pem,
                public_key: @certificate.key_pair.public_key,
                private_key: @certificate.key_pair.private_key
            }
        end

        def create_thing
            thing_name = "#{Rails.env.capitalize}_Aeroh_Device_#{@identifier}"
            @thing = @client.create_thing(thing_name: thing_name)
        end

        def create_certificate
            @certificate = @client.create_keys_and_certificate(set_as_active: true)
        end

        def attach_thing_to_certificate
            raise StandardError.new("You need to create a thing and certificate first!") unless @thing and @certificate

            @client.attach_thing_principal(thing_name: @thing.thing_name, principal: @certificate.certificate_arn)
        end

        def attach_policy_to_certificate
            raise StandardError.new("You need to create a certificate first!") unless @certificate

            @client.attach_principal_policy(policy_name: @policy_name, principal: @certificate.certificate_arn)
        end
    end
end
