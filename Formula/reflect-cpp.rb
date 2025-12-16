class ReflectCpp < Formula
  desc "Fast serialization, deserialization and validation using C++20 reflection"
  homepage "https://rfl.getml.com"
  url "https://github.com/getml/reflect-cpp/archive/refs/tags/v0.22.0.tar.gz"
  sha256 "69013925d8a5b97cf1d7aedbdf29a7099376efdd9afc924d4225fcb72770bf8b"
  license "MIT"

  depends_on "cmake" => :build
  depends_on "apache-arrow"
  depends_on "avro-c"
  depends_on "capnp"
  depends_on "ctre"
  depends_on "flatbuffers"
  depends_on "mongo-c-driver"
  depends_on "msgpack"
  depends_on "pugixml"
  depends_on "tomlplusplus"
  depends_on "yaml-cpp"
  depends_on "yyjson"

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args,
                                              "-DCMAKE_CXX_STANDARD=20",
                                              "-DREFLECTCPP_USE_BUNDLED_DEPENDENCIES=OFF",
                                              "-DREFLECTCPP_USE_VCPKG=OFF",
                                              "-DREFLECTCPP_ALL_FORMATS=ON",
                                              "-DREFLECTCPP_CBOR=OFF",
                                              "-DREFLECTCPP_UBJSON=OFF"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cxx").write <<~CPP
      #include <rfl/json.hpp>
      #include <rfl.hpp>
      #include <cassert>
      #include <iostream>
      #include <string>

      int main()
      {
        struct Person {
          std::string name;
          int age;
        };

        const std::string json_string = rfl::json::write(Person{
          .name = "Homer",
          .age = 45
        });

        auto homer = rfl::json::read<Person>(json_string).value();
        assert(homer.age == 45);
        std::cout << homer.name;
      }
    CPP
    system ENV.cxx, "test.cxx", "-o", "test", "-std=c++20",
      "-I#{include}",
      "-L#{lib}", "-lreflectcpp"
    assert_equal "Homer", shell_output("./test")
  end
end
