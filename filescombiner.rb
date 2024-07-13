class Swiftfilescombiner < Formula
  desc "CLI utility to combine Swift files"
  homepage "https://github.com/bashta/SwiftFilesCombiner"
  url "https://github.com/Bashta/FilesCombiner/archive/refs/tags/v0.0.2.tar.gz"
  sha256 "24599eb25f5dffb27d18d2f0e0074dda328272c6c3a4ca560f84559dac593deb"
  license "MIT"

  depends_on xcode: ["15.0", :build]

  def install
    system "swift", "build", "--disable-sandbox", "-c", "release"
    bin.install ".build/release/SwiftFilesCombiner"
  end

  test do
    system "#{bin}/SwiftFilesCombiner", "--version"
  end
end
