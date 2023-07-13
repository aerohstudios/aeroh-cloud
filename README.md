# README

## Ruby/Rails Version

1. Ruby  `2.7.4`
2. Rails `6.1.3`

## System Dependencies (Mac)

1. [Homebrew](https://brew.sh/) 3.4.6 or above
2. [RVM](https://rvm.io/) 1.29.12 or above
   1. RVM requires [gnupg](https://gnupg.org/), can be installed with homebrew `gnupg` package.
3. Ruby 2.7.4 from RVM
4. [PostgreSQL](https://wiki.postgresql.org/wiki/Homebrew) 14.2 from Homebrew
5. [Node JS](https://changelog.com/posts/install-node-js-with-homebrew-on-os-x) v17.9.0 for webpack from Homebrew
6. [Yarn](https://classic.yarnpkg.com/lang/en/docs/install/#mac-stable) 1.22.18 globally via npm

```shell
> /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
> curl -sSL https://get.rvm.io | bash -s stable # this will ask you to install gpg keys
> rvm install ruby-2.7.4
> brew install postgresql
> brew install node # install node if you don't have it already
> npm install --global yarn
```


## Install libraries

```shell
> bundle install
> bundle exec rails webpacker:install
```

## Database Creation & Initialization (Development, Test)

Create a posgresql Session from Shell (bash, zsh, etc.)

```shell
> initdb --locale=C -E UTF-8 /opt/homebrew/var/postgresql@14 # (not required) homebrew runs this by default
> brew services restart postgresql@14 # make sure postgress is up and running
>
> psql -h localhost postgres
```

Create `aeroh_cloud_user` user and give database creation access

```sql
postgres=# create user aeroh_cloud_user;
postgres=# ALTER USER aeroh_cloud_user CREATEDB;
```

Run rake database commands to create db and run migrations.

```shell
> bundle exec rake db:create
> bundle exec rake db:migrate RAILS_ENV=development
```

## Start server

We need to start rails server and webpack server. So, Run the two commands in two different terminal sessions.

```shell
> bundle exec rails s
> npm install --force # needed 1st time for webpack dev server
> ruby ./bin/webpack-dev-server
```

## Run Test Suite (Rspec)

```shell
> rspec
```

## Deployment

Aeroh Cloud Runs on Heroku

Add the Heroku App Repository in your Git Config

```
git remote add heroku https://git.heroku.com/aeroh-cloud.git
```

Push to master, and that will trigger the production deployment pipeline.

```
git push heroku master
```

## Other information to be added later

* Configuration
* How to run the test suite
* Services (job queues, cache servers, search engines, etc.)
* Deployment instructions
