# Minitest Skip

This gem provides alternative ways of skipping a test. Normally a skipped test in Minitest looks like:

```ruby
def test_that_is_flaky
  skip "Figure out why this flakes"
end
```

The gotcha for skipping tests with the `skip` keyword is that the `setup` and `teardown` blocks are still executed. This can be costly for acceptance tests since their setup usually involves starting a browser among other slow things.

This gem will allow you to use methods that begin with `skip_` to mark a test as skipped. It modifies Minitest such that it will recognize these skip methods and correctly report the results.

```ruby
require "minitest/autorun"
class TestSkip < Minitest::Test
  def setup
    sleep 2 # costly setup block
  end

  def skip_test_that_is_temporarily_broken
    # ...
  end
end

# ruby test/test_skip.rb
# Run options: --seed 54134

# # Running:

# S

# Finished in 0.001663s, 601.3537 runs/s, 0.0000 assertions/s.

# 1 runs, 0 assertions, 0 failures, 0 errors, 1 skips

# You have skipped tests. Run with --verbose for details.
```

This gem also adds `xit` and `xdescribe` if you prefer the spec style syntax for Minitest.

```ruby
require "minitest/autorun"
require "minitest/spec"
require "minitest/skip_dsl"

describe "Test" do
  it "normal" do assert true end
  xit "skipped" do assert false end
  xdescribe "All skipped" do
    it "nested skip" do assert false end
  end
end

```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'minitest-skip'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install minitest-skip

And that's it! This is a Minitest plugin which means that it will be autoloaded. If you want to use `xit` and `xdescribe` methods, you also need to `require "minitest/skip_dsl"`.

## Contributing

1. Fork it ( https://github.com/ivantsepp/minitest-skip/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
