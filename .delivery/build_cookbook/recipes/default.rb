#
# Cookbook Name:: build_cookbook
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
include_recipe 'delivery-truck::default'
include_recipe 'cb_dvo_terraform::install'
