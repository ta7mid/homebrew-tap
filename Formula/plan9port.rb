class Plan9port < Formula
  desc "Port of many Plan 9 programs and libraries to Unix"
  homepage "https://9fans.github.io/plan9port/"
  url "https://github.com/9fans/plan9port/archive/ae4fdf4.tar.gz"
  version "2026.02.27-ae4fdf4"
  sha256 "2423069d2be70ba426096c9eaa57884b5b0ce75edac3f7a62d6c1c2e77e67cb2"
  license "MIT"
  head "https://github.com/9fans/plan9port.git", branch: "master"

  livecheck do
    url "https://api.github.com/repos/9fans/plan9port/branches/master"
    strategy :json do |json|
      commit = json["commit"]
      sha = commit["sha"]
      date = commit.dig("commit", "author", "date")
      "#{DateTime.parse(date).strftime("%Y.%m.%d")}-#{sha[0, 7]}"
    end
  end

  def install
    prefix.install_metafiles

    # Fix the hardcoded default install prefix in source files
    # https://gitlab.archlinux.org/archlinux/packaging/packages/plan9port/-/blob/7045c67c217a4b27af666ac48fe9f4997b6c18cc/PKGBUILD#L47
    buildpath.glob("**/*").select { |f| f.file? && !f.binary_executable? }.each do |f|
      inreplace f, "/usr/local/plan9", libexec.to_s, audit_result: false
    end

    # Build
    system "./INSTALL", "-r", libexec.to_s

    # Remove files and folders in buildpath that shouldn't be installed.
    # These are used for developing or building plan9port, not useful for end users.
    rm_r %w[
      .github
      dist
      lib/git
      mac
      news
      proto
      src
      unix
    ]
    rm %w[
      .gitignore
      CONTRIBUTING.md
      CONTRIBUTORS
      INSTALL
      Makefile
      configure
      install.log
      install.sum
      install.txt
    ]
    rm buildpath.glob("**/.gitkeep")

    # Install
    libexec.install buildpath.glob("*")
    bin.install_symlink libexec/"bin/9"
  end

  def caveats
    <<~EOS
      Run the following and add it to your shell profile, e.g. ~/.zprofile or ~/.profile:
        export PLAN9="#{opt_libexec}"

      In order to not collide with binaries, man pages, libraries, and include files
      installed by other packages, the plan9port distribution is installed under this
      PLAN9 directory instead of #{opt_prefix}, which means they
      have not been symlinked into the usual locations under #{HOMEBREW_PREFIX}

      As an exception, the `9` exec script has been symlinked into #{opt_bin},
      so it is available in PATH.  It sets PLAN9 and adds `$PLAN9/bin` to PATH, as many
      plan9port tools require, before `exec`ing the rest of the command line, and is
      thus the recommended way to run plan9port programs, e.g.:
        # 9 ls

      If you need to have plan9port binaries and man pages first in your PATH, set:
        export PLAN9="#{opt_libexec}"
        export PATH="$PATH:$PLAN9/bin"
        export MANPATH="$MANPATH:$PLAN9/man"

      For compilers to find plan9port libraries you may need to set:
        export PLAN9="#{opt_libexec}"
        export LDFLAGS="-L$PLAN9/lib"
        export CPPFLAGS="-I$PLAN9/include"
    EOS
  end

  test do
    system bin/"9", "man", "plumb"
    assert_match " Plan 9 ", shell_output("#{bin}/9 man ls")

    (testpath/"test.c").write <<~'C'
      #include <stdio.h>

      int main(void)
      {
        return 12 != printf("Hello World\n");
      }
    C
    system bin/"9", "9c", "test.c"
    system bin/"9", "9l", "-o", "test", "test.o"
    assert_equal "Hello World\n", shell_output("./test")
  end
end
