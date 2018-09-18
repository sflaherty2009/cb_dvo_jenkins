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
