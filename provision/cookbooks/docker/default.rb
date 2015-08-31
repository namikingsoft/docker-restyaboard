package "docker" do
  action :install
end

execute "install docker-compose" do
  command "pip install -U docker-compose"
  not_if "test -e /usr/local/bin/docker-compose"
end

link "/usr/bin/docker-compose" do 
  to "/usr/local/bin/docker-compose"
  not_if "test -e /usr/bin/docker-compose"
end

service "docker" do
  action [:enable, :start]
end
