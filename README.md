# README

## Ruby/Rails Version

1. Ruby  `2.7.4`
2. Rails `6.1.3`

## System Dependencies (Mac)

1. [RVM](https://rvm.io/) 1.29.12 or above
2. [Homebrew](https://brew.sh/) 3.4.6 or above
3. Ruby 2.7.4 from RVM
4. [PostgreSQL](https://wiki.postgresql.org/wiki/Homebrew) 14.2 from Homebrew
4. [Node JS](https://changelog.com/posts/install-node-js-with-homebrew-on-os-x) v17.9.0 for webpack from Homebrew
5. [Yarn](https://classic.yarnpkg.com/lang/en/docs/install/#mac-stable) 1.22.18 globally via npm


## Install libraries

```shell
> bundle install
> bundle exec rails webpacker:install
```

## Database Creation & Initialization (Development, Test)

Create a posgresql Session from Shell (bash, zsh, etc.)

```shell
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
> ruby ./bin/webpack-dev-server
```

## Other information to be added later

* Configuration
* How to run the test suite
* Services (job queues, cache servers, search engines, etc.)
* Deployment instructions
