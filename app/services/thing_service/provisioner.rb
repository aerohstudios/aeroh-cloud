module ThingService
    # This Service uses AWS IoT Core
    # API Documentation - https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/IoT/Client.html


    class Provisioner < ThingService::Base
        attr_reader :identifier, :thing, :policy, :certificate

        def initialize(identifier)
            super()

            @identifier = identifier
            @thing = nil
            @policy = nil
            @certificate = nil
        end

        def execute
            create_thing
            create_policy
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
            thing_name = "#{Rails.env.capitalize}_Druid_Core_#{@identifier}"
            @thing = @client.create_thing(thing_name: thing_name)
        end

        def create_policy
            raise StandardError.new("You need to create a thing first!") unless @thing

            policy_name = "#{Rails.env.capitalize}_Druid_Core_Access_#{@identifier}"
            policy_document = {
                "Version": "2012-10-17",
                "Statement": [
                    {
                    "Effect": "Allow",
                    "Action": "iot:Connect",
                    "Resource": @thing.thing_arn
                    },
                    {
                    "Effect": "Allow",
                    "Action": "iot:Publish",
                    "Resource": @thing.thing_arn
                    },
                    {
                    "Effect": "Allow",
                    "Action": "iot:Subscribe",
                    "Resource": @thing.thing_arn
                    },
                    {
                    "Effect": "Allow",
                    "Action": "iot:Receive",
                    "Resource": @thing.thing_arn
                    }
                ]
            }.to_json

            @policy = @client.create_policy(policy_name: policy_name, policy_document: policy_document)
        end

        def create_certificate
            @certificate = @client.create_keys_and_certificate(set_as_active: true)
        end

        def attach_thing_to_certificate
            raise StandardError.new("You need to create a thing and certificate first!") unless @thing and @certificate

            @client.attach_thing_principal(thing_name: @thing.thing_name, principal: @certificate.certificate_arn)
        end

        def attach_policy_to_certificate
            raise StandardError.new("You need to create a policy and certificate first!") unless @policy and @certificate

            @client.attach_principal_policy(policy_name: @policy.policy_name, principal: @certificate.certificate_arn)
        end
    end
end