class Plan9port < Formula
  desc "A port of many Plan 9 libraries and programs to Unix"
  homepage "https://9fans.github.io/plan9port/"
  url "https://github.com/9fans/plan9port/archive/df9b195e.zip"
  version "df9b195e"
  sha256 "938f28c7b07f6d9c5fe982020cb5d006ba8a8d2b8e9a7706dfdafbc7b6b303f2"
  head "https://github.com/9fans/plan9port.git"

  def install
    system "./INSTALL", "-r", libexec
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/9"
    prefix.install Dir[libexec/"mac/*.app"]
  end

  def caveats
    <<~EOS
      In order not to collide with macOS system binaries, the Plan 9 binaries
      have been installed to #{opt_libexec}/bin.

      To run the Plan 9 version of a command simply call it through the command
      "9", which has been installed into the Homebrew prefix bin.  For example,
      to run Plan 9's ls run:
          # 9 ls
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
