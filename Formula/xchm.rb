class Xchm < Formula
  desc "GUI front-end to chmlib"
  homepage "https://github.com/rzvncj/xCHM"
  url "https://github.com/rzvncj/xCHM/archive/refs/tags/1.38.tar.gz"
  sha256 "f6db981faa426b29d432e0fcfc83fc5b6192972cd02fe9412b0348f425e9b60d"
  license "GPL-2.0-or-later"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "chmlib"
  depends_on "gettext" => :no_linkage
  depends_on "libiconv" => :no_linkage
  depends_on "wxwidgets@3.2"

  def install
    args = %W[
      --disable-silent-rules
      --enable-optimize
      --with-libiconv-prefix=#{Formula["libiconv"].prefix}
      --with-libintl-prefix=#{Formula["gettext"].prefix}
      --with-wx-prefix=#{Formula["wxwidgets@3.2"].prefix}
      --with-wx-config=#{Formula["wxwidgets@3.2"].bin/"wx-config-3.2"}
    ]

    system "autoreconf", "--force", "--install", "--verbose"
    system "./configure", *args, *std_configure_args
    system "make", "install"
  end

  test do
    system bin/"xchm", "--help"
  end
end
