azure_auth = data_bag_item('jenkins', 'credentials')

jenkins_password_credentials 'conHybris' do
  id          'conHybris'
  description 'creds for use by hybris container storage'
  password    azure_auth['service_accounts']['conHybris']
end

jenkins_password_credentials 'conWeb' do
  id          'conWeb'
  description 'creds for use by web container storage'
  password    azure_auth['service_accounts']['conWeb']
end

jenkins_password_credentials 'conSolr' do
  id          'consolr'
  description 'creds for use by web container storage'
  password    azure_auth['service_accounts']['consolr']
end

jenkins_password_credentials 'TrekDevOps' do
  id          'TrekDevOps'
  description 'creds used for pulls/push to bitbucket'
  password    azure_auth['service_accounts']['TrekDevOps']
end

jenkins_password_credentials 'conBase' do
  id          'conBase'
  description 'creds for use by base container storage'
  password    azure_auth['service_accounts']['conBase']
end

jenkins_password_credentials 'conApacheMaintenance' do
  id          'conApacheMaintenance'
  description 'creds for use by base container storage'
  password    azure_auth['service_accounts']['conApacheMaintenance']
end

jenkins_password_credentials 'grant_pierce' do
  id          'grant_pierce'
  description 'grant_pierce app password for pull request analyzer'
  password    azure_auth['service_accounts']['grant_pierce']
end

jenkins_password_credentials 'scott_flaherty' do
  id          'scott_flaherty'
  description 'scott_flaherty app password for tbc multibranch job'
  password    azure_auth['service_accounts']['scott_flaherty']
end
