cask "9term" do
  version "2026.02.27-ae4fdf4"
  sha256 "8ae2830dadd2b94274301b59ab2319755def657530b4bbcd6080ad77fa22716e"

  url "https://codeload.github.com/9fans/plan9port/tar.gz/#{version.split("-").last}",
      verified: "https://codeload.github.com/9fans/plan9port/"
  name "9term"
  desc "Plan 9-style terminal emulator for Unix"
  homepage "https://9fans.github.io/plan9port/"

  livecheck do
    formula "plan9port"
  end

  depends_on formula: "plan9port"

  preflight do
    launcher = staged_path/"plan9port-#{version.split("-").last}/mac/9term.app/Contents/MacOS/9term"
    original = 'PLAN9=${PLAN9:-/usr/local/plan9}'
    replacement = 'PLAN9=${PLAN9:-' + Formula["plan9port"].opt_libexec.to_s + '}'
    content = launcher.read

    raise CaskError, "Unexpected 9term launcher format" unless content.include?(original)

    launcher.write(content.sub(original, replacement))
    launcher.chmod(0755)
  end

  app "plan9port-#{version.split("-").last}/mac/9term.app"

  zap trash: [
    "~/Library/Preferences/com.swtch.9term.plist",
    "~/Library/Saved Application State/com.swtch.9term.savedState",
  ]

  caveats <<~EOS
    9term.app is patched to use Homebrew's plan9port installation automatically.

    If you want to use plan9port tools directly from your shell, add:
      export PLAN9="$(brew --prefix plan9port)/libexec"
  EOS
end
