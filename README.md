# Polevault

Polevault is a way to bootstrap and maintain the state of a particular Hashicorp Vault cluster.

## Usage

To bootstrap a Vault node with specified config and migrations
```
polevault bootstrap --config config.yml
```

## Config

Polevault uses a basic YAML configuration and has a few basic options:

- `unseal_key_prefix`: Defaults 'unseal-key' this will be the key prefix for your key value store suffixed by the shard index. For example, the first unseal key in the default scenario would be 'unseal-key-1'.
- `root_token_key`: Defaults to 'token'. Similarly the key that the root token will be stored under will be suffixed with 'root' so the key would be 'token-root'. This is useful for example, if you are using the S3 adapter to match which CMK goes with what token.
- `shares`: The total number of unseal keys (Shamir secrets keys)
- `threshold`: The minimum number of unseal keys needed to unseal vault
- `adapter`: Currently only `s3` and `inmem` are supported, but adapters are simple to create and contributions are welcome
- `migrations_path`: Path to where polevault should look for and create vault migrations
- `migration_key`: Defaults to `secret/_migration`. The entry in vault used to store the migration version
- `vault`: This key is used to pass arbitrary config to the underlying Vault::Client instance

## Adapters

Adapters are ideally secure key value stores into which sensitive keys are stored.

### S3 Adapter

The S3 adapter takes some additional configuration since there is a need to do client-side encryption with KMS. You must specify the CMK or Customer Master Key with which to encrypt the root and unseal keys. Ideally you should have a separate CMK per unseal key. These are suffixed with the shard, or 'root'. As an example:

```
kms:
  region: us-east-1
  cmk_root: <root cmk uuid>
  cmk_1: <cmk for shard 1>
  cmk_2: <cmk for shard 2>
  cmk_3: <cmk for shard 3>
s3:
  region: us-east-1
  bucket: bucket-name
```
## Migrations

Much like Rails, Polevault keeps track of state in Vault with migrations. To generate a new migration, just run:

```
$ polvault generate-migration my_migration --config config.yml
"Migration template written to migrations/1486164063_my_migration.rb"
```

Make sure that within the config file, you adjust the values for `migrations_path` and `migration_key` if you want to adjust those values.

Here is an example of a migration:
```
require 'polevault/migration'
require 'erb'

class MyMigration < Polevault::Migration
  def migrate
    # NOTE: Within this class you have access to the following variables:
    #
    # vault: Vault::Client instance configured with config
    #   This which will have access to setup your
    #   Vault node through the root token generated by init. See
    #   https://github.com/hashicorp/vault-ruby for API docs
    # config: Figly::Settings hash that has config accessible via dot operator.
    #   see http://github.com/onetwopunch/figly for details
    # kv: The kv store you specified in your config with methods read/write.
    #
    # i.e.
    vault.logical.write('secret/test', value: config.custom.secret_value)

    puts "Enable Github auth for ops team"
    vault.sys.enable_auth('github', 'github')
    vault.logical.write('auth/github/config', organization: 'hashicorp')
    vault.logical.write('auth/github/map/teams/ops', value: 'ops')

    # You can use ERB to inject values into policies
    @path = config.custom_path
    limited_template = File.read('/etc/default/vault/policies/limited_policy.hcl.erb'))
    limited_policy = ERB.new(limited_template).result(binding)
    vault.sys.put_policy("limited", limited_policy)
  end
end

```

## Unsealing

The bootstrap script must be run under the root token, but only on one node. This stores the configuration into the vault backend. If you have other nodes in you're vault cluster running in HA mode, you'll need to unseal them each individually. You can do this using:

```
polevault unseal SHARD --config config.yml
```

This should only be run after the initial bootstrap since it will read the unseal key from the KV from the specified shard. If there is more than one key needed to unseal the vault, the command will let you know the progress. Ideally, this should be run from different nodes or lambdas with different permissions to the respective unseal keys.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. This console spins up a docker container with an inmem vault server spun up and then cleaned up after.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/onetwopunch/polevault.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
