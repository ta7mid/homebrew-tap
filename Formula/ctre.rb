class Ctre < Formula
  desc "Compile-time PCRE-compatible regular expression matcher for C++"
  homepage "https://github.com/hanickadot/compile-time-regular-expressions"
  url "https://github.com/hanickadot/compile-time-regular-expressions/archive/refs/tags/v3.10.0.tar.gz"
  sha256 "23585680a282658abe3557cf112d79edddb5fdfd8947f450b279fe63940a1fa7"
  license "Apache-2.0"

  depends_on "cmake" => :build

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cxx").write <<~CPP
      #include <ctre-unicode.hpp>
      #include <cassert>
      #include <iostream>

      int main()
      {
        auto m = ctre::match<"[a-z]+([0-9]+)">("abc123");
        assert(m);
        std::cout << m.get<1>();
      }
    CPP
    system ENV.cxx, "test.cxx", "-o", "test", "-std=c++20", "-I#{include}"
    assert_equal "123", shell_output("./test")
  end
end
