class Plan9port < Formula
  desc "Port of many Plan 9 programs and libraries to Unix"
  homepage "https://9fans.github.io/plan9port/"
  url "https://github.com/9fans/plan9port/archive/refs/heads/master.tar.gz"
  version "f39a2407"
  sha256 "814a1aa814d49b6e1a64a3ade3f5ada1496338c30e977ebe8c60cd2e84e3ef06"
  license "MIT"
  head "https://github.com/9fans/plan9port.git", branch: "master"

  def installdir
    libexec
  end

  def opt_installdir
    opt_libexec
  end

  def install
    # Remove unneeded files and directories
    rm_r ".github"
    rm [".gitignore", "CONTRIBUTING.md", "CONTRIBUTORS", "Makefile", "configure"]

    # Replace hardcoded install prefix with `installdir`
    # https://gitlab.archlinux.org/archlinux/packaging/packages/plan9port/-/blob/7045c67c217a4b27af666ac48fe9f4997b6c18cc/PKGBUILD#L47
    buildpath.glob("**/*").select { |f| f.file? && !f.binary_executable? }.each do |f|
      inreplace f, "/usr/local/plan9", installdir.to_s, audit_result: false
    end

    # Move everything to `installdir` and build install there
    installdir.install buildpath.glob("*")
    installdir.cd do |dir|
      system "./INSTALL", "-r", dir.to_s
    end

    # The official `9` exec script is symlinked as is
    bin.install_symlink installdir/"bin/9"

    # For other commands, install wrapper exec scripts with `p9-` prepended to their names
    commands = installdir.glob("bin/**/*")
                         .reject { |f| f.directory? || f.basename == "9" }
                         .select { |f| f.text_executable? || f.binary_executable? }
    commands.each do |cmd|
      script_name = cmd.basename.to_s
      script_name.prepend "p9-" unless script_name.include?('"') # keep `"` and `""` as is
      (bin/script_name).atomic_write <<~SH
        #!/bin/sh

        PLAN9=#{opt_installdir} export PLAN9

        case "$PATH" in
        $PLAN9/bin:*)
          ;;
        *)
          PATH="$PLAN9/bin:$PATH" export PATH
          ;;
        esac

        exec '#{cmd}' "$@"
      SH
    end

    # Symlink man pages as their `p9-`-prefixed names
    installdir.glob("man/man*/*").each do |f|
      link_name = f.basename.to_s
      link_name.prepend "p9-" unless ["INDEX", "index.html"].include? link_name
      (man/f.dirname.basename).install_symlink f => link_name
    end

    # Move other installed files to appropriate locations
    prefix.install installdir.glob("{CHANGES,LICENSE,README.md}")
    (prefix/"Applications").install installdir.glob("mac/*.app") if OS.mac?

    # Clean up leftovers and byproducts
    rm_r installdir/"mac"
    rm installdir/"INSTALL"
    rm installdir.glob("install.{log,sum,txt}")
  end

  def caveats
    <<~EOS
      In order not to collide with system binaries, the Plan 9 binaries have not
      been installed to the Homebrew prefix directory as is, but instead have
      been installed into #{Formatter.url (opt_installdir/"bin").to_s}
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

        export PLAN9=#{Formatter.url opt_installdir.to_s}
        export PATH="$PATH:$PLAN9/bin"
        export MANPATH="$MANPATH:$PLAN9/man"
    EOS
  end

  test do
    (testpath/"test.c").write <<~'C'
      #include <u.h>
      #include <libc.h>
      #include <stdio.h>

      int main(void)
      {
        return printf("Hello World\n");
      }
    C

    system bin/"9", "9c", "test.c"
    system bin/"9", "9l", "-o", "test", "test.o"
    assert_equal "Hello World\n", shell_output("./test", 1)

    # Also test that the `p9-`-prefixed commands work
    system bin/"p9-rm", "test.o", "test"
    system bin/"p9-9c", "test.c"
    system bin/"p9-9l", "-o", "test", "test.o"
    assert_equal "Hello World\n", shell_output("./test", 1)
  end
end
