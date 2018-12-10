#
# Cookbook Name:: cb_dvo_jenkins
# Recipe:: _vm_agent
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

# Recipe used for automatically deploying azure agents on server utilization
# underscore placed in front of recipe name because it should not be run standalone.
azure_auth = data_bag_item('jenkins', 'credentials')

jenkins_password_credentials 'jenkinsAdmin' do
  id          'jenkinsAdmin'
  description 'creds for use by jenkins agents'
  password    azure_auth['agent']['password']
  notifies :execute, 'jenkins_script[master_executors]', :immediately
end

# Set the number of executors on the master server to zero, run jobs off agents
jenkins_script 'master_executors' do
  command <<-GROOVY.gsub(/^ {4}/, '')
    import jenkins.model.*

    def instance = Jenkins.getInstance()
    instance.setNumExecutors(0)
    instance.save()
  GROOVY
  notifies :execute, 'jenkins_script[az_creds]', :immediately
  action :nothing
end

# Add credentials for use with spinning up azure vms
jenkins_script 'az_creds' do
  command <<-GROOVY.gsub(/^ {4}/, '')
    import com.cloudbees.plugins.credentials.*
    import com.cloudbees.plugins.credentials.common.*
    import com.cloudbees.plugins.credentials.domains.*
    import com.cloudbees.plugins.credentials.impl.*
    import jenkins.model.*
    import hudson.security.*
    import hudson.plugins.active_directory.*
    import org.jenkinsci.plugins.*
    import com.microsoft.azure.util.AzureCredentials

    def azureCredential = new AzureCredentials(
      CredentialsScope.GLOBAL,
      'azureCreds',
      'Azure Service Principal',
      '#{azure_auth['production']['subscription']}',
      '#{azure_auth['production']['client_id']}',
      '#{azure_auth['production']['client_secret']}',
      'https://login.microsoftonline.com/#{azure_auth['production']['tenant_id']}/oauth2',
      '',
      '',
      '',
      ''
    )
    SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), azureCredential)
  GROOVY
  notifies :execute, 'jenkins_script[vm_agent_linux]', :immediately
  action :nothing
end

jenkins_script 'vm_agent_linux' do
  command <<-GROOVY.gsub(/^ {4}/, '')
  import com.microsoft.azure.vmagent.builders.*
  import com.cloudbees.plugins.credentials.*
  import com.cloudbees.plugins.credentials.common.*
  import com.cloudbees.plugins.credentials.domains.*
  import com.cloudbees.plugins.credentials.impl.*
  import jenkins.model.*
  import hudson.security.*
  import hudson.plugins.active_directory.*
  import org.jenkinsci.plugins.*
  import com.microsoft.azure.util.AzureCredentials

  def myCloud = new AzureVMCloudBuilder()
      .withCloudName("azurejenkins")
      .withAzureCredentialsId("azureCreds")
      .withNewResourceGroupName("jenkinsagent")
      .addNewTemplate()
          .withName("jenkinsagent")
          .withLabels("jenkinsagent")
          .withLocation("East US")
          .withVirtualMachineSize("Standard_DS2_v2")
          .withNewStorageAccount("")
          .addNewAdvancedImage()
            .withReferenceImage("Canonical", "UbuntuServer", "16.04-LTS", "latest")
            .withVirtualNetworkName("AZ-VN-EastUS2-02")
            .withVirtualNetworkResourceGroupName("AZ-RG-Network")
            .withSubnetName("AZ-SN-dvo")
            .withUsePrivateIP(true)
            .withPreInstallSsh(false)
            .withInitScript($/
                sudo add-apt-repository ppa:openjdk-r/ppa -y
                sudo apt-get -y update
                sudo apt-get install openjdk-8-jre openjdk-8-jre-headless openjdk-8-jdk -y
                sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
                sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
                sudo apt-get -y update
                sudo apt-get install -y docker-ce
                sudo gpasswd -a jenkins docker
                sudo chmod 0777 /var/run/docker.sock
                sudo apt-get install -y git
              /$)
          .endAdvancedImage()
          .withAdminCredential("jenkinsAdmin")
      .endTemplate()
      .build();
    Jenkins.getInstance().clouds.add(myCloud);
    GROOVY
  action :nothing
end
