FactoryGirl.define do
  factory :doorkeeper_application, :class => 'Doorkeeper::Application' do
    name "My Awesome App !"
    redirect_uri "https://myawesomeapp.com/oauth/redirect"
    scopes ""
    owner nil
  end
end