class ArmciMpi < Formula
  desc "Implementation of ARMCI using MPI-3 one-sided communication"
  homepage "https://github.com/pmodels/armci-mpi"
  url "https://github.com/pmodels/armci-mpi/archive/refs/tags/v0.4.tar.gz"
  sha256 "bcc3bb189b23bf653dcc69bc469eb86eae5ebc5ad94ab5f83e52ddbdbbebf1b1"
  license "BSD-3-Clause-Open-MPI"

  keg_only "it conflicts with global-arrays"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "m4" => :build
  depends_on "open-mpi"

  def install
    system "autoreconf", "--force", "--install", "--verbose"
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~'C'
      #include <armci.h>
      #include <mpi.h>
      #include <stdio.h>

      int main(int argc, char* argv[])
      {
        MPI_Init(&argc, &argv);
        ARMCI_Init();
        int rank;
        MPI_Comm_rank(MPI_COMM_WORLD, &rank);
        printf("Hello from rank %d\n", rank);
        ARMCI_Finalize();
        MPI_Finalize();
        return 0;
      }
    C
    args = %W[
      -I#{include}
      -L#{lib}
      -larmci
      -I#{Formula["open-mpi"].include}
      -L#{Formula["open-mpi"].lib}
      -lmpi
    ]
    system ENV.cc, "test.c", "-o", "test", *args
    system "mpirun", "-n", "2", "./test"
  end
end
