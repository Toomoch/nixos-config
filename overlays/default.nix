# This file defines overlays
{ inputs, nixvim, mnw, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions =
    final: _prev:
    import ../pkgs {
      pkgs = final.pkgs;
      inherit nixvim mnw;
    };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    firefoxpwa = final.unstable.firefoxpwa;
    caddy = final.unstable.caddy;
    trayscale = final.unstable.trayscale;
    river = final.unstable.river-classic;
    openapi-generator-cli = final.unstable.openapi-generator-cli;
    silverbullet = final.unstable.silverbullet;
    cosmic-session = final.unstable.cosmic-session;
    cosmic-greeter = final.unstable.cosmic-greeter;
    numbat = prev.numbat.overrideAttrs (previousAttrs: {
      postInstall = ''
        # The source files are in a directory named 'assets' at the root
        # of the unpacked source code. The destination paths are relative
        # to $out, which points to the package's output directory in the Nix store.

        # Create the applications directory and install the .desktop file
        install -Dm644 assets/numbat.desktop $out/share/applications/numbat.desktop

        # Install the scalable SVG icon
        install -Dm644 assets/numbat.svg $out/share/icons/hicolor/scalable/apps/numbat.svg

        # Loop through the specified sizes and install the PNG icons
        for s in 16 22 24 32 48 64 128 256 512; do
          install -Dm644 "assets/numbat-''${s}x''${s}.png" "$out/share/icons/hicolor/''${s}x''${s}/apps/numbat.png"
        done
      '';
    });
    home-assistant-custom-components.tuya_local =
      prev.home-assistant-custom-components.tuya_local.overrideAttrs
        (previousAttrs: {
          postInstall = (previousAttrs.postInstall or "") + ''
            install -Dm444 ${./airmart.yaml} $out/custom_components/tuya_local/devices/airmart.yaml
          '';
        });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
