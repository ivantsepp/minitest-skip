require_relative 'test_helper'

class TestSkipMethods < Minitest::Test

  def setup
    @@ran = false
    @test = Class.new(Minitest::Test) do
      def skip_test_name
        @@ran = true
      end
    end
    @output = StringIO.new("")

    @reporter = Minitest::CompositeReporter.new
    @reporter << @summary_reporter = Minitest::SummaryReporter.new(@output)
    @reporter << @progress_reporter = Minitest::ProgressReporter.new(@output)
    @reporter.start
  end

  def test_run_skip
    @test.run(@reporter)
    @reporter.report
    assert_includes @output.string.dup, "1 runs, 0 assertions, 0 failures, 0 errors, 1 skips"
  end

  def test_run_skip_verbose
    Object.const_set("ExampleSkipTest", @test)
    @progress_reporter.options = { verbose: true }
    @summary_reporter.options = { verbose: true }

    @test.run(@reporter)
    @reporter.report

    assert_includes @output.string.dup, "#skip_test_name = 0.00 s = S"
    assert_includes @output.string.dup, <<-EOM.gsub(/^ {4}/, "")
      1) Skipped:
    ExampleSkipTest#skip_test_name [test/test_skip_methods.rb:8]:
    Skipped from SkipPlugin
    EOM

  end

  def test_skip_methods_are_recorded
    @test.run(@reporter)
    result = @summary_reporter.results.first
    failure = result.failures.first
    assert result.skipped?
    assert_equal Minitest::Skip, failure.error.class
    assert_equal "Skipped from SkipPlugin", failure.error.message
    assert_equal "test/test_skip_methods.rb:8", failure.location
  end

  def test_skip_methods_are_not_executed
    @test.run(@reporter)
    refute @@ran, "skip methods should not be executed"
  end

end
