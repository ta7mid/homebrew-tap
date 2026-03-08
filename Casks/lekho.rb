cask "lekho" do
  version "0.1.0"
  sha256 "393b2aff5c4e3b1ca47f7a059630370345bdd88dbebc76ae7cee6082eb2581d0"

  url "https://github.com/ARahim3/Lekho/releases/download/v#{version}/Lekho-#{version}.dmg",
      verified: "github.com/"
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
            pkgutil: "com.lekho.inputmethod.Lekho",
            delete:  [
              "/Applications/Lekho.app",
              "~/Library/Input Methods/Lekho.app",
            ]

  zap trash: [
    "~/Library/Caches/com.lekho.inputmethod.Lekho",
    "~/Library/WebKit/com.lekho.inputmethod.Lekho",
  ]
end
