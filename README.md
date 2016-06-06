# JibeRulesetBot
- [![Coveralls](https://img.shields.io/coveralls/jibeinc/jibe_ruleset_bot.svg?style=flat-square)](https://img.shields.io/coveralls/jibeinc/jibe_ruleset_bot.svg)
- [![Quality](http://img.shields.io/codeclimate/github/jibeinc/jibe_ruleset_bot.svg?style=flat-square)](https://codeclimate.com/github/jibeinc/jibe_ruleset_bot)
- [![Coverage](http://img.shields.io/codeclimate/coverage/github/jibeinc/jibe_ruleset_bot.svg?style=flat-square)](https://codeclimate.com/github/jibeinc/jibe_ruleset_bot)
- [![Build](http://img.shields.io/travis-ci/jibeinc/jibe_ruleset_bot.svg?style=flat-square)](https://travis-ci.org/jibeinc/jibe_ruleset_bot)
- [![Version](http://img.shields.io/gem/v/architecture.svg?style=flat-square)](https://rubygems.org/gems/architecture)
- [![Issues](http://img.shields.io/github/issues/jibeinc/jibe_ruleset_bot.svg?style=flat-square)](http://github.com/jibeinc/jibe_ruleset_bot/issues)
- [![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](http://opensource.org/licenses/MIT)

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/jibe_ruleset_bot`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jibe_ruleset_bot'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jibe_ruleset_bot

## Usage

### Sample Flow

Here's a sample login flow:

    {
      "config": {},
      "flow": {
        "name": "Login Flow",
        "actions": [
          {
            "name": "Login",
            "key": 'load_login_page',
            "starting": true,
            "steps":
            [
              {
                "name": "Go to accounts login page",
                "target": "https://example.com/login",
                "method": "go"
              },
              {
                "name": "Get login form",
                "method": "get_form",
                "target": {
                  "name": "login"
                }
              },
              {
                "name": "Fill in email",
                "method": "fill_in_input",
                "retain_element": true,
                "target": {
                  "id": "email"
                },
                "value": "PUT USERNAME HERE"
              },
              {
                "name": "Fill in password",
                "method": "fill_in_input",
                "retain_element": true,
                "target": {
                  "id": "password"
                },
                "value": "PUT PASSWORD HERE"
              },
              {
                "name": "Submit login",
                "method": "submit"
              },
              {
                "name": "Verify logged in page",
                "is_validator": true,
                "method": "body_includes",
                "value": "Welcome Back"
              }
            ]
          }
        ]
      }
    }

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jibeinc/jibe_ruleset_bot. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
