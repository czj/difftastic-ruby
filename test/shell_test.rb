# frozen_string_literal: true

require_relative "test_helper"
require "tmpdir"

class ShellTest < Minitest::Spec
	it "diff_files with spaces, quotes and command substitution in paths" do
		Dir.mktmpdir do |dir|
			Dir.chdir(dir) do
				File.write("a $(touch injected).txt", "A")
				File.write("b 'quoted\".txt", "B")

				output = Difftastic::Differ.new(color: :never, tab_width: 2).diff_files("a $(touch injected).txt", "b 'quoted\".txt")

				assert_equal "1 A                         1 B", output
				refute File.exist?("injected")
			end
		end
	end

	it "diff_strings with a temporary directory containing a space" do
		Dir.mktmpdir do |parent|
			dir = File.join(parent, "with space")
			Dir.mkdir(dir, 0o700)
			original_tmpdir = ENV["TMPDIR"]
			ENV["TMPDIR"] = dir

			output = Difftastic::Differ.new(color: :never, tab_width: 2).diff_strings("A", "B")

			assert_equal "1 A                         1 B", output
		ensure
			ENV["TMPDIR"] = original_tmpdir
		end
	end

	it "diff_strings with every option set" do
		differ = Difftastic::Differ.new(color: :never, context: 3, background: :dark, syntax_highlight: :off, tab_width: 2, width: 80)

		assert_equal "1 A                         1 B", differ.diff_strings("A", "B")
	end
end
