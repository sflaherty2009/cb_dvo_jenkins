# Changelog - cb_dvo_jenkins

All notable changes to this project will be documented in this file.

## [0.2.52] - 2019-03-13

- Configured mysql backup job for trek-wordpress-mysql.

## [0.2.51] - 2019-03-07

- Added init script for adding components needed for knife commands.
- Modified vm_agent.rb so that SAS key was not sitting in plain text in vm_agent recipe.
- Modifying LDAP server.
- Updating traffic drain job, adding environment pinning and acr cleanup job. Adding further credentials for environment pinning job.
- Adding in hybris auto deploy skip job.
- Changing current acr cleanup job.
- Updating environment pinning and metadata pinning.

## [0.2.50] - 2019-03-01

### Added

- Dev3 options for refresh and manual container build jobs.

## [0.2.46] - 2019-01-23

### Added

- Refresh job option for tst2.

## [0.2.44] - 2019-01-11

### Modified

- Removing Dev Hybris container build job. Should now be done in the tbc multibranch pipeline. 

## [0.2.43] - 2019-01-11

### Added

- Added aditional Jenkins job Jenkins_Agent_Cleanup. This job will be used for cleanup of Jenkins Agents once their disks get under 10 GB free space. This job will check agent nodes every 45 minutes.

## [0.2.42] - 2019-01-11

### Modified

- Mispelling of groovy plugin was causing failure in Chef Run. 

## [0.2.41] - 2019-01-11

### Modified

- Added groovy plugin to Jenkins server for use with Jenkins slave cleanup scripts

## [0.2.40] - 2019-01-03

### Modified

- Added test2 option to manual build job.

## [0.2.30] - 2018-12-5

- Changed jenkins agent to advanced image. Pulled VNET and Subnet setting into jenkins agent to hopefully mitigate slowdowns with Junit testing.

### Modified

- Set e2e to build off of nonexistent 'e2e' branch.

## [0.2.29] - 2018-11-30

### Modified

- Updated tbc_e2e job to pull from the develop branch.

## [0.2.26] - 2018-11-28

### Modified

- Updated trilead-api plugin to v1.0.1.

## [0.2.25] - 2018-11-28

### Modified

- Stripped the string 'arm' out of penv in the dvo_docker.xml file.
- Added trilead-api v1.0.0 plugin.

## [0.2.19] - 2018-11-5

### Modified

- Updated cb_dvo_addStorage dependency.

## [0.2.17] - 2018-10-23

### Added

- This changelog file.
