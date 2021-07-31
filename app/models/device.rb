class Device < ApplicationRecord
    belongs_to :user

    def provision
        return if self.provisioned

        response = ThingService.provision(self.id)
        self.provisioned = true
        self.thing_arn = response[:thing_arn]
        self.certificate_arn = response[:certificate_arn]
        self.certificate_pem = response[:certificate_pem]
        self.certificate_private_key = response[:private_key]
        self.certificate_public_key = response[:public_key]
        self.save!
    end
end
