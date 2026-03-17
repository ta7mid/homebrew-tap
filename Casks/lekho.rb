cask "lekho" do
  version "0.2.1"
  sha256 "66cf647f56f39ab3042676d45550f85098cf896c78531e668b6e8d4cd48b4d6b"

  url "https://github.com/ARahim3/Lekho/releases/download/v#{version}/Lekho-#{version}.dmg",
      verified: "github.com/ARahim3/Lekho/"
  name "Lekho"
  desc "Bengali input method based on the Avro Phonetic layout"
  homepage "https://arahim3.github.io/Lekho/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :ventura"

  pkg "Install Lekho.pkg"

  uninstall quit:    "com.lekho.inputmethod.Lekho",
            delete:  [
              "/Applications/Lekho.app",
              "~/Library/Input Methods/Lekho.app",
            ]

  zap trash: [
    "~/Library/Caches/com.lekho.inputmethod.Lekho",
    "~/Library/WebKit/com.lekho.inputmethod.Lekho",
  ]

  caveats do
    logout
  end
end
