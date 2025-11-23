class Gridpack < Formula
  desc "HPC package for simulation of large-scale electrical grids"
  homepage "https://github.com/GridOPTICS/GridPACK"
  url "https://github.com/GridOPTICS/GridPACK/releases/download/v3.5/GridPACK-3.5.tar.gz"
  sha256 "73b109506ff311eea55805af915f3186337a9001053ae97333f9760842d75a22"
  license "BSD-2-Clause"

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "boost-mpi"
  depends_on "open-mpi"
  depends_on "globalarrays-for-gridpack"
  depends_on "petsc-for-gridpack"

  def install
    # Boost.System is a header-only library now
    inreplace "src/CMakeLists.txt", "mpi serialization random system", "mpi serialization random"

    system "cmake", "-S", "src", "-B", "build", *std_cmake_args,
        "-DCMAKE_BUILD_TYPE:STRING=Debug",
        "-DBUILD_SHARED_LIBS:BOOL=NO",
        "-DBoost_ROOT:PATH=#{Formula["boost"].opt_prefix}",
        "-Dboost_mpi_dir:PATH=#{Formula["boost-mpi"].opt_prefix}",
        "-DGA_DIR:PATH=#{Formula["globalarrays-for-gridpack"].opt_prefix}",
        "-DPETSC_DIR:PATH=#{Formula["petsc-for-gridpack"].opt_prefix}",
        "-DGRIDPACK_ENABLE_TESTS:BOOL=NO"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end
end
