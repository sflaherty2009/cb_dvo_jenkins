bash "install_azure_cli" do
  code <<-EOH
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
    yum check-update 
    sudo yum install azure-cli 
    yum check-update
    sudo yum update azure-cli
  EOH
  not_if { File.exist?("/etc/yum.repos.d/azure-cli.repo") }
end
