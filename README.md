# Freelancer

[![Build Status](https://travis-ci.org/sgraton/freelancer.svg?branch=master)](https://travis-ci.org/sgraton/freelancer)
[![codecov.io](https://codecov.io/github/sgraton/freelancer/coverage.svg?branch=master)](https://codecov.io/github/sgraton/freelancer?branch=master)
[![security](https://hakiri.io/github/sgraton/freelancer/master.svg)](https://hakiri.io/github/sgraton/freelancer/master)

## Install

### Clone the repository

```shell
git clone git@github.com:sgraton/freelancer.git
cd freelancer
```

### Check your Ruby version

```shell
ruby -v
```

The ouput should start with something like `ruby 2.6.3`

If not, install the right ruby version using [rbenv](https://github.com/rbenv/rbenv) (it could take a while):

```shell
rbenv install 2.6.3
```

### Install dependencies

Using [Bundler](https://github.com/bundler/bundler) and [Yarn](https://github.com/yarnpkg/yarn):

```shell
bundle && yarn
```

### Initialize the database

```shell
rails db:create db:migrate db:seed
```