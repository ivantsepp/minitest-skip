module Minitest
  module SkipPlugin
    # Patch runnable.run(reporter, options) so that it
    # recognizes `skip_` methods and records them as skips
    def run(reporter, options = {})
      super
      methods_matching(/^skip_/).each do |method_name|
        # Minitest 5.13 added skip_until as a default method.
        next if method_name == "skip_until"

        test = new(method_name)
        test.time = 0

        skip = Skip.new("Skipped from SkipPlugin")
        source = test.method(method_name).source_location
        skip.set_backtrace(["#{source[0]}:#{source[1]}"])
        test.failures << skip

        # Minitest 5.11 Added Minitest::Result#from
        if Minitest.const_defined?(:Result)
          test = Minitest::Result.from(test)
        end

        # Minitest 5.10.0 Added #prerecord
        # see https://github.com/seattlerb/minitest/commit/c797bafa94838a98a9e41805df4517a7f0343d44
        reporter.prerecord self, method_name if reporter.respond_to? :prerecord
        reporter.record(test)
      end
    end
  end

  def self.plugin_skip_init(options)
    Runnable.singleton_class.prepend(SkipPlugin)
  end
end
