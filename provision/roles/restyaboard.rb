include_recipe "../cookbooks/docker/default.rb"

execute "add group docker for ec2-user" do
  command "gpasswd -a ec2-user docker"
  not_if "id ec2-user | grep docker"
end

git "/home/ec2-user/docker-restyaboard"  do
  repository "https://github.com/namikingsoft/docker-restyaboard.git"
  user "ec2-user"
  not_if "test -d /home/ec2-user/docker-restyaboard"
end

execute "docker up" do
  command "COMPOSE_API_VERSION=1.18 /usr/local/bin/docker-compose up -d"
  cwd "/home/ec2-user/docker-restyaboard"
  user "ec2-user"
  not_if "docker ps | grep restyaboard"
end