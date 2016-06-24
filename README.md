# WebMinion
- [![Build](http://img.shields.io/travis-ci/jibeinc/web_minion.svg?style=flat-square)](https://travis-ci.org/jibeinc/web_minion)
- [![Quality](http://img.shields.io/codeclimate/github/jibeinc/web_minion.svg?style=flat-square)](https://codeclimate.com/github/jibeinc/web_minion)
- [![Coveralls](https://img.shields.io/coveralls/jibeinc/web_minion.svg?style=flat-square)](https://coveralls.io/github/jibeinc/web_minion)
- [![Issues](http://img.shields.io/github/issues/jibeinc/web_minion.svg?style=flat-square)](http://github.com/jibeinc/web_minion/issues)
- [![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](http://opensource.org/licenses/MIT)

WebMinion is a metadata-driven browser automation library. Instead of writing a custom bot with lots of code, you can write a JSON configuration and give it to WebMinion to run instead. You can use webdrivers like Mechanize, Capybara/Selenium (TODO) and Capybara/PhantomJS (TODO).

*NOTE* The public API is currently unstable and subject to change.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'web_minion'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install web_minion

## Usage

```ruby
flow = JSON.parse(File.read("./test/test_json/test_json_one.json"))
web_minion = WebMinion.create(flow)
web_minion.perform
```

### Sample Flow

Here's a sample login flow:

    {
      "config": {},
      "flow": {
        "name": "Login Flow",
        "actions": [
          {
            "name": "Login",
            "key": "load_login_page",
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

Bug reports and pull requests are welcome on GitHub at https://github.com/jibeinc/web_minion. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
