# CalCentral

* Master: [![Build Status](https://travis-ci.com/sis-berkeley-edu/calcentral.svg?branch=master)](https://travis-ci.com/sis-berkeley-edu/calcentral)
* QA: [![Build Status](https://travis-ci.com/sis-berkeley-edu/calcentral.svg?branch=qa)](https://travis-ci.com/sis-berkeley-edu/calcentral)

## Dependencies

* Administrator privileges
* [Bundler](http://gembundler.com/rails3.html)
* [Git](https://help.github.com/articles/set-up-git)
* [JDBC Oracle driver](http://www.oracle.com/technetwork/database/enterprise-edition/jdbc-112010-090769.html)
* [Java 8 SDK](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
* [JRuby 9.2.9.0](http://jruby.org/)
* [Node.js >=8.9.4](http://nodejs.org/)
* [Rubygems 2.5.1](https://rubygems.org/pages/download)
* [RBEnv](https://github.com/rbenv/rbenv) - Ruby environment manager

## Installation

1. Install Java 8 JDK:

    Install [Java SE Development Kit 8u241)](https://www.oracle.com/technetwork/java/javase/downloads/index.html)

1. Install Homebrew:

    Install [Homebrew](http://brew.sh/)

    ```bash
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    ```

    Update Homebrew

    ```bash
    brew update
    ```

    Upgrade Homebrew packages
    ```bash
    brew upgrade
    ```

    Cleanup Homebrew
    ```bash
    brew cleanup
    ```

    Check Homebrew for issues
    ```bash
    brew doctor
    ```

1. [Fork this repository], then:

    with ssh (see [Connecting to Github with SSH])

    ```bash
    git clone git@github.com:[your GitHub Account]/calcentral.git
    # e.g. git clone git@github.com:johnsmith/calcentral.git
    ```

    or via https - (see [Caching Your Github Password in Git])

    ```bash
    git clone https://github.com/[your Github Account]/calcentral.git
    # e.g. git clone https://github.com/johnsmith/calcentral.git
    ```

[Fork this repository]: https://github.com/sis-berkeley-edu/calcentral/wiki/Workflow
[Connecting to Github with SSH]: https://help.github.com/articles/connecting-to-github-with-ssh/
[Caching Your Github Password in Git]: https://help.github.com/articles/caching-your-github-password-in-git/

1. Install JRuby:

    Use [rbenv](https://github.com/rbenv/rbenv)

    ```bash
    # install rbenv
    brew install rbenv

    # initialize your rbenv environment in ~/.rbenv
    rbenv init

    # modify your ~/.bash_profile (or equivalent config)
    # to run:
    # eval "$(command rbenv init -)"

    # open a new terminal to init rbenv, go into calcentral
    # directory
    cd calcentral

    # install jruby version used by calcentral
    rbenv install

    # update RBenv and RubyBuild
    brew upgrade rbenv ruby-build

    # display version of rbenv
    rbenv --version

    # display ruby versions installed (* indicating in use)
    rbenv versions

    # display all available versions
    rbenv install --list-all
    ```

1. Make JRuby faster for local development by running this or put in your .bashrc:

    ``` bash
    export JRUBY_OPTS="--dev"
    ```

1. Download the appropriate gems with [Bundler](http://gembundler.com/rails3.html):

    **Important**: Make sure you have the JRuby-upgraded CalCentral codebase in
    your calcentral directory before running `bundle install`.

    ```bash
    gem install bundler
    bundle install
    rbenv rehash
    ```

[Bundler]: http://gembundler.com/rails3.html

1. Set up a local settings directory:

    ```bash
    mkdir ~/.calcentral_config
    ```

    Default settings are loaded from your source code in `config/settings.yml`
    and `config/settings/ENVIRONMENT_NAME.yml`. For example, the configuration
    used when running tests with `RAILS_ENV=test` is determined by the
    combination of `config/settings/test.yml` and `config/settings.yml`.
    Because we don't store passwords and other sensitive data in source code,
    any RAILS_ENV other than `test` requires overriding some default settings.
    Do this by creating `ENVIRONMENT.local.yml` files in your
    `~/.calcentral_config` directory. For example, your
    `~/.calcentral_config/development.local.yml` file may include access tokens
    and URLs for a locally running Canvas server.
    You can also create Ruby configuration files like "settings.local.rb" and
    "development.local.rb" to amend the standard `config/environments/*.rb`
    files.

1. Install JDBC driver (for Oracle connection)

    * Download [ojdbc8.jar]
    * Copy `ojdbc8.jar` to the applicable directory:
      * RVM - `~/.rvm/rubies/jruby-9.2.9.0/lib/`
      * rbenv - `~/.rbenv/versions/jruby-9.2.9.0/lib/`

[ojdbc8.jar]: https://www.oracle.com/database/technologies/appdev/jdbc-ucp-19c-downloads.html

1. Create local SQLite database

    Run rails console

    ```shell
    # run rake task to create database
    require 'rake'
    Rails.application.load_tasks
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:schema:load'].invoke
    ```

[ojdbc7_g.jar]: http://www.oracle.com/technetwork/database/features/jdbc/jdbc-drivers-12c-download-1958347.html

1. Make yourself a super-user:

    ```bash
    bundle exec rake superuser:create UID=[your numeric CalNet UID]
    # e.g. rake superuser:create UID=61889
    ```

1. Install Node Version Manager (NVM)

    ```bash
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.1/install.sh | bash
    ```

    [Configure your shell] to use the Node version specified in `.nvmrc`.

    Open a new terminal window to ensure that NVM is present. If you go into
    the CalCentral folder it should recognize the `.nvmrc` file and install
    the version of Node specified.

    You can verify that it's using the right version using `which`:

    ```bash
    $ cat .nvmrc
    10.15.3
    $ which npm
    /Users/janesmith/.nvm/versions/node/v10.15.3/bin/npm
    ```

[Configure your shell]: https://github.com/nvm-sh/nvm#deeper-shell-integration

1. Install the front-end tools:

    ```bash
    npm install
    ```

1. Start the front-end development server, or kick off a Webpack build:

    ```bash
    # starts development server
    npm run dev

    # starts build process
    npm run build
    ```

1. Start the server:

    ```bash
    rails s
    ```

1. Access your rails server at [localhost:3000], or the Webpack development
server at [localhost:8080].

[localhost:3000]: http://localhost:3000/
[localhost:8080]: http://localhost:8080/

**Note**: Usually you won't have to do any of the following steps when you're
developing on CalCentral.

## Back-end Testing

Back-end (rspec) tests live in `spec/*`.

To run the tests from the command line:

```bash
rspec
```

To run the tests faster, use spork, which is a little server that keeps the
Rails app initialized while you change code
and run multiple tests against it. Command line:

```shell
spork
# (...wait a minute for startup...)
rspec --drb spec/lib/my_spec.rb
```

## Front-end Linting

Front-end linting can be done by running the following commands:

```bash
npm run lint
```

This will check for any potential JavaScript issues and whether you formatted
the code correctly.

## Role-Aware Testing

Some features of CalCentral are only accessible to users with particular roles,
such as `student`. These features may be invisible when logged in as yourself.
In particular:

My Academics will only appear in the navigation if logged in as a student.
However, the "Oski Bear" test student does not fake data loaded on dev and QA.
To test My Academics, log in as user  `test-212385` or `test-212381` (ask a
developer for the passwords to these if you need them). Once logged in as a test
student, append `/academics` to the URL to access My Academics.

## Debugging

### Emulating production mode locally

1. Make sure you have a separate production database:

    ```shell
    psql postgres
    create database calcentral_production;
    grant all privileges on database calcentral_production to calcentral_development;
    ```

1. In calcentral_config/production.local.yml, you'll need the following entries:

    ```yml
    secret_token: "Some random 30-char string"
    postgres: [credentials for your separate production db (copy/modify from development.local.yml)]
    google_proxy: and canvas_proxy: [copy from development.local.yml]
      application:
        serve_static_assets: true
    ```

1. Populate the production db by invoking your production settings:

    ```shell
    RAILS_ENV="production" rake db:schema:load db:seed
    ```

1. Precompile the front-end assets

    ```bash
    npm run build
    ```

1. Start the server in production mode:

    ```bash
    rails s -e production
    ```

1. If you're not able to connect to Google or Canvas, export the data in the
   oauth2 from your development db and import them into the same table in your
   production db.

1. After testing, remember to remove the static assets, or run another build
   before the next task.

### Test connection

Make sure you are on the Berkeley network or connected through
[preconfigured VPN] for the Oracle connection. If you use a VPN, use group
`1-Campus_VPN`.

[preconfigured VPN]: https://kb.berkeley.edu/page.php?id=23065

### Enable basic authentication

Basic authentication will enable you to log in without using CAS.
This is necessary when your application can't be CAS authenticated or when
you're testing mobile browsers.

**Note**: only enable this in fake mode or in development.

1. Add the following setting to your `environment.yml` file (e.g. `development.yml`):

    ```bash
    developer_auth:
      enabled: true
      password: topsecret!
    ```

1. (Re)start the server for the changes to take effect.

1. Click on the footer (Berkeley logo) when you load the page.

1. You should be seeing the [Basic Auth screen](http://cl.ly/SA6C). As the login
   you should use a UID (e.g. `61889` for oski) and then the password from the
   settings file.

### "Act As" another user

To help another user debug an issue, you can "become" them on CalCentral. To
assume the identity of another user, you must:

* Currently be logged in as a designated superuser
* Be accessing a machine/server which the other user has previously logged into
  (e.g. from localhost, you can't act as a random student, since that student
  has probably never logged in at your terminal)

Access the URL:

`https://[hostname]/act_as?uid=123456`

where 123456 is the UID of the user to emulate.

**Note**: The Act As feature will only reveal data from data sources we control,
e.g. Canvas. Google data will be completely suppressed, __EXCEPT__ for test
users. The following user uids have been configured as test users.

* 11002820 - "Tammi Chang"
* 61889 - "Oski Bear"
* All IDs listed on the [Universal Calnet Test IDs] page

To become yourself again, access: `https://[hostname]/stop_act_as`

[Universal Calnet Test IDs]: https://wikihub.berkeley.edu/display/calnet/Universal+Test+IDs

### Logging

Logging behavior and destination can be controlled from the command line or
shell scripts via env variables:

* `LOGGER_STDOUT=false` - Only log to the default files
* `LOGGER_STDOUT=true` - Log to standard output as well as the default files
* `LOGGER_STDOUT=only` - Only log to standard output
* `LOGGER_LEVEL=DEBUG` - Set logging level; acceptable values are 'FATAL',
                         'ERROR', 'WARN', 'INFO', and 'DEBUG'

### Tips

1. On Mac OS X, to get RubyMine to pick up the necessary environment variables,
   open a new shell, set the environment variables, and:

    ```bash
    /Applications/RubyMine.app/Contents/MacOS/rubymine &
    ```

1. If you want to explore the Oracle database on Mac OS X, use [SQL Developer].

[SQL Developer]: http://www.oracle.com/technetwork/developer-tools/sql-developer/overview/index.html

### Styleguide

See [docs/styleguide.md](docs/styleguide.md).

## Creating timeshifted fake data feeds

Proxies running in fake mode use WebMock to substitute fixture data for
connections to external services (Canvas, Google, etc). This fake data lives in
`fixtures/json` and `fixtures/xml`.

Fixture files can represent time information by tokens that are substituted with
appropriately shifted values when fixture data is loaded. See
`config/initializers/timeshift.rb` for the dictionary of substitutions.

## Rake tasks

To view other rake task for the project: `rake -T`

* `rake spec:xml` - Runs rake spec, but pipes the output to xml using the
`rspec_junit_formatter` gem, for JUnit compatible test result reports

## Installing Memcached

Dev, QA, and Production CalCentral environments use memcached as a cache store
in place of the default ActiveSupport cache store.

To set this up locally, perform the following steps:

1. Install and run [memcached](http://memcached.org/).

1. Add the following lines to development.local.yml:

```yml
cache:
  store: "memcached"
```

## Memcached tasks

A few rake tasks to help monitor statistics and more:

* `rake memcached:clear` - Invalidate all memcached keys and reset memcached
  stats from all cluster nodes.
* `rake memcached:get_stats` - Fetch memcached stats from all cluster nodes.
  Per-slab stats may point out specific types of data which are being overcached
  or undercached, or indicate a need to reconfigure memcached.
* `rake memcached:dump_slab slab=NUMBER` - Shows which cached items are
  currently stored in the "slab" with the given ID. The list won't include the
  keys of expired or evicted items.

* __WARNING:__ do not run `rake memcached:clear` on the production cluster
  unless you know what you're doing!
* All `memcached` tasks take the optional param of `hosts`. So, if say you
  weren't running these tasks on the cluster layers themselves, or only wanted
  to tinker with a certain subset of clusters:
  
  `rake memcached:get_stats hosts="localhost:11212,localhost:11213,localhost:11214"`

## Using the feature toggle

To selectively enable/disable a feature, add a property to the `features`
section of settings.yml, e.g.:

```yml
features:
  wizbang: false
  neato: true
```

After server restart, these properties will appear in each users' status feed.
You can now use `data-ng-if` in Angular to wrap the feature:

```html
<div data-ng-if="user.profile.features.neato">
  Some neato feature...
</div>
```
