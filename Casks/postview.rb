cask "postview" do
  version "1.9.3"
  sha256 "8b1006b812fd9645ee5ba53c3798991cc6c73b88e525d6968c77749a60eb9678"

  url "https://web.archive.org/web/20180818013748if_/https://metaobject.com/downloads/Products/PostView/PostView-#{version}.dmg",
      verified: "web.archive.org/web/20180818013748if_/https://metaobject.com/downloads/Products/PostView/"
  name "PostView"
  desc "Viewer for PDF, PostScript and image files"
  homepage "https://www.metaobject.com/Products/"

  livecheck do
    url :homepage
    regex(/Current version: (\d+(?:\.\d+)+): <a href="[^"]*PostView-\d+(?:\.\d+)+.dmg/i)
    strategy :page_match
  end

  app "PostView.app"

  zap trash: [
        "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.metaobject.postview.*",
        "~/Library/Preferences/com.metaobject.PostView.plist",
      ],
      rmdir: "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments"

  caveats do
    requires_rosetta
  end
end
