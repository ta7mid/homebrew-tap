class Plan9port < Formula
  desc "Port of many Plan 9 libraries and programs to Unix"
  homepage "https://9fans.github.io/plan9port/"
  url "https://github.com/9fans/plan9port/archive/refs/heads/master.tar.gz"
  version "df9b195e"
  sha256 "7c9eddf9506149e8683dbba7d13d08e2defa443ff402f1b591e813d3920cb2bb"
  license "MIT"
  head "https://github.com/9fans/plan9port.git", branch: "master"

  def install
    # remove cruft
    rm ["CONTRIBUTING.md", "CONTRIBUTORS"]
    rm_r "mac/" if OS.linux?

    # prepare
    # https://gitlab.archlinux.org/archlinux/packaging/packages/plan9port/-/blob/7045c67c217a4b27af666ac48fe9f4997b6c18cc/PKGBUILD#L47
    Dir["**/*"]
      .select { |path| File.file?(path) }
      .select { |file| File.foreach(file).any? { |line| line.include? "/usr/local/plan9" } }
      .each { |file| inreplace file, "/usr/local/plan9", libexec.to_s }
    libexec.install Dir["*"]

    chdir libexec do
      # build
      system "./INSTALL", "-r", libexec.to_s

      # install
      Dir["bin/*"].each do |cmd|
        bin.install_symlink cmd => "plan9-#{File.basename cmd}"
      end
      mv bin/"plan9-9", bin/"9"
      Dir["man/man*/*"].each do |page|
        basename = File.basename page
        index_basenames = ["INDEX", "index.html"]
        dir = File.basename(File.dirname(page))
        (man/dir).install_symlink page => "plan9-#{basename}" unless index_basenames.include?(basename)
      end
      prefix.install ["CHANGES", "LICENSE", "README.md"]

      # clean up
      rm %w[
        INSTALL
        Makefile
        config
        configure
        install.log
        install.sum
        install.txt
      ]
    end
  end

  def caveats
    <<~EOS
      In order not to collide with system binaries, the Plan 9 binaries have not
      been installed to the Homebrew prefix directory as is.  Instead, they have
      been installed into #{Formatter.url opt_libexec/"bin"}
      and symlinked into the Homebrew prefix bin with `plan9-` prepended to
      their names.  Likewise, the Plan 9 man pages have also been symlinked into
      the Homebrew prefix with `plan9-`-prefixed names.

      Several of the installed tools expect other Plan 9 binaries to be
      available in PATH.  The `9` command can be used to adjust the PATH on the
      fly and use the original names of the binaries.  Hence, to run the Plan 9
      version of a command, simply prefix it with `9 `, like so:
        # 9 ls

      If you want the unprefixed versions always available in your PATH, add
      the following to your shell's startup file:

        export PLAN9=#{Formatter.url opt_libexec}
        export PATH="$PATH:$PLAN9/bin"
        export MANPATH="$MANPATH:$PLAN9/man"
    EOS
  end

  test do
    (testpath/"test.c").write <<~C
      #include <u.h>
      #include <libc.h>
      #include <stdio.h>

      int main(void)
      {
        return printf("Hello World\\n");
      }
    C
    system bin/"9", "9c", "test.c"
    system bin/"9", "9l", "-o", "test", "test.o"
    assert_equal "Hello World\n", shell_output("./test", 1)
  end
end
