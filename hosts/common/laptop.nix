{
  hostName ? "laptop",
  inputs,
  lib,
  pkgs,
  userName ? "malachi",
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc-laptop
  ];

  networking.hostName = lib.mkDefault hostName;
  system.stateVersion = "25.05";

  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  fileSystems."/" = lib.mkOptionDefault {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=4G" "mode=755"];
  };

  hardware.enableRedistributableFirmware = lib.mkDefault true;
  hardware.bluetooth.enable = lib.mkDefault true;
  hardware.bluetooth.powerOnBoot = lib.mkDefault true;

  networking.networkmanager.enable = lib.mkDefault true;
  services.fwupd.enable = lib.mkDefault true;
  services.power-profiles-daemon.enable = lib.mkDefault true;
  services.thermald.enable = lib.mkDefault true;
  services.printing.enable = lib.mkDefault true;

  time.timeZone = lib.mkDefault "America/Denver";

  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = [
      "audio"
      "input"
      "kvm"
      "libvirtd"
      "networkmanager"
      "video"
      "wheel"
    ];
  };

  programs.zsh.enable = lib.mkDefault true;
  virtualisation.libvirtd.enable = lib.mkDefault true;
  programs.virt-manager.enable = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    fastfetch
    fwupd
    git
    home-manager
    kitty
    nh
    pciutils
    powertop
    tmux
    usbutils

    # Ensure Niri and DankMaterialShell/DMS packages are available system-wide
    # when deploying the framework to a laptop. These refer to the flakes exposed
    # in the top-level flake inputs (niri-flake and dank-material-shell).
    # If the package is missing for the current system, the pkgs reference will
    # gracefully fail at evaluation; keep these as convenient defaults.
    (inputs.niri-flake.packages.${pkgs.stdenv.hostPlatform.system}.niri // null)
    (inputs.dank-material-shell.packages.${pkgs.stdenv.hostPlatform.system}.dms-shell // null)
  ];
}
