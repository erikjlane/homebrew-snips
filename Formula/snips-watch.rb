class SnipsWatch < Formula
  desc "Snips Watch"
  homepage "https://snips.ai"

  url "ssh://git@github.com/snipsco/snips-platform.git",
    :using => :git, :tag => "0.64.0", :revision => "6df6a46d5ccfb312163c60a0ce2b3b90d8136b54"

  head "ssh://git@github.com/snipsco/snips-platform.git",
    :using => :git, :branch => "develop"

  bottle do
    root_url "https://homebrew.snips.ai/bottles"
    cellar :any
    sha256 "c5a37b1b8e865274339e487fc3d62af4534b5e7bf1eaef3343e505a85662300d" => :el_capitan
  end

  option "with-debug", "Build with debug support"
  option "without-completion", "bash, zsh and fish completion will not be installed"

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "portaudio"

  def install
    target_dir = build.with?("debug") ? "target/debug" : "target/release"

    args = %W[--root=#{prefix}]
    args << "--path=snips-watch/snips-watch"
    args << "--debug" if build.with? "debug"

    system "cargo", "install", *args

    bin.install "#{target_dir}/snips-watch"

    if build.with? "completion"
      bash_completion.install "#{target_dir}/completion/snips-watch.bash"
      fish_completion.install "#{target_dir}/completion/snips-watch.fish"
      zsh_completion.install "#{target_dir}/completion/_snips-watch"
    end
  end

  test do
    assert_equal "snips-watch #{version}\n", shell_output("#{bin}/snips-watch --version")
  end
end
