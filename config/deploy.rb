require 'capistrano/ext/multistage'
require 'bundler/capistrano'

set :application, "samlLjackson"
set :repository, "git://github.com/dubsdaazn/samlLjackson.git"
set :scm, :git
set :git_enable_submodules, 1
set :user, "deploy"
set :copy_cache, "#{ENV['HOME']}/deploy/#{application}"
set :copy_exclude, ['.git']
set :deploy_to, "/var/www/#{application}"
set :deploy_via, :copy
set :keep_releases, 2
set :use_sudo, false
set :rails_env, lambda{ stage }
default_run_options[:pty] = true

def tag_to_deploy
  require_annotated = /refs\/tags\/(v.+\^\{\})$/
  all_version_tags      = `git ls-remote --tags #{repository}`.scan(require_annotated).flatten
  sorted_version_tags   = all_version_tags.sort_by{|v| v.split('.').map{|nbr| nbr[/\d+/].to_i}}
  stripped_version_tags = sorted_version_tags.map{|tag| tag.strip}
  puts "stripped_version_tags: #{stripped_version_tags.class}"

  last_x_tags = []
  if stripped_version_tags.size > 10
    last_x_tags         = stripped_version_tags[-10..-1]
    puts "last_ten_tags: #{last_x_tags}"
  else
     max = stripped_version_tags.size
     last_x_tags         = stripped_version_tags[-max..-1]
    puts "last_ten_tags: #{last_x_tags}"
  end

  tag = Capistrano::CLI.ui.choose { |menu|
    menu.choices *last_x_tags
    menu.header    = "Available tags"
    menu.prompt    = "Tag to deploy?"
    menu.select_by = :index_or_name
  }
end

def current_branch
  if stage == :acceptance
    branch = "dev"
  elsif stage == :qa
    branch = "qa"
  else
    branch = 'master'
  end
  branch
end

task(:set_branch) do
  set :branch, stage == :production ? tag_to_deploy : current_branch
end
after 'multistage:ensure', :set_branch

task(:migrate) do
  env = (stage == :acceptance) ? 'ci' : stage
  run "cd #{current_release} && bundle exec rake db:migrate RAILS_ENV=#{env}"
end
after 'deploy:update_code', :migrate

namespace :primedia do
  desc "Put the version that was deployed into RAILS_ROOT/VERSION"
  task :add_version_file, :roles => :app do
    run "cd #{current_path} && echo #{branch} > VERSION"
  end
end

namespace :deploy do
  desc "Deploy and do everything else. Ever."

  task :full do
    default
    primedia.add_version_file
  end

  task :start, :roles => :app do
    # run "chown -R deploy:nginx #{current_release}"
    if stage == :acceptance
      run "echo START APP MANUALLY"
      # run "sudo /etc/init.d/unicorn start"
    else
      run "touch #{current_release}/tmp/restart.txt"
    end
  end

  task :stop, :roles => :app do
    # Do nothing.
    if stage == :acceptance
      run "echo STOP APP MANUALLY"
      # run "sudo /etc/init.d/unicorn stop"
    end
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    # run "sudo chown -R deploy:nginx #{current_release}"
    if stage == :acceptance
      run "echo RESTART APP MANUALLY"
      # run "sudo /etc/init.d/unicorn stop"
      # run "sudo /etc/init.d/unicorn start"
    else
      run "touch #{current_release}/tmp/restart.txt"
    end
  end
end