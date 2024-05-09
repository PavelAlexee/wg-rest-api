# frozen_string_literal: true

require 'json'
require 'byebug'
require 'config'
Config.load_and_set_settings('config/settings/test.yaml')

require_relative '../app/clients_serializer'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'

  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end