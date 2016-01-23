module Minitest
  module SkipPlugin
    def run(reporter, options = {})
      super
      methods_matching(/^skip_/).each do |method_name|
        test = self.new(method_name)
        test.time = 0

        skip = Skip.new("Skipped from SkipPlugin")
        source = test.method(method_name).source_location
        skip.set_backtrace(["#{source[0]}:#{source[1]}"])
        test.failures << skip

        reporter.record(test)
      end
    end
  end

  def self.plugin_skip_init(options)
    Runnable.singleton_class.prepend(SkipPlugin)
  end
end
