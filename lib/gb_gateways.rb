require 'gb_gateways/version'
require 'gb_gateways/abstract_gateway'

module GBGateways
  def self.load_paths
    AbstractGateway.load_paths
  end
end
