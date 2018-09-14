jenkins_password_credentials 'conHybris' do
  id          'conHybris'
  description 'creds for use by hybris container storage'
  password    'sMM3oPIUwy8BsiSnke/A57NTKPqUX0Vs'
end

jenkins_password_credentials 'conWeb' do
  id          'conWeb'
  description 'creds for use by web container storage'
  password    'C7HSI+J1Ro7Fz7pnzS7me2mm4zitJEAk'
end

jenkins_password_credentials 'TrekDevOps' do
  id          'TrekDevOps'
  description 'creds used for pulls/push to bitbucket'
  password    'WQrULM66cGyPyB'
end

jenkins_password_credentials 'conBase' do
  id          'conBase'
  description 'creds for use by base container storage'
  password    'NrD6bvZ4w7Xjk0TA6KYkfT5se/kiQErD'
end
