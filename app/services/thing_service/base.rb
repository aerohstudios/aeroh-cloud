module ThingService
    class Base
        attr_reader :client

        def initialize
            @client = Aws::IoT::Resource.new(region: 'us-east-1').client
        end
    end
end
