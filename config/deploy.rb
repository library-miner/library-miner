# config valid only for Capistrano 3.1
require 'rvm1/capistrano3'
#require 'whenever/capistrano'

lock '3.2.1'

set :application, 'library-miner'
set :repo_url, 'git@bitbucket-miner:library_miner/library-miner.git'
# git clone の際にローカルの秘密鍵を使用する
set :ssh_options, { forward_agent: true }

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/library-miner'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Shared
set :linked_files, %w{config/database.yml config/secrets.yml config/settings.yml .env}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# RVM
set :rvm_type, :system
set :rvm1_ruby_version, '2.2.0'

# Unicorn
set :unicorn_pid, "#{shared_path}/tmp/pids/unicorn.pid"

# Whenever
#set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
    end
  end

  desc 'upload importabt files'
  task :upload do
    on roles(:app) do |host|
      if test "[ ! -d #{shared_path}/config ]"
        execute :mkdir, '-p', "#{shared_path}/config"
      end
      upload!('config/database.yml',"#{shared_path}/config/database.yml")
      upload!('config/secrets.yml',"#{shared_path}/config/secrets.yml")
      upload!('config/settings.yml',"#{shared_path}/config/settings.yml")
      upload!('.env',"#{shared_path}/.env")
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    end
  end

  #before :started, 'deploy:upload'
  after :finishing, 'deploy:cleanup'
end

namespace :bower do
  desc 'Install bower'
  task :install do
    on roles(:web) do
      within release_path do
        execute :rake, 'bower:install CI=true'
      end
    end
  end
end
before 'deploy:compile_assets', 'bower:install'
