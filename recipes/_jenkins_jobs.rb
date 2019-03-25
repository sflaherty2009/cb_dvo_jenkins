jobs = run_context.cookbook_collection[:cb_dvo_jenkins].files_for('files')

jobs.each do |job|
  filename = job['name']
  path = job['path']
  cookbook_file path do
    source filename
    action :create
  end

  job_name = filename.tr('.xml', '')

  jenkins_job job_name do
    config filename
  end
end
