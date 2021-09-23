require 'rails_helper'

RSpec.describe "Api::V1::Devices", type: :request do
  it "unauthorized" do
    get "/api/v1/devices"
    expect(response).to have_http_status(:unauthorized)

    post "/api/v1/devices"
    expect(response).to have_http_status(:unauthorized)

    put "/api/v1/devices/1"
    expect(response).to have_http_status(:unauthorized)

    delete "/api/v1/devices/1"
    expect(response).to have_http_status(:unauthorized)
  end

  context "logged in" do
    before(:all) do
      @user = build(:user)
      expect(@user.save).to be true
    end

    before(:each) do
      sign_in(@user)
    end

    it "index" do
      owned_device = build(:device, user_id: @user.id)
      expect(owned_device.save).to be true

      other_user = build(:user)
      expect(other_user.save).to be true

      other_device = build(:device, user_id: other_user.id)
      expect(other_device.save).to be true

      get "/api/v1/devices"
      expect(response).to have_http_status(:ok)
      device_ids = []
      expect {
        device_ids = JSON.parse(response.body)["data"].map {|row| row["id"]}
      }.to_not raise_error
      expect(device_ids).to include(owned_device.id.to_s)
      expect(device_ids).not_to include(other_device.id.to_s)

      expect { owned_device.destroy }.not_to raise_error
      expect { other_device.destroy }.not_to raise_error
      expect { other_user.destroy }.not_to raise_error
    end

    it "show (owned)" do
      device = build(:device, user_id: @user.id)
      expect(device.save).to be true

      get "/api/v1/devices/#{device.id}"
      expect(response).to have_http_status(:ok)

      expect { device.destroy }.not_to raise_error
    end

    it "show (not owned)" do
      other_user = build(:user)
      expect(other_user.save).to be true

      device = build(:device, user_id: other_user.id)
      expect(device.save).to be true

      get "/api/v1/devices/#{device.id}"
      expect(response).to have_http_status(:not_found)

      expect { device.destroy }.not_to raise_error
      expect { other_user.destroy }.not_to raise_error
    end

    it "create" do
      params = {
        data: {
          type: "devices",
          attributes: {
            "name": "Living Room Fan",
            "mac-addr": "00:00:00:00:00:00"
          }
        }
      }
      headers = {
        "Content-Type": "application/vnd.api+json",
        "Accept": "application/vnd.api+json"
      }
      post "/api/v1/devices", params: params.to_json, headers: headers

      expect(response).to have_http_status(:created)
      device_id = nil
      expect {
        device_id = JSON.parse(response.body)["data"]["id"]
      }.not_to raise_error
      device = Device.find(device_id)
      expect(device.user_id).to eq(@user.id)
      expect { device.destroy }.not_to raise_error
    end


    context "update (owned)" do
      it "with allowed params" do
        device = build(:device, user_id: @user.id)
        expect(device.save).to be true

        new_name = "Living Room Fan"
        params = {
          data: {
            type: "devices",
            id: device.id.to_s,
            attributes: {
              "name": new_name,
            }
          }
        }
        headers = {
          "Content-Type": "application/vnd.api+json",
          "Accept": "application/vnd.api+json"
        }
        put "/api/v1/devices/#{device.id}", params: params.to_json, headers: headers
        expect(response).to have_http_status(:ok)

        device_id = nil
        attributes = {}
        expect {
          json_response = JSON.parse(response.body)
          device_id = json_response["data"]["id"]
          attributes = json_response["data"]["attributes"]
        }.not_to raise_error

        expect(device_id).to eq(device_id)
        expect(attributes["name"]).to eq(new_name)

        expect { device.destroy }.not_to raise_error
      end

      it "with not allowed params" do
        device = build(:device, user_id: @user.id)
        expect(device.save).to be true

        [:mac_addr, :certificate_arn, :certificate_pem, :certificate_public_key, :certificate_private_key].each do |field|
          params = {
            data: {
              type: "devices",
              id: device.id.to_s,
              attributes: {
                field: "new value"
              }
            }
          }
          headers = {
            "Content-Type": "application/vnd.api+json",
            "Accept": "application/vnd.api+json"
          }
          put "/api/v1/devices/#{device.id}", params: params.to_json, headers: headers
          expect(response).to have_http_status(:bad_request)
        end

        expect { device.destroy }.not_to raise_error
      end
    end

    it "update (not owned)" do
      other_user = build(:user)
      expect(other_user.save).to be true

      device = build(:device, user_id: other_user.id)
      expect(device.save).to be true

      params = {
        data: {
          type: "devices",
          id: device.id.to_s,
          attributes: {
            "name": "Living Room Fan"
          }
        }
      }
      headers = {
        "Content-Type": "application/vnd.api+json",
        "Accept": "application/vnd.api+json"
      }
      put "/api/v1/devices/#{device.id}", params: params.to_json, headers: headers
      expect(response).to have_http_status(:not_found)

      expect { device.destroy }.not_to raise_error
      expect { other_user.destroy }.not_to raise_error
    end

    it "delete (owned)" do
      device = build(:device, user_id: @user.id)
      expect(device.save).to be true

      params = {
        data: {
          type: "devices",
          id: device.id.to_s
        }
      }
      headers = {
        "Content-Type": "application/vnd.api+json",
        "Accept": "application/vnd.api+json"
      }
      delete "/api/v1/devices/#{device.id}", params: params.to_json, headers: headers
      expect(response).to have_http_status(:no_content)

      expect { Device.find(device.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "delete (not owned)" do
      other_user = build(:user)
      expect(other_user.save).to be true

      device = build(:device, user_id: other_user.id)
      expect(device.save).to be true

      params = {
        data: {
          type: "devices",
          id: device.id.to_s
        }
      }
      headers = {
        "Content-Type": "application/vnd.api+json",
        "Accept": "application/vnd.api+json"
      }
      delete "/api/v1/devices/#{device.id}", params: params.to_json, headers: headers
      expect(response).to have_http_status(:not_found)

      expect { device.destroy }.not_to raise_error
      expect { other_user.destroy }.not_to raise_error
    end

    after(:all) do
      @user.destroy
    end
  end
end
