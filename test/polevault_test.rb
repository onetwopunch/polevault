require 'test_helper'

class PolevaultTest < Minitest::Test
  def polevault
    @polevault ||= Polevault::Command.new(config: "test/fixtures/test_config.yml")
  end

  def setup
    DockerVault.run
  end

  def teardown
    DockerVault.clean
  end

  def test_initialized?
    assert(polevault.uninitialized?)
  end

  def test_vault_init
    root, uk = polevault.vault_init
    assert_match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/, root)
    assert(uk.length == 3)
    assert_equal(polevault.kv.read('token-root'), root)
    uk.each_with_index do |k, idx|
      assert_match(/[0-9a-f]{66}/, k)
      assert_equal(polevault.kv.read('unseal-key', shard: idx + 1), uk[idx])
    end
  end

  def test_migration_parser
    mig = Polevault::Migrator.new(client: polevault.client)
    assert_match(/test\/fixtures\/migrations/, mig.path)
    version, class_name = mig.parse_migration('test/fixtures/migrations/1485991238_test_migration.rb')
    assert_equal('TestMigration', class_name)
    assert_equal(1485991238, version)
  end

  def test_migrate
    polevault.bootstrap

    value = polevault.client.logical.read('secret/test').data[:value]
    assert_equal("Hooray!", value)

    policies = polevault.client.sys.policies
    assert_equal(["default", "limited", "root"], policies)

    auths = polevault.client.sys.auths.keys
    assert_equal([:github, :token], auths)
  end
end
