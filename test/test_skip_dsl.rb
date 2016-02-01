require_relative 'test_helper'
require 'minitest/skip_dsl'

class TestSkipDSL < Minitest::Test

  def setup
    @output = StringIO.new("")

    @reporter = Minitest::CompositeReporter.new
    @reporter << @summary_reporter = Minitest::SummaryReporter.new(@output)
    @reporter << @progress_reporter = Minitest::ProgressReporter.new(@output)
    @reporter.start
  end

  def test_xit
    test = describe "Test" do
      it "normal" do assert true end
      xit "skipped" do assert false end
    end
    test.run(@reporter)
    @reporter.report

    assert_includes @output.string.dup, "2 runs, 1 assertions, 0 failures, 0 errors, 1 skips"
  end

  def test_xdescribe
    test = xdescribe "Test" do
      it "normal" do assert true end
      xit "skipped" do assert false end
    end
    test.run(@reporter)
    @reporter.report

    assert_includes @output.string.dup, "2 runs, 0 assertions, 0 failures, 0 errors, 2 skips"
  end

  def test_nested_describes
    nested_1 = nested_2 = nil
    test = describe "Test" do
      it "normal" do assert true end
      xit "skipped" do assert false end
      nested_1 = xdescribe "All skipped" do
        it "nested skip" do assert false end
        nested_2 = describe "nested describe" do
          it "nested 2 levels skip" do assert false end
        end
      end
    end
    test.run(@reporter)
    nested_1.run(@reporter)
    nested_2.run(@reporter)
    @reporter.report

    assert_includes @output.string.dup, "4 runs, 1 assertions, 0 failures, 0 errors, 3 skips"
  end

  def test_skip_macro
    test = describe "Test" do
      skip def test_something
        assert false
      end

      def test_something_else
        assert false
      end
      skip :test_something_else
    end
    test.run(@reporter)
    @reporter.report

    assert_includes @output.string.dup, "2 runs, 0 assertions, 0 failures, 0 errors, 2 skips"
  end
end
