{pkgs}: let
  lib = pkgs.lib;
  pick = names:
    builtins.filter (pkg: pkg != null)
    (map (name: lib.attrByPath (lib.splitString "." name) null pkgs) names);
in
  pkgs.mkShell {
    name = "trix-llm";
    packages = pick [
      "llama-cpp"
      "ollama"
      "open-webui"
      "python3"
      "uv"
      "nodejs"
      "deno"
      "jq"
      "curl"
      "ripgrep"
      "fd"
      "mods"
      "aichat"
    ];
    shellHook = ''
      export TRIX_PROFILE=llm
      export TRIX_LLM_LOCAL_URL="''${TRIX_LLM_LOCAL_URL:-http://127.0.0.1:8080/v1/models}"
      export TRIX_OLLAMA_URL="''${TRIX_OLLAMA_URL:-http://127.0.0.1:11434/api/tags}"
      mkdir -p "$HOME/.local/share/trix/models" "$HOME/.local/state/trix/llm"
      echo "TRIX LLM shell: llama.cpp/Ollama/Open WebUI when available. Run: trix llm"
    '';
  }
