cask "9term" do
  version "2025.11.09-f39a240"
  sha256 "2bf42e0a4bba5334f1155a1153982a7e59a5fcdbac6f9684cc6255c856da9238"

  url "https://codeload.github.com/9fans/plan9port/tar.gz/#{version.split("-").last}"
  name "9term"
  desc "Terminal emulator providing an interface similar to that used on Plan 9"
  homepage "https://9fans.github.io/plan9port/"

  livecheck do
    formula "plan9port"
  end

  depends_on formula: "plan9port"

  app "plan9port-#{version.split("-").last}/mac/9term.app"

  zap trash: ""

  caveats <<~EOS
    To use 9term, you will need to set the the PLAN9 environment
    variable to the path of the `libexec` subdirectory under the
    plan9port installation prefix, e.g. (for Bash shell):
      export PLAN9="$(brew --prefix plan9port)/libexec"
  EOS
end
