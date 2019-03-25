jobs = run_context.cookbook_collection['cookbook_name']

jobs.manifest['files'].each do |job|
  filename = job['name']
  cookbook_file "#{Chef::Config[:file_cache_path]}/#{filename}" do
    source filename
    action :create
  end

  job_xml = File.join(Chef::Config[:file_cache_path], filename)

  jenkins_job filename do
    config job_xml
  end
end
