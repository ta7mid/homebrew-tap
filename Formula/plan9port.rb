class Plan9port < Formula
  desc "Port of many Plan 9 libraries and programs to Unix"
  homepage "https://9fans.github.io/plan9port/"
  url "https://github.com/9fans/plan9port/archive/df9b195e.tar.gz"
  version "df9b195e"
  sha256 "920232bc57c41b019e2254d67cbb332fe4dd5a5e90334a9174e8d0b51c4f0624"
  head "https://github.com/9fans/plan9port.git"
  license "MIT"

  def install
    # clean up
    rm_rf ".hg/"
    rm_f Dir["**/.cvsignore"]
    rm_f [".hgignore", ".hgtags", "CONTRIBUTING.md", "CONTRIBUTORS"]
    on_linux do
      rm_rf "mac/"
    end

    # prepare
    root = prefix/"plan9"
    # https://gitlab.archlinux.org/archlinux/packaging/packages/plan9port/-/blob/7045c67c217a4b27af666ac48fe9f4997b6c18cc/PKGBUILD#L47
    Dir["**/*"]
      .select { |path| File.file?(path) and File.foreach(path).any?{ |line| line["/usr/local/plan9"] } }
      .each { |file| inreplace file, "/usr/local/plan9", root.to_s }
    root.install Dir["*"]

    chdir root do
      # build
      system "./INSTALL", "-r", root.to_s

      # install
      bin.install_symlink root/"bin/9"
      cp "bin/9", bin/"plan9"

      # clean up
      rm_f ["INSTALL", "Makefile", "config", "configure", "install.log", "install.sum", "install.txt"]
      prefix.install "CHANGES", "LICENSE", "README.md"
    end
  end

  def caveats
    <<~EOS
      In order not to collide with system binaries, the Plan 9 binaries have
      been installed to #{opt_prefix}/plan9/bin.

      To run the Plan 9 version of a command, simply call it through either
      `9` or `plan9`, which have been installed into the Homebrew prefix bin.
      For example, to run Plan 9's `ls`, enter
          # 9 ls
      or
          # plan9 ls
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
