jobs = %w(con_base_Hybris tbc dvo_docker con_base_solr sonarqube dvo_wcpweb2 traffic_drain bump_web_heads database_refresh tbc_dev2 tbc_e2e maintenance_page tbc_domane)

jobs.each do |job|
  cookbook_file "#{Chef::Config[:file_cache_path]}/#{job}.xml" do
    source "#{job}.xml"
    action :create
  end

  job_xml = File.join(Chef::Config[:file_cache_path], "#{job}.xml")

  jenkins_job job do
    config job_xml
  end
end
