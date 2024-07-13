class Swiftfilescombiner < Formula
  desc "CLI utility to combine Swift files"
  homepage "https://github.com/bashta/SwiftFilesCombiner"
  url "https://github.com/Bashta/FilesCombiner/archive/refs/tags/v0.0.1.tar.gz"
  sha256 "dcd8f5ccbf2e1b74608a5d0b2b86e1a766c7904757a636fc14e3a1574c137d8f"
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
