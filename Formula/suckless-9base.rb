class Suckless9base < Formula
  desc "Plan 9 userland tools"
  homepage "https://tools.suckless.org/9base/"
  url "https://dl.suckless.org/tools/9base-6.tar.gz"
  sha256 "2997480eb5b4cf3092c0896483cd2de625158bf51c501aea2dc5cf74176d6de9"
  license all_of: ["X11", "LPL-1.02"]

  keg_only <<~EOS
    the 9base tools conflict with many standard Unix userland tools and tools
    provided by other Homebrew packages
  EOS

  depends_on "make" => :build

  # Additional dependency
  # resource "" do
  #   url ""
  #   sha256 ""
  # end

  def install
    # https://gitlab.archlinux.org/archlinux/packaging/packages/9base/-/blob/7aaad73e5261545b02934dc80e44f4dd784243d5/PKGBUILD#L29
    inreplace "config.mk" do |s|
      s.change_make_var! "PREFIX", prefix
      s.change_make_var! "MANPREFIX", man
      s.change_make_var! "OBJTYPE", Hardware::CPU.arm? ? "arm" : "x86_64"
      s.change_make_var! "CFLAGS", '-fcommon -Wno-implicit-function-declaration -I. -DPLAN9PORT -DPREFIX="\"${PREFIX}\""'
      s.gsub! "-static", ""
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
