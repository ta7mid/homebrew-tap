class Helics < Formula
  desc "Open-source cyber-physical-energy co-simulation framework for energy systems"
  homepage "https://docs.helics.org/en/latest/"
  url "https://github.com/GMLC-TDC/HELICS/releases/download/v3.5.2/Helics-v3.5.2-source.tar.gz"
  sha256 "c2604694698a1e33c4a68f3d1c5ab0a228ef2bfca1b0d3bae94801dbd3b11048"
  license "BSD-3-Clause"

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "zeromq"

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args,
      "-DCMAKE_CXX_STANDARD=17"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_equal "3.5.2 (2024-04-08)\n", shell_output("#{bin}/helics_player --version")
    assert_equal "3.5.2 (2024-04-08)\n", shell_output("#{bin}/helics_recorder --version")
  end
end
