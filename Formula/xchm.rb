class Xchm < Formula
  desc "CHM file viewer"
  homepage "http://xchm.sourceforge.net"
  url "https://github.com/rzvncj/xCHM/releases/download/1.36/xchm-1.36.tar.gz"
  sha256 "291411f51fe702f7f60a2904757183cfb7b7a0852e008bd71dcbfbe573ea9f43"
  license "GPL-2.0"

  depends_on "chmlib"
  depends_on "wxwidgets"

  def install
    system "./configure", "--disable-dependency-tracking", "--disable-silent-rules", *std_configure_args
    system "make"
    system "make", "install"
  end
end
