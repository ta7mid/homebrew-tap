class Plan9port < Formula
  desc "Port of many Plan 9 libraries and programs to Unix"
  homepage "https://9fans.github.io/plan9port/"
  url "https://github.com/9fans/plan9port/archive/refs/heads/master.tar.gz"
  version "df9b195e"
  sha256 "7c9eddf9506149e8683dbba7d13d08e2defa443ff402f1b591e813d3920cb2bb"
  license "MIT"
  head "https://github.com/9fans/plan9port.git", branch: "master"

  DEFAULT_INSTALL_PREFIX = "/usr/local/plan9".freeze
  MANPAGE_INDEX_FILENAMES = ["INDEX", "index.html"].freeze

  def install
    # remove unnecessary files
    rm_r ".github"
    rm [".gitignore", "CONTRIBUTING.md", "CONTRIBUTORS", "Makefile", "configure"]

    # update hardcoded install prefix
    # https://gitlab.archlinux.org/archlinux/packaging/packages/plan9port/-/blob/7045c67c217a4b27af666ac48fe9f4997b6c18cc/PKGBUILD#L47
    Dir["**/*"]
      .select { |path| File.file?(path) }
      .select { |file| File.foreach(file).any? { |line| line.include? DEFAULT_INSTALL_PREFIX } }
      .each { |file| inreplace file, DEFAULT_INSTALL_PREFIX, libexec.to_s }
    libexec.install Dir["*"]

    # build
    chdir libexec do
      system "./INSTALL", "-r", libexec.to_s
    end

    # install exec scripts
    bin.install_symlink libexec/"bin/9"
    libexec.glob("bin/**/*").select { |p| File.basename(p) != "9" && File.file?(p) }.each do |path|
      cmd = File.basename path
      cmd = "p9-#{cmd}" unless cmd.include? '"' # keep `"` and `""` as is
      (bin/cmd).atomic_write <<~SH
        #!/bin/sh

        PLAN9=#{libexec} export PLAN9

        case "$PATH" in
        $PLAN9/bin:*)
          ;;
        *)
          PATH="$PLAN9/bin:$PATH" export PATH
          ;;
        esac

        exec '#{path}' "$@"
      SH
    end

    # install man pages
    libexec.glob("man/man*/*").each do |path|
      dir = File.basename(File.dirname(path))
      f = File.basename path
      (man/dir).install_symlink path => MANPAGE_INDEX_FILENAMES.include?(f) ? f : "p9-#{f}"
    end

    # install macOS GUI `.app`s
    (prefix/"Applications").install Dir["#{libexec}/mac/*.app"] if OS.mac?

    # install other files
    prefix.install [
      "CHANGES",
      "LICENSE",
      "README.md",
    ].map { |f| libexec/f }

    # clean up leftover cruft
    rm_r libexec/"mac"
    rm [
      "INSTALL",
      "install.log",
      "install.sum",
      "install.txt",
    ].map { |f| libexec/f }
  end

  def caveats
    <<~EOS
      In order not to collide with system binaries, the Plan 9 binaries have not
      been installed to the Homebrew prefix directory as is, but instead have
      been installed into #{Formatter.url opt_libexec/"bin"}
      and symlinked into the Homebrew prefix bin with `p9-` prepended to
      their names.  Likewise, the Plan 9 man pages have also been symlinked into
      the Homebrew man prefix with `p9-`-prefixed names.

      Several of the installed tools expect other Plan 9 binaries to be
      available in PATH.  The `9` command can be used to adjust the PATH on the
      fly and use the original names of the binaries.  Hence, to run the Plan 9
      version of a command, simply prefix it with `9 `, like so:
        # 9 ls

      If instead you want the unprefixed versions always available in your PATH,
      add the following to your shell's startup file:

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
