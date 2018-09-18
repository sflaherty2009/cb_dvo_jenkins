# Hybris Base Container Build
cookbook_file "#{Chef::Config[:file_cache_path]}/con_base_Hybris.xml" do
  source 'con_base_Hybris.xml'
  action :create
end

con_base_hybris_xml = File.join(Chef::Config[:file_cache_path], 'con_base_Hybris.xml')

jenkins_job 'con_base_hybris' do
  config con_base_hybris_xml
end

# Hybris Dev Container Build
cookbook_file "#{Chef::Config[:file_cache_path]}/tbc.xml" do
  source 'tbc.xml'
  action :create
end

tbc_xml = File.join(Chef::Config[:file_cache_path], 'tbc.xml')

jenkins_job 'tbc' do
  config tbc_xml
end

# Hybris Manual Container Build
cookbook_file "#{Chef::Config[:file_cache_path]}/dvo_docker.xml" do
  source 'dvo_docker.xml'
  action :create
end

dvo_docker_xml = File.join(Chef::Config[:file_cache_path], 'dvo_docker.xml')

jenkins_job 'dvo-docker' do
  config dvo_docker_xml
end

# Solr Container Build - Hybris
cookbook_file "#{Chef::Config[:file_cache_path]}/con_base_solr.xml" do
  source 'con_base_solr.xml'
  action :create
end

con_base_solr_xml = File.join(Chef::Config[:file_cache_path], 'con_base_solr.xml')

jenkins_job 'con_base_solr' do
  config con_base_solr_xml
end

# SonarQube
cookbook_file "#{Chef::Config[:file_cache_path]}/sonarqube.xml" do
  source 'sonarqube.xml'
  action :create
end

sonarqube_xml = File.join(Chef::Config[:file_cache_path], 'sonarqube.xml')

jenkins_job 'SonarQube - TBC develop branch' do
  config sonarqube_xml
end

# Web Container Build - Hybris
cookbook_file "#{Chef::Config[:file_cache_path]}/dvo_wcpweb2.xml" do
  source 'dvo_wcpweb2.xml'
  action :create
end

dvo_wcpweb2_xml = File.join(Chef::Config[:file_cache_path], 'dvo_wcpweb2.xml')

jenkins_job 'dvo_wcpweb2' do
  config dvo_wcpweb2_xml
end
