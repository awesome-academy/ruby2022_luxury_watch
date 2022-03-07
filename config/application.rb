require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Ruby2022LuxuryWatch
  class Application < Rails::Application
    config.load_defaults 6.1
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.autoload_paths << Rails.root.join("lib")
    config.i18n.available_locales = [:en, :vi]
    config.i18n.default_locale = :vi

    config.action_view.embed_authenticity_token_in_remote_forms = true

    config.active_job.queue_adapter = :sidekiq
  end
end
