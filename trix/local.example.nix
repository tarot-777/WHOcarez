# Copy this file to a host-specific module or import it from your Home Manager
# profile while testing. Do not put secrets in this file.
{
  config,
  lib,
  pkgs,
  ...
}: {
  whycare.trixOS = {
    enable = true;

    # Pick one: daily, research, redteam, forensics, llm, crypto, full
    # For a laptop, start with daily. Use dev shells for heavy/specialist stacks.
    profile = "daily";

    # Change to firefox, brave, qutebrowser, etc. if installed.
    browser = "brave";

    # Local model endpoints. These are only endpoint settings; they do not store keys.
    llmLocalUrl = "http://127.0.0.1:8080/v1";
    ollamaUrl = "http://127.0.0.1:11434";
  };

  # Example extra user packages that are usually safe on a laptop.
  home.packages = with pkgs; [
    keepassxc
    bitwarden-cli
    obsidian
  ];
}
