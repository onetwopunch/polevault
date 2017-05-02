require 'aws-sdk'

module Polevault
  module Adapters
    class S3
      def initialize
        @fig = Figly::Settings
      end

      def read(key, shard: nil )
        key += "-#{shard}" if shard
        cipher = bucket.object(key).get.body.string
        decrypt(cipher).plaintext
      end

      def write(key, value, shard: nil)
        key += "-#{shard}" if shard
        cmk = fig.kms["cmk_#{shard}"]
        bucket.object(key).put({body: encrypt(value, cmk)})
      end

      protected

      attr_reader :fig

      def bucket
        @bucket ||= begin
          s3 = Aws::S3::Resource.new(region: fig.s3.region)
          s3.bucket(fig.s3.bucket)
        end
      end

      def kms
        @kms ||= Aws::KMS::Client.new(region: fig.kms.region)
      end

      def encrypt(plaintext, key_id)
        kms.encrypt({
          key_id: key_id,
          plaintext: plaintext
        }).ciphertext_blob
      end

      def decrypt(ciphertext)
        kms.decrypt(ciphertext_blob: ciphertext)
      end
    end
  end
end
