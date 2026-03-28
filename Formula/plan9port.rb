class Plan9port < Formula
  desc "Port of many Plan 9 libraries and programs to Unix"
  homepage "https://9fans.github.io/plan9port/"
  license "MIT"
  head "https://github.com/9fans/plan9port.git", branch: "master"

  on_linux do
    depends_on "fontconfig"
    depends_on "libx11"
    depends_on "libxext"
    depends_on "libxt"
  end

  def install
    prefix.install_metafiles

    # Build with libexec as $PLAN9.
    system "./INSTALL", "-r", libexec

    # Install only runtime and user-relevant files into libexec.
    rm_r "lib/git"
    rm Dir["**/.gitkeep"]
    libexec.install Dir["*"] - %w[
      .github
      .gitignore
      CONTRIBUTING.md
      CONTRIBUTORS
      INSTALL
      Makefile
      configure
      dist
      install.log
      install.sum
      install.txt
      mac
      news
      proto
      src
      unix
    ]

    # Surface the `9`/`u` scripts and their man page "9(1)".
    bin.install_symlink %w[9 9.rc u u.rc].map { |f| libexec/"bin"/f }
    man1.install_symlink libexec/"man/man1/9.1"
  end

  def caveats
    <<~EOS
      To avoid collisions with system and Homebrew commands, plan9port's
      commands are installed under:
        #{opt_libexec}/bin

      To run a plan9port command, use the `9` wrapper installed in
      #{opt_bin}, for example:
        9 ls

      NOTE: some shell configurations, notably oh-my-zsh, define `9` as an
      alias for `cd -9`. If `9` is unavailable, unalias it in your shell
      initialization.

      If you want plan9port commands available in your PATH,
      either source the `9` script:
        . 9

      or, equivalently, set:
        export PLAN9="#{opt_libexec}"
        export PATH="$PLAN9/bin:$PATH"

      To restore the system command search order while keeping PLAN9 set, use:
        u <command>

      See 9(1) for details about `9`, `u`, `. 9`, and `. u` (as well as their rc
      counterparts):
        man 1 9   # or `9 man 1 -- 9` to use plan9port's `man`

      To read plan9port man pages other than 9(1) with the system `man` command,
      set:
        export MANPATH="$MANPATH:$PLAN9/man"

      For compilers to find plan9port libraries you may need to set:
        export LDFLAGS="-L$PLAN9/lib"
        export CPPFLAGS="-I$PLAN9/include"
    EOS
  end

  test do
    nine = bin/"9"

    # Verify installed scripts reference the correct $PLAN9 path.
    assert_match libexec.to_s, nine.read
    bin.glob("**/*").each do |f|
      refute_match "/usr/local/plan9", f.read
    end

    # Check surfaced scripts and man pages.
    refute_match "plan9port", shell_output("man ls")
    assert_match "plan9port", shell_output(". #{nine} && man ls")
    system "man", "1", "9"
    refute_match(/[Nn]o manual/, shell_output("#{nine} man u u.rc 9 9.rc"))
    system nine, "rc", "-c", "venti/verifyarena </dev/null"

    # Compile and run a minimal lib9 program.
    (testpath/"test.c").write <<~'C'
      #include <u.h>
      #include <libc.h>

      void
      main(void)
      {
        print("Hello from lib9\n");
        exits(nil);
      }
    C
    system nine, "9c", "test.c"
    system nine, "9l", "-o", "test", "test.o"
    assert_equal "Hello from lib9\n", shell_output("./test")
  end
end
