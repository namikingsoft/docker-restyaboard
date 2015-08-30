require 'spec_helper'

describe service('docker') do
  it { should be_enabled }
  it { should be_running }
end

describe port(1234) do
  it { should be_listening }
end