module Polevault
  module Adapters
    class Inmem
      def initialize
        @store = {}
      end

      def read(key, shard: nil)
        key += "-#{shard}" if shard
        @store[key]
      end

      def write(key, value, shard: nil)
        key += "-#{shard}" if shard
        @store[key] = value
      end
    end
  end
end
