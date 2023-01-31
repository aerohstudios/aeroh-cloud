if Rails.env.development?
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins 'localhost'
      resource '/oauth/token', headers: :any, methods: [:post]
      resource '/api/v1/*', headers: :any, methods: [:get, :post, :patch, :delete, :options]
    end
  end
end
