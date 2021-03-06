# encoding: UTF-8
#
# Cookbook Name:: compass-really
# Recipe:: default
#
# Copyright 2013, Opscode, Inc.
# Copyright 2013, AT&T Services, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# pull latest rally image
docker_image = node['compass']['rally_image']
execute "pull latest rally image" do
  command "docker pull #{docker_image}"
end

remote_directory "/var/lib/rally-docker/scenarios" do
  source "scenarios"
  recursive true
  mode "0755"
  action :create_if_missing
end

cookbook_file "check_health.py" do
  mode "0755"
  path "/var/lib/rally-docker/check_health.py"
end

# load variables
rally_db = node['mysql']['bind_address'] + ":#{node['mysql']['port']}"
deployment_name = node.name.split('.')[-1]
endpoint = node['compass']['hc']['url']
admin = node['openstack']['identity']['admin_user'] || 'admin'
pass = node['openstack']['identity']['users'][admin]['password']

template "/var/lib/rally-docker/Dockerfile" do
  source 'Dockerfile.erb'
  variables(
            RALLY_DB: rally_db)
  action :create_if_missing
end

template "/var/lib/rally-docker/deployment.json" do
  source 'deployment.json.erb'
  variables(
            user: admin,
            password: pass,
            url: endpoint,
            tenant: 'admin')
  action :create_if_missing
end

execute "build running image" do
  command "docker build -t #{deployment_name} /var/lib/rally-docker"
end
