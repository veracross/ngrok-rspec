require "ngrok/rspec/version"
require "ngrok/tunnel"

module Ngrok

  class UnknownServerPort < StandardError; end

  module Rspec
    class << self; attr_accessor :original_app_host, :tunnel; end

    def self.included(base)

      Ngrok::Rspec.original_app_host = Capybara.app_host
      original_always_include_port = Capybara.always_include_port

      ::RSpec.configure do |config|

        config.around(:each, ngrok: true) do |example|
          raise UnknownServerPort, "Define Capybara.server_port in RSpec.config" unless Capybara.server_port
          Ngrok::Tunnel.start(Ngrok::Rspec.tunnel) unless Ngrok::Tunnel.running?

          Capybara.always_include_port = false

          Capybara.app_host = Ngrok::Tunnel.ngrok_url

          example.run

          Capybara.always_include_port = original_always_include_port
          Capybara.app_host = Ngrok::Rspec::original_app_host
        end

        config.around(:each, ngrok_https: true) do |example|
          raise UnknownServerPort, "Define Capybara.server_port in RSpec.config" unless Capybara.server_port
          Ngrok::Tunnel.start(Ngrok::Rspec.tunnel) unless Ngrok::Tunnel.running?

          Capybara.always_include_port = false

          Capybara.app_host = Ngrok::Tunnel.ngrok_url_https

          example.run

          Capybara.always_include_port = original_always_include_port
          Capybara.app_host = Ngrok::Rspec::original_app_host
        end

        config.after(:suite) do
          Ngrok::Tunnel.stop if Ngrok::Tunnel.running?
        end

      end
    end


  end
end
