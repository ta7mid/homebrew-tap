cask "mathmagic-lite" do
  version "10.15"
  sha256 "8034861b27c13bfeffdfb58bf9e573203965a37711490f25096b108350623e89"

  url "http://www.mathmagic.com/download/installers/MathMagicLite.64-bit.zip"
  name "MathMagic Lite"
  desc "Multi-purpose editor and converter for equations and scientific symbols"
  homepage "http://www.mathmagic.com"

  livecheck do
    url "http://www.mathmagic.com/download/download.html"
    regex /<a href="http:\/\/www.mathmagic.com\/download\/installers\/MathMagicLite.64-bit.zip">MathMagic Lite v([1-9]+[0-9]*[._-][0-9]+) for Mac<\/a>/i
  end

  depends_on macos: ">= :mojave"

  suite "MathMagic Lite 64-bit"

  zap trash: ""
end
