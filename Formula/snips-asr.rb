class SnipsAsr < Formula
  desc "Snips ASR"
  homepage "https://snips.ai"

  url "ssh://git@github.com/snipsco/snips-platform.git",
    :using => :git, :tag => "0.60.10", :revision => "52306741000f9e4d060345c551bcfd72214eadef"

  head "ssh://git@github.com/snipsco/snips-platform.git",
    :using => :git, :branch => "develop"

  bottle do
    root_url "https://homebrew.snips.ai/bottles"
    cellar :any
    sha256 "8caed13355d0412785131674d51dd4715796ea936fd8a0adba22439e138712e3" => :el_capitan
  end

  option "with-debug", "Build with debug support"
  option "without-completion", "bash, zsh and fish completion will not be installed"

  depends_on "autoconf" => :build # needed by snips-fst-rs
  depends_on "automake" => :build # needed by snips-fst-rs
  depends_on "pkg-config" => :build # needed by snips-kaldi
  depends_on "rust" => :build
  depends_on "snips-platform-common"

  def install
    target_dir = build.with?("debug") ? buildpath/"target/debug" : buildpath/"target/release"

    args = %W[--root=#{prefix}]
    args << "--path=snips-asr/snips-asr"
    args << "--debug" if build.with? "debug"

    system "cargo", "install", *args

    bin.install "#{target_dir}/snips-asr"
    lib.install Dir.glob(File.join(target_dir, "build", "snips-kaldi-sys-*", "out", "libsnips_kaldi.dylib"))[0]

    if build.with? "completion"
      bash_completion.install "#{target_dir}/completion/snips-asr.bash"
      fish_completion.install "#{target_dir}/completion/snips-asr.fish"
      zsh_completion.install "#{target_dir}/completion/_snips-asr"
    end
  end

  plist_options :manual => "snips-asr -c #{HOMEBREW_PREFIX}/etc/snips.toml"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <dict>
          <key>SuccessfulExit</key>
          <false/>
        </dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/snips-asr</string>
          <string>-c</string>
          <string>#{etc}/snips.toml</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/snips/snips-asr.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/snips/snips-asr.log</string>
        <key>ProcessType</key>
        <string>Interactive</string>
      </dict>
    </plist>
  EOS
  end

  test do
    assert_equal "snips-asr #{version}\n", shell_output("#{bin}/snips-asr --version")
  end
end
