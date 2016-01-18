#
# Author:: Andrew Jungklaus <lostkangaroo@lostkangaroo.net>
# Cookbook Name:: dlamp
# Recipe:: drupal_repo
# Description:: Clones Drupal Repo specific to version
#   Development Environment
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

Chef::Log.info "Attempting to locate databag git_repo"

if Chef::DataBag.list.key?('git_repo')

  Chef::Log.info "git_repo data loaded"
   begin
    repos = data_bag('git_repo').collect do |item|
      repo = data_bag_item('git_repo', item)

      # whole sale make sure the destination is writeable
      directory "#{repo['destination']}" do
        mode "0777"
      end

      # add the git repo to known hosts so we don't have issues pulling things in
      ssh_known_hosts repo['fdqn'] do
        user "vagrant"
      end

      if not repo['revision']
        repo['revision'] = "HEAD"
        Chef::Log.info "No Repo Revision, using HEAD"
      end

      if repo['deploy_key']
        Chef::Log.info "Adding deploy key to Vagrant user"

        # create a ssh key wrapper we can use if a deploy key is needed
        file "/home/vagrant/#{repo['id']}.git_wrapper.sh" do
          owner "vagrant"
          mode "0755"
          content "#!/bin/sh\nexec /usr/bin/ssh -i /home/vagrant/.ssh/#{repo['id']}.deploy_rsa \"$@\""
        end

        # create the key itself to be used
        file "/home/vagrant/.ssh/#{repo['id']}.deploy_rsa" do
          owner "vagrant"
          mode "0600"
          content repo['deploy_key']
        end

        # add this key to ssh config file
        ssh_config repo['fdqn'] do
          options 'User' => 'git', 'IdentityFile' => "/home/vagrant/.ssh/#{repo['id']}.deploy_rsa"
        end
      end

      git repo['destination'] do
        repository repo['repo']
        revision repo['revision']
        user "vagrant"
        if repo['deploy_key']
          ssh_wrapper "/home/vagrant/" + repo['id'] + ".git_wrapper.sh"
        end
        action :sync
      end

      directory repo['destination'] do
        mode "777"
      end
    end
   rescue
     Chef::Log.info "Could not load data bag 'git_repo'"
   end
end
