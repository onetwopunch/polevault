require "polevault/version"
require "polevault/kv"
require "polevault/migrator"
require 'vault'
require 'figly'

module Polevault
  ## This is the highest number of hours in Go
  # before you get an integer overflow.
  INFINITY = "#{292 * 365 * 24}h".freeze

  def self.root
    File.realpath("#{__FILE__}/../..")
  end

  class Command
    include Helpers
    attr_reader :client

    def initialize(config:)
      Figly.load_file(config)
      @client = Vault::Client.new(fig.vault.symbolize_keys)
    end

    def bootstrap
      if uninitialized?
        puts "Initializing and unsealing Vault at #{client.address}"
        init_and_unseal && migrate!
        puts "Done!"
      elsif sealed?
        # Assume root for bootstrap
        puts "Vault #{client.address} sealed. Unsealing..."
        fig.shares.times { |idx| try_unseal(idx + 1) }
        migrate!
      else
        migrate!
      end
    end

    # NOTE: The shard in this case is the integer that corresponds
    # with the shamir secret for each unseal node. For example if
    # you are using S3 with KMS, the shard indicates which KMS CMK
    # and key suffix to use. Shard must be less than # shares
    def try_unseal(shard)
      key = kv.read(unseal_key_prefix, shard: shard)
      if sealed?
        stat = client.sys.unseal(key)
        if stat.sealed?
          puts "Shard #{shard}: #{stat.progress} out of #{stat.t} keys entered."
        else
          puts "Unsealed!"
        end
      end
    end

    def migrate!
      Migrator.new(client: client).migrate if client.sys.leader.leader?
    end

    def sealed?
      client.sys.seal_status.sealed?
    end

    def uninitialized?
      status = client.sys.seal_status rescue nil
      status.nil?
    end

    def vault_init
      response = client.sys.init({shares: fig.shares, threshold: fig.threshold})
      root_token = response.root_token

      kv.write(root_key_prefix, root_token, shard: 'root')
      unseal_keys = response.keys.each_with_index do |uk, i|
        kv.write(unseal_key_prefix, uk, shard: (i + 1))
      end

      [root_token, unseal_keys]
    end

    def init_and_unseal
      if uninitialized?
        root_token, unseal_keys = vault_init
        unseal_keys.each do |uk|
          client.sys.unseal(uk)
        end
        # TODO: Theres a race condition here where migrations
        # don't get run. Seems there might be something to do
        # with the vault-ruby gem using a connection pool
        sleep 2
        client.token = root_token
      end
    end
  end
end
