module Triglav
  module Agent
  end
end

require 'triglav/agent/api_client'
require 'triglav/agent/configuration'
require 'triglav/agent/error'
require 'triglav/agent/hash_util'
require 'triglav/agent/logger'
require 'triglav/agent/storage_file'
require 'triglav/agent/timer'
require 'triglav/agent/version'

require 'triglav/agent/base/cli'
require 'triglav/agent/base/setting'
require 'triglav/agent/base/worker'
require 'triglav/agent/base/processor'
require 'triglav/agent/base/connection' # just a skelton
require 'triglav/agent/base/monitor' # just a skelton
