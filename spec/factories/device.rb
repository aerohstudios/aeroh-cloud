FactoryBot.define do
    factory :device do
        provisioned { false }
        cert_active { false }
    end
end
