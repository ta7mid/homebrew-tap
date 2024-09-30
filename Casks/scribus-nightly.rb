cask "scribus-nightly" do
  version "1.7.0.svn-r26264"
  sha256 "5ac684028582804dc10af1a07eab5cfe5a2ff64149f7a6a40b837d3ae5428c17"

  url "https://downloads.sourceforge.net/scribus/scribus-svn/#{version[0..8]}/scribus-#{version[0..2]}.x-nightly_Monterey-20240819-#{version[-6..-1]}.dmg"
  name "Scribus (Nightly)"
  desc "Free and open-source page layout program"
  homepage "https://www.scribus.net/"

  livecheck do
    url "https://sourceforge.net/projects/scribus/rss?path=/scribus"
    regex(%r{url=.*?/scribus[._-]v?(\d+(?:\.\d+)+)(?:#{arch})?\.(?:dmg|pkg)}i)
  end

  app "Scribus17x.app"

  zap trash: [
    "~/Library/Application Support/Scribus",
    "~/Library/Preferences/Scribus",
    "~/Library/Saved Application State/net.scribus.savedState",
  ]
end
