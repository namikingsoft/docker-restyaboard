include_recipe "../cookbooks/docker/default.rb"

directory "/dockerfile"
directory "/dockerfile/restyaboard"
remote_directory "/dockerfile/restyaboard" do
  action :create
  source "../../restyaboard"
end

remote_file  "/dockerfile/docker-compose.yml" do 
  source "../../docker-compose.yml"
end

execute "docker up" do
  command "COMPOSE_API_VERSION=1.18 docker-compose up -d"
  cwd "/dockerfile"
  not_if "docker ps | grep restyaboard"
end