module ThingService
    def self.provision(identifier)
        puts "Creating thing with identifier: #{identifier}"
        provisioner = ThingService::Provisioner.new(identifier)
        return provisioner.execute
    end
end