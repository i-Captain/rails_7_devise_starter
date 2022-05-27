require File.expand_path("./environment", __dir__)

# config valid for current version and patch releases of Capistrano
lock "~> 3.17.0"

set :application, "myapp"
set :repo_url, "git@github.com:i-Captain/rails_7_devise_starter.git"
set :branch, ENV['BRANCH'] || `git rev-parse --abbrev-ref HEAD`.chomp

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Deploy to the user(deploy)'s home directory
set :deploy_to, "/home/deploy/#{fetch :application}"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"
append :linked_files, "config/master.key", "config/database.yml"

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'public/system', 'public/uploads'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 10

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure


namespace :deploy do
  desc 'Tag the successful deploy'
  task :settag do
    `
      git tag deploy_#{fetch :rails_env}_#{fetch :release_timestamp}
      git push origin #{fetch :branch} --tags
    `
  end
end

after 'deploy', 'deploy:settag'