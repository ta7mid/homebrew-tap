cask "plan9port" do
  version :latest
  sha256 :no_check

  url "https://github.com/9fans/plan9port/archive/refs/heads/master.tar.gz",
      verified: "github.com/9fans/plan9port/"
  name "plan9port macOS apps"
  desc "App bundles for 9term(1) and plumb(1) from plan9port"
  homepage "https://9fans.github.io/plan9port/"

  depends_on formula: "plan9port"

  app "9term.app"
  app "Plumb.app"

  preflight do
    src = staged_path/"plan9port-master"

    (src/"mac").glob("*.app").each do |app|
      launcher = app/"Contents/MacOS"/app.basename(".app").to_s.downcase
      contents = launcher.read

      contents.sub! "/usr/local/plan9", Formula["plan9port"].opt_libexec
      launcher.write contents
      launcher.chmod 0755

      FileUtils.mv app, staged_path
    end

    FileUtils.rm_r src
  end
end
