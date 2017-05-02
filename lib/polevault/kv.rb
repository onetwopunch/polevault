require 'polevault/helpers'
require "polevault/adapters/s3"
require "polevault/adapters/inmem"

module Polevault
  class Kv
    include Polevault::Helpers

    def initialize(adapter = :inmem)
      @adapter = Polevault::Adapters.const_get(camelcase(adapter)).new
    end

    def write(key, value, shard: nil)
      @adapter.write(key, value, shard: shard)
    end

    def read(key, shard: nil)
      @adapter.read(key, shard: shard)
    end
  end
end
