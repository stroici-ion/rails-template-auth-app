# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # For development, allow your specific frontend URL.
    # In production, you will change this to your actual frontend domain (e.g., "https://myapp.com")
    origins [
      "http://localhost:5173",
      "http://127.0.0.1:5173",
      "http://192.168.100.145:5173"
    ]

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      # CRITICAL: This must be true so the frontend can receive and send the HttpOnly Refresh Token cookie!
      credentials: true 
  end
end