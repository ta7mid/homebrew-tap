cask "plumb" do
  version "2026.02.27-ae4fdf4"
  sha256 "8ae2830dadd2b94274301b59ab2319755def657530b4bbcd6080ad77fa22716e"

  url "https://codeload.github.com/9fans/plan9port/tar.gz/#{version.split("-").last}",
      verified: "https://codeload.github.com/9fans/plan9port/"
  name "Plumb"
  desc "GUI client for sending messages to Plan 9 plumbers"
  homepage "https://9fans.github.io/plan9port/"

  livecheck do
    formula "plan9port"
  end

  depends_on formula: "plan9port"

  preflight do
    launcher = staged_path/"plan9port-#{version.split("-").last}/mac/Plumb.app/Contents/MacOS/plumb"
    original = 'PLAN9=${PLAN9:-/usr/local/plan9}'
    replacement = 'PLAN9=${PLAN9:-' + Formula["plan9port"].opt_libexec.to_s + '}'
    content = launcher.read

    raise CaskError, "Unexpected Plumb launcher format" unless content.include?(original)

    launcher.write(content.sub(original, replacement))
    launcher.chmod(0755)
  end

  app "plan9port-#{version.split("-").last}/mac/Plumb.app"
end
