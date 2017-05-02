# A thin wrapper around Docker for use within tests
require 'json'

module DockerVault
  class << self
    def run
      check!
      return if container_running?
      unless network_exists?
        cmd = "docker network create --driver bridge #{net} "
        cmd += "--subnet 172.142.0.0/16 --ip-range 172.142.0.0/24 "
        cmd += "--gateway 172.142.0.1"
        sys(cmd)
      end

      cmd = "docker run -d --cap-add=IPC_LOCK -p 18200:8200 "
      cmd += "--name test-vault --network #{net} "
      cmd += "--ip #{ip} -e 'VAULT_LOCAL_CONFIG=#{config}' "
      cmd += "vault server"

      sys(cmd)

      sleep(1) # Give things a second to spin up.
    end

    def clean
      sys("docker kill #{name}") if container_running?
      sys("docker rm #{name}") if container_dead?
      sys("docker network rm #{net}") if network_exists?
    end

    def check!
      if sys("which docker")
        sys('docker pull vault') unless sys('docker images | grep vault')
      else
        raise "You must first install Docker: https://www.docker.com/products/overview"
      end
    end

    def config
      infinity = "#{292 * 365 * 24}h".freeze
      JSON.fast_generate({
        backend: {
          inmem: {}
        },
        default_lease_ttl: infinity,
        max_lease_ttl: infinity,
        listener: {
          tcp: {
            address: "#{ip}:8200",
            tls_disable: 1
          }
        }
      })
    end

    def network_exists?
      sys("docker network ls | grep #{net}")
    end

    def container_running?
      sys("docker ps | grep #{name}")
    end

    def container_dead?
      sys("docker ps -a | grep #{name}") && !container_running?
    end

    def name
      "test-vault"
    end

    def net
      "#{name}-net"
    end

    def ip
      "172.142.0.2"
    end

    def sys(cmd)
      system("#{cmd} > /dev/null")
    end
  end
end
