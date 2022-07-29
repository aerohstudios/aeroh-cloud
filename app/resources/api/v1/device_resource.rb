class Api::V1::DeviceResource < JSONAPI::Resource
    attributes :name, :mac_addr, :provisioned, :cert_active, :certificate_arn, :certificate_pem, :certificate_public_key, :certificate_private_key, :thing_name, :root_ca, :mqtt_uri

    before_save do
        @model.user_id = context.current_user.id if @model.new_record?
    end

    def thing_name
      @model.thing_arn.split("thing/").last rescue nil
    end

    def root_ca
      # Cert chain taken from https://docs.aws.amazon.com/iot/latest/developerguide/server-authentication.html
      # RSA 2048 bit key: Amazon Root CA 1
      # https://www.amazontrust.com/repository/AmazonRootCA1.pem
      # ECC 256 bit key: Amazon Root CA 3
      # https://www.amazontrust.com/repository/AmazonRootCA3.pem
      <<-EOF
-----BEGIN CERTIFICATE-----
MIIDQTCCAimgAwIBAgITBmyfz5m/jAo54vB4ikPmljZbyjANBgkqhkiG9w0BAQsF
ADA5MQswCQYDVQQGEwJVUzEPMA0GA1UEChMGQW1hem9uMRkwFwYDVQQDExBBbWF6
b24gUm9vdCBDQSAxMB4XDTE1MDUyNjAwMDAwMFoXDTM4MDExNzAwMDAwMFowOTEL
MAkGA1UEBhMCVVMxDzANBgNVBAoTBkFtYXpvbjEZMBcGA1UEAxMQQW1hem9uIFJv
b3QgQ0EgMTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALJ4gHHKeNXj
ca9HgFB0fW7Y14h29Jlo91ghYPl0hAEvrAIthtOgQ3pOsqTQNroBvo3bSMgHFzZM
9O6II8c+6zf1tRn4SWiw3te5djgdYZ6k/oI2peVKVuRF4fn9tBb6dNqcmzU5L/qw
IFAGbHrQgLKm+a/sRxmPUDgH3KKHOVj4utWp+UhnMJbulHheb4mjUcAwhmahRWa6
VOujw5H5SNz/0egwLX0tdHA114gk957EWW67c4cX8jJGKLhD+rcdqsq08p8kDi1L
93FcXmn/6pUCyziKrlA4b9v7LWIbxcceVOF34GfID5yHI9Y/QCB/IIDEgEw+OyQm
jgSubJrIqg0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMC
AYYwHQYDVR0OBBYEFIQYzIU07LwMlJQuCFmcx7IQTgoIMA0GCSqGSIb3DQEBCwUA
A4IBAQCY8jdaQZChGsV2USggNiMOruYou6r4lK5IpDB/G/wkjUu0yKGX9rbxenDI
U5PMCCjjmCXPI6T53iHTfIUJrU6adTrCC2qJeHZERxhlbI1Bjjt/msv0tadQ1wUs
N+gDS63pYaACbvXy8MWy7Vu33PqUXHeeE6V/Uq2V8viTO96LXFvKWlJbYK8U90vv
o/ufQJVtMVT8QtPHRh8jrdkPSHCa2XV4cdFyQzR1bldZwgJcJmApzyMZFo6IQ6XU
5MsI+yMRQ+hDKXJioaldXgjUkK642M4UwtBV8ob2xJNDd2ZhwLnoQdeXeGADbkpy
rqXRfboQnoZsG4q5WTP468SQvvG5
-----END CERTIFICATE-----

-----BEGIN CERTIFICATE-----
MIIBtjCCAVugAwIBAgITBmyf1XSXNmY/Owua2eiedgPySjAKBggqhkjOPQQDAjA5
MQswCQYDVQQGEwJVUzEPMA0GA1UEChMGQW1hem9uMRkwFwYDVQQDExBBbWF6b24g
Um9vdCBDQSAzMB4XDTE1MDUyNjAwMDAwMFoXDTQwMDUyNjAwMDAwMFowOTELMAkG
A1UEBhMCVVMxDzANBgNVBAoTBkFtYXpvbjEZMBcGA1UEAxMQQW1hem9uIFJvb3Qg
Q0EgMzBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABCmXp8ZBf8ANm+gBG1bG8lKl
ui2yEujSLtf6ycXYqm0fc4E7O5hrOXwzpcVOho6AF2hiRVd9RFgdszflZwjrZt6j
QjBAMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgGGMB0GA1UdDgQWBBSr
ttvXBp43rDCGB5Fwx5zEGbF4wDAKBggqhkjOPQQDAgNJADBGAiEA4IWSoxe3jfkr
BqWTrBqYaGFy+uGh0PsceGCmQ5nFuMQCIQCcAu/xlJyzlvnrxir4tiz+OpAUFteM
YyRIHN8wfdVoOw==
-----END CERTIFICATE-----
      EOF
    end

    def mqtt_uri
      # host comes from
      # Aws::IoT::Resource.new(region: 'us-east-1').
      #   client.describe_endpoint(endpoint_type: "iot:Data-ATS")
      host = "a1auw5389lxk45-ats.iot.us-east-1.amazonaws.com"

      # protocol and port is discussed here:
      #   https://docs.aws.amazon.com/iot/latest/developerguide/protocols.html
      scheme = "mqtts"
      port = "8883"

      "#{scheme}://#{host}:#{port}"
    end

    def self.records(options={})
        context = options[:context]
        context.current_user.devices
    end

    def self.updatable_fields(context)
        super - [:mac_addr, :certificate_arn, :certificate_pem, :certificate_public_key, :certificate_private_key, :created_at, :updated_at, :thing_name, :root_ca, :mqtt_uri]
    end

    def self.creatable_fields(context)
        super - [:certificate_arn, :certificate_pem, :certificate_public_key, :certificate_private_key, :created_at, :updated_at, :thing_name, :root_ca, :mqtt_uri]
    end

    def fetchable_fields
        if context.controller.action_name == "create" and
            context.controller.controller_name == "devices" and
            context.controller.request.path == "/api/v1/devices"
            super - [:certificate_arn]
        else
            super - [:certificate_arn, :certificate_pem, :certificate_public_key, :certificate_private_key, :root_ca]
        end
    end
end
