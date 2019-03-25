jobs = run_context.cookbook_collection[:cb_dvo_jenkins].files_for('files')

jobs.each do |job|
  filename = job['name']
  name = filename.tr('files/', '')
  cookbook_file "#{Chef::Config[:file_cache_path]}/#{name}" do
    source name
    action :create
  end

  job_name = name.tr('.xml', '')

  jenkins_job job_name do
    config name
  end
end
