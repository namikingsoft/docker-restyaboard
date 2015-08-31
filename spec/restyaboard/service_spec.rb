require 'spec_helper'

describe service('docker') do
  it { should be_enabled }
  it { should be_running }
end

describe port(1234) do
  it { should be_listening }
end

describe docker_container('dockerfile_restyaboard_1') do
  it { should be_running }
end

describe docker_container('dockerfile_postgres_1') do
  it { should be_running }
end

describe docker_container('dockerfile_elasticsearch_1') do
  it { should be_running }
end

describe docker_container('dockerfile_data00restyaboard_1') do
  it { should have_volume('/usr/share/nginx/html/media','/volumes/data00restyaboard') }
  it { should have_volume('/var/lib/postgresql/data','/volumes/data00postgres') }
  it { should have_volume('/usr/share/elasticsearch/data','/volumes/data00elasticsearch') }
end
