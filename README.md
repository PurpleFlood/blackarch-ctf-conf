# blackarch-ctf-conf

VM BlackArch Linux pour CTF, sur libvirt/KVM, déployée par Ansible. Marche sur
les deux machines (ou n'importe quelle machine NixOS avec `virtualisation.libvirtd`
+ `programs.virt-manager`) sans rien installer de permanent sur l'hôte.

## Démarrer

```
nix run .      # = nix run .#up : crée/démarre/provisionne la VM, ouvre l'affichage
```

Premier lancement : télécharge l'image cloud Arch, crée la VM, ajoute le dépôt
BlackArch (strap.sh), installe blackman + les outils CTF, le bureau Openbox
(conf officielle BlackArch), qemu-guest-agent/spice-vdagent, et WireGuard.
Compte 10-20 min selon la connexion. Les lancements suivants re-vérifient tout
(idempotent) mais sont nettement plus rapides ; pour un redémarrage instantané
sans repasser par Ansible : `./scripts/blackarch-ctf up --fast`.

## Autres commandes

```
nix run .#provision   # ré-applique Ansible sans ouvrir l'affichage
nix run .#down        # arrêt propre (ACPI)
nix run .#destroy     # supprime la VM + son disque (garde l'image de base en cache)
nix run .#vpn fr       # connecte le WireGuard de la VM (via le script vpn) au pays donné
nix run .#vpn status
nix run .#vpn off
```

## Raccourcis clavier hôte vs VM

Rien à configurer : spice-gtk (utilisé par virt-viewer) capture automatiquement
le clavier dès que la souris est sur la fenêtre de la VM — à ce moment-là, même
les raccourcis `super + ...` de bspwm/sxhkd partent dans la VM. Dès que la
souris sort de la fenêtre, sxhkd reprend la main sur l'hôte. Aucun conflit
possible, aucune config à faire.

## WireGuard / VPN

Le script `/usr/local/bin/vpn` dans la VM est une copie du script Mullvad de
l'hôte. Par défaut (`sync_wireguard_from_host: true` dans `group_vars/all.yml`),
Ansible copie `/etc/wireguard` de l'hôte vers la VM au provisioning (demande ton
mot de passe sudo *local* pour lire le dossier). Mets la variable à `false` si
tu préfères déposer tes propres configs Mullvad dans la VM à la main.

## Config

Tout est dans `group_vars/all.yml` (RAM, vCPU, taille disque, user de bureau,
accélération 3D SPICE...) et `roles/blackarch_base/vars/packages.yml` (liste
des outils CTF — pacman + AUR pour ce qui manque côté BlackArch, ex: burpsuite,
pwndbg).

La clé SSH dédiée au projet est générée automatiquement dans `.ssh/` (jamais ta
clé perso), ignorée par git.
