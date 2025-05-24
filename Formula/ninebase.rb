class Ninebase < Formula
  desc "Plan 9 userland tools"
  homepage "https://tools.suckless.org/9base/"
  url "https://dl.suckless.org/tools/9base-6.tar.gz"
  sha256 "2997480eb5b4cf3092c0896483cd2de625158bf51c501aea2dc5cf74176d6de9"
  license all_of: ["X11", "LPL-1.02"]

  keg_only <<~EOS
    The 9base tools conflict with many standard Unix userland tools provided by
    other Homebrew packages.
  EOS

  depends_on "make" => :build

  # Additional dependency
  # resource "" do
  #   url ""
  #   sha256 ""
  # end

  def install
    puts prefix
    inreplace "config.mk" do |text|
      text.gsub! "/usr/local/plan9", prefix
      text.gsub! /^OBJTYPE.*$/, "OBJTYPE = arm"
      text.gsub! "-static", "-shared"
    end

    system "make"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test 9base`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system bin/"program", "do", "something"`.
    system "false"
  end
end
