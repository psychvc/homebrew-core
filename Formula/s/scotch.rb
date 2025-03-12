class Scotch < Formula
  desc "Package for graph partitioning, graph clustering, and sparse matrix ordering"
  homepage "https://gitlab.inria.fr/scotch/scotch"
  url "https://gitlab.inria.fr/scotch/scotch/-/archive/v7.0.7/scotch-v7.0.7.tar.bz2"
  sha256 "d88a9005dd05a9b3b86e6d1d7925740a789c975e5a92718ca0070e16b6567893"
  license "CECILL-C"
  head "https://gitlab.inria.fr/scotch/scotch.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "92d2f145da7c1d8ba98af44802e2559a1135ae8dbe93b66accb721882b5c25a7"
    sha256 cellar: :any,                 arm64_sonoma:  "bd954b30d0f7bf9342d0ca1064d7911a6e89821b21f821f8eb66e9d84b0868e0"
    sha256 cellar: :any,                 arm64_ventura: "a160800ce17a50773a9e1e45564cd6545a5c71718535e66dcad648dc8046333b"
    sha256 cellar: :any,                 sonoma:        "f2ba17bc5147d76d1fefd5ec59f8b43d2460cdb79b4e9dddad4918d7f2e458f1"
    sha256 cellar: :any,                 ventura:       "9f667ef06d2ead0f46601721aaa656c535669975268acb234ab080004de1918e"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "5e1e2cfd818f3b90daa1747abb648b43c6bbbf6727b87be4f88e7456b89331cb"
  end

  depends_on "bison" => :build
  depends_on "cmake" => :build
  depends_on "open-mpi"
  depends_on "xz"

  uses_from_macos "flex" => :build
  uses_from_macos "bzip2"
  uses_from_macos "zlib"

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DBUILD_SHARED_LIBS=ON",
                    "-DCMAKE_INSTALL_RPATH=#{rpath}",
                    "-DENABLE_TESTS=OFF",
                    "-DINSTALL_METIS_HEADERS=OFF",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    pkgshare.install "src/check/test_strat_seq.c"
    pkgshare.install "src/check/test_strat_par.c"

    # License file has a non-standard filename
    prefix.install buildpath.glob("LICEN[CS]E_*.txt")
    doc.install (buildpath/"doc").children
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdlib.h>
      #include <stdio.h>
      #include <scotch.h>
      int main(void) {
        int major, minor, patch;
        SCOTCH_version(&major, &minor, &patch);
        printf("%d.%d.%d", major, minor, patch);
        return 0;
      }
    C
    system ENV.cc, "test.c", "-L#{lib}", "-lscotch", "-lscotcherr",
                             "-pthread", "-L#{Formula["zlib"].opt_lib}", "-lz", "-lm"
    assert_match version.to_s, shell_output("./a.out")

    system ENV.cc, pkgshare/"test_strat_seq.c", "-o", "test_strat_seq",
                   "-I#{include}", "-L#{lib}", "-lscotch", "-lscotcherr", "-lm", "-pthread",
                   "-L#{Formula["zlib"].opt_lib}", "-lz"
    assert_match "Sequential mapping strategy, SCOTCH_STRATDEFAULT", shell_output("./test_strat_seq")

    system "mpicc", pkgshare/"test_strat_par.c", "-o", "test_strat_par",
                    "-I#{include}", "-L#{lib}", "-lptscotch", "-lscotch", "-lptscotcherr", "-lm", "-pthread",
                    "-L#{Formula["zlib"].opt_lib}", "-lz", "-Wl,-rpath,#{lib}"
    assert_match "Parallel mapping strategy, SCOTCH_STRATDEFAULT", shell_output("./test_strat_par")
  end
end
