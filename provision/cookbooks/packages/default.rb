execute "update yum repo" do
  command <<-EOL
    yum -y update
    date >> /var/log/yum-update
  EOL
  not_if "test -e /var/log/yum-update"
end

package 'git'