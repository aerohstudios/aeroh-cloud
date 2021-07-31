require 'rails_helper'

RSpec.describe Device, type: :model do
  it "can't save without name and type" do
    expect(Device.new.save).to be false

    expect { Device.create }.not_to raise_error(ActiveRecord::NotNullViolation)
  end

  it "can save with user" do
    user = create(:user)
    device = Device.new
    device.user_id = user.id
    expect(device.save!).to be true
  end
end
