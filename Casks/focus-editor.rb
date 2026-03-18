cask "focus-editor" do
  version "0.3.8"
  sha256 "56883831e607892c050325e17b8b354fda69a538111bc2b84f7ad3b8bccb3db0"

  url "https://github.com/focus-editor/focus/releases/download/#{version}/focus-macOS.dmg",
      verified: "github.com/focus-editor/"
  name "Focus"
  desc "Simple and fast text editor"
  homepage "https://focus-editor.dev/"

  livecheck do
    url :url
    strategy :github_latest
  end

  app "Focus.app"
  binary "Focus.app/Contents/MacOS/Focus"

  zap trash: "~/Library/Application Support/dev.focus-editor"

  caveats do
    requires_rosetta
  end
end
