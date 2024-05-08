# frozen_string_literal: true

require_relative 'config_builder'
require_relative 'key_generator'
require_relative 'confug_updater'

module WireGuard
  # wg server
  class Server
    WG_JSON_PATH = "#{Settings.wg_path}/wg0.json".freeze
    WG_DEFAULT_ADDRESS = Settings.wg_default_address

    attr_reader :server_private_key, :server_public_key

    def initialize
      initialize_json_config
    end

    def new_config(params)
      config = build_new_config(json_config['configs'], params)

      update_json_config(config)
      dump_json_config(json_config)
      dump_wireguard_config

      config
    end

    def all_configs
      return {} if configs_empty?

      @configs.except('last_id', 'last_address')
    end

    def config(id)
      return nil if configs_empty?

      @configs[id]
    end

    private

    attr_reader :json_config

    def initialize_json_config
      if File.exist?(WG_JSON_PATH)
        @json_config = JSON.parse(File.read(WG_JSON_PATH))
        @server_private_key = @json_config['server']['private_key']
        @server_public_key = @json_config['server']['public_key']
        @configs = @json_config['configs']
      else
        generate_server_private_key
        generate_server_public_key
        create_json_server_config
      end
    end

    def create_json_server_config # rubocop:disable Metrics/MethodLength
      @json_config = {
        server: {
          private_key: @server_private_key,
          public_key: @server_public_key,
          address: WG_DEFAULT_ADDRESS.gsub('x', '1')
        },
        configs: {
          last_id: 0,
          last_address: WG_DEFAULT_ADDRESS.gsub('x', '1')
        }
      }

      dump_json_config(@json_config)
    end

    def dump_json_config(config)
      File.write(WG_JSON_PATH, JSON.pretty_generate(config))
    end

    def dump_wireguard_config
      # ConfigUpdater.update
    end

    def update_json_config(config)
      json_config['configs'][config[:id].to_s] = config
      json_config['configs']['last_id'] = config[:id]
      json_config['configs']['last_address'] = config[:address]
    end

    def generate_server_private_key
      @server_private_key = KeyGenerator.wg_genkey
    end

    def generate_server_public_key
      @server_public_key = KeyGenerator.wg_pubkey(@server_private_key)
    end

    def configs_empty?
      @configs.nil? or json_config['configs']['last_id'].zero?
    end

    def build_new_config(configs, params)
      ConfigBuilder.new(configs, params).config
    end
  end
end