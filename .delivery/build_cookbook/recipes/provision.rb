#
# Cookbook Name:: build_cookbook
# Recipe:: provision
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
include_recipe 'delivery-truck::provision'
include_recipe 'cb_dvo_terraform::acceptance' if workflow_stage?('acceptance')
