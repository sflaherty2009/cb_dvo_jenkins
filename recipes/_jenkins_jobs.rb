jobs = run_context.cookbook_collection[cookbook_name].template_filenames

jobs.each do |job|
  cookbook_file "#{Chef::Config[:file_cache_path]}/#{job}" do
    source job
    action :create
  end

  job_xml = File.join(Chef::Config[:file_cache_path], job)

  jenkins_job job do
    config job_xml
  end
end
