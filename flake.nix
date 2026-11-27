{
  description = "Vaultwarden OCI image built with Nix dockerTools";
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://rogernavelsaker.cachix.org"
      "https://nacosolutions.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "rogernavelsaker.cachix.org-1:n1DtzMNhA9Rz4Kg3xlXOi/KceULu8VrMbs9WXyMFQNQ="
      "nacosolutions.cachix.org-1:JzCiW2CLcuLXtwOVAg3SlSK/kpqWbfSFEVenyKVUlug="
    ];
  };

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      image = pkgs.dockerTools.buildLayeredImage {
        name = "vaultwarden";
        tag = pkgs.vaultwarden.version;
        contents = [ pkgs.vaultwarden pkgs.vaultwarden.webvault pkgs.dockerTools.fakeNss pkgs.cacert ];

        config = {
          User = "10001:10001";
          WorkingDir = "/data";
          Entrypoint = [ "${pkgs.vaultwarden}/bin/vaultwarden" ];
          Env = [
            "DATA_FOLDER=/data"
            "ROCKET_ADDRESS=0.0.0.0"
            "WEB_VAULT_FOLDER=${pkgs.vaultwarden.webvault}/share/vaultwarden/vault"
            "ROCKET_PORT=8080"
            "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
          ];
          ExposedPorts = { "8080/tcp" = { }; };
          Volumes = { "/data" = { }; };
        };

        fakeRootCommands = ''
          mkdir -p ./data ./tmp
          chown 10001:10001 ./data ./tmp
          chmod 0700 ./data
          chmod 1777 ./tmp
        '';
      };
    in {
      packages.${system} = {
        inherit image;
        default = image;
      };
      checks.${system} = { inherit image; };
    };
}
