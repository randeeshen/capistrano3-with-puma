## 使用 CAPISTRANO3 和 PUMA 进行部署

### 添加需要使用到的gem

```ruby
group :development do
  gem 'capistrano-rails'
  gem 'capistrano3-puma'
  gem 'capistrano-rvm'
end

gem 'puma'    #使用puma做server
```

### 编辑配置文件

* 初始化cap:
```ruby
$ cap install
```

* 初始化后，会生成多个我们需要用的文件，代码可以直接使用Capfile：
```ruby
require 'capistrano/setup'
require 'capistrano/deploy'

require 'capistrano/rvm'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'capistrano/puma'      #因为使用puma做Server，所以要加上这一条

Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }
```

* 然后关键的一些task都是写在config/deploy.rb里，假设我们的项目名字叫example：
```ruby
lock '3.1.0'

set :application, 'example'      #项目名称
set :repo_url, 'git@example.com:example.git'    #git仓库的存放地址

set :linked_files, %w{config/database.yml}      #需要做链接的文件，一般database.yml和部分配置文件
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
    end
  end
  after :restart, :'puma:restart'    #添加此项重启puma
  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    end
  end
end
```

* 这里我们只使用production环境，所以只对config/deploy/production.rb介绍，这是cap3的一个特别的地方，它把不同环境的部署方案分开放在deploy文件内，并且部署命令改为cap 环境名称 deploy，这样分开来后，整个部署配置文件结构变得非常清晰：
```ruby
role :app, %w{deploy@example.com}     #服务器地址
role :web, %w{deploy@example.com}
role :db,  %w{deploy@example.com}
server 'example.com', user: 'deploy', roles: %w{web app}

set :deploy_to, '/home/deploy/example'     #部署的位置

# PUMA
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,   "#{shared_path}/tmp/pids/puma.pid"
set :puma_bind, "unix:///tmp/example.sock"
#根据nginx配置链接的sock进行设置，需要唯一
set :puma_conf, "#{shared_path}/puma.rb"
set :puma_access_log, "#{shared_path}/log/puma_error.log"
set :puma_error_log, "#{shared_path}/log/puma_access.log"
set :puma_role, :app
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
set :puma_threads, [0, 16]
set :puma_workers, 0
set :puma_init_active_record, false
set :puma_preload_app, true
```

### 开始部署

* 执行cap production deploy:check检查涉及需要用上的部署文件是否齐全，运行后会检测出不存在database.yml，需要在/home/deploy/example/shared/config/中创建database.yml，可以写一个task把文件上传上去，也可以直接创建。
* 完成后，就可以执行cap production deploy进行部署了。

### 总结

使用capistrano3后，发现比2方便了很多，而且整个结构非常清晰，配合puma使用非常方便。上面介绍的是非常简单的，因为还没有涉及自己写task，所以以后应该会写一个专门介绍如何写部署task的文章。

如果希望把自己的项目从capistrano2升级到3的话，可以参考 [Capistrano 3 Upgrade Guide](https://semaphoreapp.com/blog/2013/11/26/capistrano-3-upgrade-guide.html)。

原文：[使用CAPISTRANO3和PUMA进行部署](http://jesktop.com/2014/02/23/capistrano3-with-puma/)
