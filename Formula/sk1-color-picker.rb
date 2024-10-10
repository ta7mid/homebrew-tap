class Sk1ColorPicker < Formula
  include Language::Python::Virtualenv

  desc "Color picker used in sK1"
  homepage "https://sk1project.net/color-picker"
  url "https://github.com/sk1project/color-picker/archive/refs/heads/master.tar.gz"
  version "1.1rc"
  sha256 "bf83412e3830ddc95b2981a8fee394cc46743ba46ea5396e6e395608652e538a"
  license "GPL-3.0"

  depends_on "pillow"
  depends_on "pygobject3"
  depends_on "python@3.11"

  def install
    virtualenv_install_with_resources
  end
end
