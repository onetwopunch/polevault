$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'polevault'
require 'byebug'
require_relative './lib/docker_vault'

require 'minitest/autorun'

MiniTest::Unit.after_tests do
  # Ensure we clean up
  DockerVault.clean
end
