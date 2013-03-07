require 'thor'
require 'rainbow'
require 'yaml'

module Snipe
  autoload :Cli,        'snipe/cli'
  autoload :Dependency, 'snipe/dependency'
  autoload :Logger,     'snipe/logger'
  autoload :Utility,    'snipe/utility'
  autoload :Version,    'snipe/version'
end
