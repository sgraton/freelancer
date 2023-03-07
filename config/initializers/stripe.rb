if ENV['ASSET_COMPILE'].blank?
    Stripe.api_key = Rails.application.credentials[:development][:stripe][:STRIPE_SECRET_KEY]
end