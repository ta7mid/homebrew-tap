class GlobalarraysForGridpack < Formula
  desc "Partitioned Global Address Space (PGAS) library for distributed arrays"
  homepage "http://hpc.pnl.gov/globalarrays/"
  url "https://github.com/GlobalArrays/ga/releases/download/v5.9.2/ga-5.9.2.tar.gz"
  sha256 "cbf15764bf9c04e47e7a798271c418f76b23f1857b23feb24b6cb3891a57fbf2"
  license "BSD-3-Clause"

  depends_on "open-mpi"

  def install
    system "./configure", *std_configure_args,
      "--enable-debug",
      "--disable-silent-rules",
      "--with-mpi-ts",
      "--enable-cxx",
      "--enable-shared"
    system "make"
    system "make", "install"
  end
end
