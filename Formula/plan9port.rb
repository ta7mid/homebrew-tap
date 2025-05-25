class Plan9port < Formula
  desc "Port of many Plan 9 libraries and programs to Unix"
  homepage "https://9fans.github.io/plan9port/"
  url "https://github.com/9fans/plan9port/archive/refs/heads/master.tar.gz"
  version "df9b195e"
  sha256 "7c9eddf9506149e8683dbba7d13d08e2defa443ff402f1b591e813d3920cb2bb"
  license "MIT"
  head "https://github.com/9fans/plan9port.git", branch: "master"

  DEFAULT_PREFIX = "/usr/local/plan9".freeze
  MANPAGE_INDEX_FILENAMES = ["INDEX", "index.html"].freeze

  def install
    # remove cruft
    rm ["CONTRIBUTING.md", "CONTRIBUTORS"]
    rm_r "mac/" if OS.linux?

    # prepare
    # https://gitlab.archlinux.org/archlinux/packaging/packages/plan9port/-/blob/7045c67c217a4b27af666ac48fe9f4997b6c18cc/PKGBUILD#L47
    Dir["**/*"]
      .select { |path| File.file?(path) }
      .select { |file| File.foreach(file).any? { |line| line.include? DEFAULT_PREFIX } }
      .each { |file| inreplace file, DEFAULT_PREFIX, libexec.to_s }
    libexec.install Dir["*"]

    # build
    chdir libexec do
      system "./INSTALL", "-r", libexec.to_s
    end

    # install
    (libexec/"bin/").children.each do |path|
      bin.install_symlink path => "plan9-#{File.basename path}"
    end
    mv bin/"plan9-9", bin/"9"
    (libexec/"man").glob("man*/*").each do |path|
      dir = File.basename(File.dirname(path))
      f = File.basename path
      (man/dir).install_symlink path => MANPAGE_INDEX_FILENAMES.include?(f) ? f : "plan9-#{f}"
    end
    prefix.install [
      "CHANGES",
      "LICENSE",
      "README.md",
    ].map { |f| libexec/f }

    # clean up
    rm [
      "INSTALL",
      "Makefile",
      "configure",
      "install.log",
      "install.sum",
      "install.txt",
    ].map { |f| libexec/f }
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
