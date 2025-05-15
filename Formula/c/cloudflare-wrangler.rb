class CloudflareWrangler < Formula
  desc "CLI tool for Cloudflare Workers"
  homepage "https://github.com/cloudflare/workers-sdk"
  url "https://registry.npmjs.org/wrangler/-/wrangler-4.15.1.tgz"
  sha256 "154b2bb8337d22328de34b5cd038a6bc40e0e82bbee27d325a6ee5d441251492"
  license any_of: ["Apache-2.0", "MIT"]

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "ae07d2a5b70525918678baa0c716a149be96eb8a426ccbb7acf917488b9cbdb6"
    sha256 cellar: :any,                 arm64_sonoma:  "ae07d2a5b70525918678baa0c716a149be96eb8a426ccbb7acf917488b9cbdb6"
    sha256 cellar: :any,                 arm64_ventura: "ae07d2a5b70525918678baa0c716a149be96eb8a426ccbb7acf917488b9cbdb6"
    sha256                               sonoma:        "99758d3b449fdfedb74fa63f9deba185c21b181a109cc803652bc291316760a2"
    sha256                               ventura:       "99758d3b449fdfedb74fa63f9deba185c21b181a109cc803652bc291316760a2"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "9c500aee559abfc6d4f46d98e2990284d67d11514df58ceb9848c434bda0f90c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "5d357445df918935c842c85f442ebac19acbacb717bca66710210726ebd2bcae"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/wrangler*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/wrangler -v")
    assert_match "Required Worker name missing", shell_output("#{bin}/wrangler secret list 2>&1", 1)
  end
end
