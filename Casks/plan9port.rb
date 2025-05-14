cask "plan9port" do
  version "df9b195e"
  sha256 "920232bc57c41b019e2254d67cbb332fe4dd5a5e90334a9174e8d0b51c4f0624"

  url "https://github.com/9fans/plan9port/archive/df9b195e.tar.gz"
  name "Plan 9 from User Space"
  desc "9term.app and Plumb.app from the Plan 9 from User Space distribution"
  homepage "https://9fans.github.io/plan9port/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :el_capitan"

  app "plan9port-df9b195ebfcd7d5fb673512ec7ec3b3df9981c61/mac/9term.app"
  app "plan9port-df9b195ebfcd7d5fb673512ec7ec3b3df9981c61/mac/Plumb.app"

  manpage "man/man1/9term.1"
  manpage "man/man1/Plumb.1"

  zap trash: ""
end
