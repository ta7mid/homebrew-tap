cask "focus-editor" do
  version "0.3.7"
  sha256 "539ea4f427bd59107036c2e263e7cb67864741993d46f2a0bd8feb10a03b4dda"

  url "https://github.com/focus-editor/focus/releases/download/#{version}/focus-macOS.dmg"
  name "Focus"
  desc "Simple and fast text editor"
  homepage "https://focus-editor.dev"

  livecheck do
    url :url
    strategy :github_latest
  end

  app "Focus.app"
  binary "Focus.app/Contents/MacOS/Focus"

  zap trash: "~/Library/Application Support/dev.focus-editor"
end
