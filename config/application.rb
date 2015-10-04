require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LibraryMiner
  class Application < Rails::Application
    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    config.time_zone = 'Tokyo'
    config.i18n.default_locale = :ja
    config.i18n.available_locales = [:ja, :en]
    config.active_job.queue_adapter = :delayed_job
    config.autoload_paths += Dir["#{config.root}/app/validators", "#{config.root}/lib"]

    config.generators do |g|
      g.assets false
      g.helper false
      g.test_framework :rspec
      g.jbuilder false
      g.template_engine :erb
    end
  end
end
