require "sidekiq/web"

Rails.application.routes.draw do
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == Rails.application.credentials.sidekiq.username && password == Rails.application.credentials.sidekiq.password
  end

  mount Sidekiq::Web => "/sidekiq"

  namespace :api do
    namespace :v1 do
      post 'webhook/callback'
    end
  end
end
