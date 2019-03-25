jobs = run_context.cookbook_collection[:cb_dvo_jenkins].files_for()

jobs.each do |job|
  filename = job['name']
  cookbook_file "#{Chef::Config[:file_cache_path]}/#{filename}" do
    source filename
    action :create
  end

  job_name = filename.tr('.xml', '')

  jenkins_job job_name do
    config filename
  end
end
