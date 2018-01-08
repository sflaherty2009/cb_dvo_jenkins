# Cookbook Name:: cb_dvo_jenkins
# Recipe:: jenkins_job_builder
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

# node.default['poise-python']['install_python2'] = true
# node.default['poise-python']['options']['pip_version'] = true

# git "/tmp/jenkins" do
#     repository "git@github.com:openstack-infra/jenkins-job-builder.git"
#     reference "master"
#     action :sync
# end

# Jenkins user used for jenkins build jobs
jenkins_user node['jenkins_job_builder']['username'] do
  full_name node['jenkins_job_builder']['username']
  public_keys node['jenkins_job_builder']['password']
end

python_runtime 'jenkins' do
  version '2'
  options pip_version: true
end

# Will re-install on every converge unless you add a not_if/only_if.
python_package 'jenkins-job-builder'

directory '/etc/jenkins_jobs' do
  owner node['jenkins_job_builder']['user']
  group node['jenkins_job_builder']['group']
  mode '0750'
end

template '/etc/jenkins_jobs/jenkins_jobs.ini' do
  source 'jenkins_jobs.ini.erb'
  owner node['jenkins_job_builder']['user']
  group node['jenkins_job_builder']['group']
  mode '0640'
  variables(
    username: node['jenkins_job_builder']['username'],
    password: node['jenkins_job_builder']['password'],
    url: node['jenkins_job_builder']['url'],
    external_url: node['jenkins']['server']['url']
  )
end
