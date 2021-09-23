require 'rails_helper'

RSpec.describe Device, type: :model do
  it "can't save without name and type" do
    expect(Device.new.save).to be false

    expect { Device.create! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "can save with user" do
    user = create(:user)
    device = Device.new
    device.user_id = user.id
    expect(device.save!).to be true
  end
end
