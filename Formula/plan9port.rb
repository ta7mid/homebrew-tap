class Plan9port < Formula
  desc "Port of many Plan 9 libraries and programs to Unix"
  homepage "https://9fans.github.io/plan9port/"
  url "https://github.com/9fans/plan9port/archive/df9b195e.tar.gz"
  version "df9b195e"
  sha256 "920232bc57c41b019e2254d67cbb332fe4dd5a5e90334a9174e8d0b51c4f0624"
  head "https://github.com/9fans/plan9port.git"
  license "MIT"

  def install
    # remove cruft
    rm_rf ".hg/"
    rm_f Dir["**/.cvsignore"]
    rm_f [".hgignore", ".hgtags", "CONTRIBUTING.md", "CONTRIBUTORS"]
    on_linux do
      rm_rf "mac/"
    end

    # prepare
    # https://gitlab.archlinux.org/archlinux/packaging/packages/plan9port/-/blob/7045c67c217a4b27af666ac48fe9f4997b6c18cc/PKGBUILD#L47
    Dir["**/*"]
      .select { |path|
        File.file?(path) and File.foreach(path).any?{ |line| line.include? "/usr/local/plan9" }
      }.each { |file| inreplace file, "/usr/local/plan9", libexec.to_s }
    libexec.install Dir["*"]

    # build
    chdir libexec do
      system "./INSTALL", "-r", libexec.to_s
    end

    # install
    (libexec/"bin").children.each do |cmd|
      bin.install_symlink cmd => "plan9-#{File.basename cmd}"
    end
    File.rename bin/"plan9-9", bin/"9"
    (libexec/"man").glob("man*/*").each do |page|
      dir = File.basename(File.dirname page)
      linked_name = File.basename page
      unless linked_name == "INDEX" or linked_name == "index.html"
        linked_name = "plan9-#{linked_name}"
      end
      (man/dir).install_symlink page => linked_name
    end
    prefix.install libexec/"CHANGES", libexec/"LICENSE", libexec/"README.md"

    # clean up
    rm_f [
      libexec/"INSTALL",
      libexec/"Makefile",
      libexec/"config",
      libexec/"configure",
      libexec/"install.log",
      libexec/"install.sum",
      libexec/"install.txt",
    ]
  end

  def caveats
    <<~EOS
      In order not to collide with system binaries, the Plan 9 binaries
      have not been installed to the Homebrew prefix directory as is.
      Instead, they have been installed into #{Formatter.url opt_libexec/"bin"}
      and symlinked into the Homebrew prefix bin with `plan9-` prepended to
      their names.  Likewise, the Plan 9 man pages have also been symlinked
      into the Homebrew prefix with `plan9-`-prefixed names.

      Several of the installed tools expect other Plan 9 binaries to be
      available in PATH.  The `9` command can be used to adjust the PATH on
      the fly and use the original names of the binaries.  Hence, to run the
      Plan 9 version of a command, simply prefix it with `9 `, like so:
        # 9 ls

      If you want the unprefixed versions always available in your PATH, add
      the following to your shell's startup file:

        export PLAN9=#{Formatter.url opt_libexec}
        export PATH="$PATH:$PLAN9/bin"
        export MANPATH="$MANPATH:$PLAN9/man"
    EOS
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <u.h>
      #include <libc.h>
      #include <stdio.h>

      int main(void)
      {
        return printf("Hello World\\n");
      }
    EOS
    system bin/"9", "9c", "test.c"
    system bin/"9", "9l", "-o", "test", "test.o"
    assert_equal "Hello World\n", shell_output("./test", 1)
  end
end
