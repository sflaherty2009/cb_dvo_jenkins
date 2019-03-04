jobs = %w(con_base_Hybris dvo_docker con_base_solr sonarqube dvo_wcpweb2 traffic_drain bump_web_heads database_refresh maintenance_page con_base_maintenance con_base_apache con_base_centos con_base_freegeoip con_base_golang Jenkins_Agent_Cleanup conhybris_acr_cleanup environment_pinning)

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
