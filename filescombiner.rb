class Swiftfilescombiner < Formula
  desc "CLI utility to combine Swift files"
  homepage "https://github.com/bashta/SwiftFilesCombiner"
  url "https://github.com/Bashta/FilesCombiner/archive/refs/tags/v0.0.3.tar.gz"
  sha256 "bc837530346a14817aeed56de3d0ce9ebcc99305aec9e0427cd781c4a2c2d562"
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
