{
  description = "Déploiement libvirt/Ansible d'une VM BlackArch (CTF)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      deps = [ pkgs.python3Packages.ansible-core pkgs.xorriso pkgs.openssh pkgs.virt-viewer ];

      # NB: on utilise $PWD, pas ${self} (copie figée/read-only du store Nix,
      # qui en plus ignore .ssh/ via .gitignore) : ce script est volontairement
      # impur (clé SSH, cache d'image, VM locale) donc il doit tourner depuis
      # le vrai checkout, lancé avec `nix run .` depuis la racine du repo.
      app = name: {
        type = "app";
        program = toString (pkgs.writeShellApplication {
          name = "blackarch-ctf-${name}";
          runtimeInputs = deps;
          text = ''
            if [ ! -x ./scripts/blackarch-ctf ]; then
              echo "Lance ceci depuis la racine du repo blackarch-ctf-conf (cd d'abord)." >&2
              exit 1
            fi
            exec ./scripts/blackarch-ctf ${name} "$@"
          '';
        }) + "/bin/blackarch-ctf-${name}";
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = deps;
        shellHook = ''
          export LIBVIRT_DEFAULT_URI=qemu:///system
          echo "blackarch-ctf: ansible-core + xorriso prêts. Lance ./scripts/blackarch-ctf up"
        '';
      };

      apps.${system} = {
        default = app "up";
        up = app "up";
        provision = app "provision";
        down = app "down";
        destroy = app "destroy";
        vpn = app "vpn";
      };
    };
}
