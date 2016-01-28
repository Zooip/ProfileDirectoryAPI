require "omniauth-cas"
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :cas, name: "GadzOrg",
                  host:      'auth-dev.gadz.org:443',
                  login_url: '/cas/login',
                  logout_url: '/cas/logout',
                  service_validate_url: '/cas/serviceValidate',
                  saml_validate_url: '/cas/samlValidate',
                  saml_time_url: '/cas',
                  saml: true,
                  ssl: true,
                  disable_ssl_verification: true,
                  return_url: false,
                  renew: true
  #provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
end