execute "setting localtime" do
  command <<-EOL
    mv /etc/localtime /etc/localtime.org
    ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
  EOL
  not_if "test -e /etc/localtime.org"
end

file "/etc/sysconfig/clock" do
  action :edit
  block do |content|
    content.gsub! /^ZONE=.*$/, 'ZONE="Asia/Tokyo"'
    content.gsub! /^UTC=true$/, ''
  end
  not_if "grep -e 'Tokyo' /etc/sysconfig/clock"
end