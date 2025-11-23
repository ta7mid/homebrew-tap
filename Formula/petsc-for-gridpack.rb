class PetscForGridpack < Formula
  desc "Portable, Extensible Toolkit for Scientific Computation (complex)"
  homepage "https://petsc.org/"
  url "https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc-3.24.1.tar.gz"
  sha256 "d77f3fd5187a72ce5b68a056aa8fcccd37b6dc7a388991d1d8fa0bde32b0abc8"
  license "BSD-2-Clause"

  livecheck do
    formula "petsc"
  end

  depends_on "cmake" => :build
  depends_on "hdf5-mpi"
  depends_on "open-mpi"
  depends_on "openblas"
  depends_on "suite-sparse"

  # required for xdrlib
  uses_from_macos "python@3.14" => :build

  keg_only "PETSc is provided by Homebrew Core"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--with-cmake",
                          "--download-metis",
                          "--download-parmetis",
                          "--download-superlu_dist",
                          "--with-suitesparse-dir=#{Formula["suite-sparse"].opt_prefix}",
                          "--with-debugging",
                          "--with-scalar-type=real",
                          "--with-x=0",
                          "--CC=mpicc",
                          "--CXX=mpicxx",
                          "--F77=mpif77",
                          "--FC=mpif90",
                          "MAKEFLAGS=$MAKEFLAGS"

    # Avoid references to Homebrew shims (perform replacement before running `make`, or else the shim
    # paths will still end up in compiled code)
    inreplace "arch-#{OS.kernel_name.downcase}-c-debug/include/petscconf.h", "#{Superenv.shims_path}/", ""

    system "make", "all"
    system "make", "install"

    # Avoid references to Homebrew shims
    rm(lib/"petsc/conf/configure-hash")

    if OS.mac? || File.foreach("#{lib}/petsc/conf/petscvariables").any? { |l| l[Superenv.shims_path.to_s] }
      inreplace lib/"petsc/conf/petscvariables", "#{Superenv.shims_path}/", ""
    end
  end

  test do
    flags = %W[-I#{include} -L#{lib} -lpetsc]
    flags << "-Wl,-rpath,#{lib}" if OS.linux?
    system "mpicc", share/"petsc/examples/src/ksp/ksp/tutorials/ex1.c", "-o", "test", *flags
    output = shell_output("./test")
    # This PETSc example prints several lines of output. The last line contains
    # an error norm, expected to be small.
    line = output.lines.last
    assert_match(/^Norm of error .+, Iterations/, line, "Unexpected output format")
    error = line.split[3].to_f
    assert (error >= 0.0 && error < 1.0e-13), "Error norm too large"
  end
end
