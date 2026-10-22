# Vaultwarden OCI image

Nix-built Vaultwarden image for x86_64 Linux using the pinned Nixpkgs package and `dockerTools`; no upstream container image is used.

## Build

```sh
nix flake check
nix build .#image
podman load -i result
```

The flake lock pins Nixpkgs; the selected Vaultwarden package is 1.37.4.

## Runtime contract

- Numeric non-root identity: `10001:10001`.
- Entrypoint is Nixpkgs' `vaultwarden` binary; the separately packaged Nixpkgs web vault is included and selected with `WEB_VAULT_FOLDER`.
- Listens on all container interfaces at TCP 8080; health endpoint: `/alive`. Do not attach it to an untrusted/public network without a reverse proxy and appropriate application configuration.
- Writable persistent path: `/data` (SQLite database and attachments).
- `/tmp` is created with mode 1777; mount it as tmpfs for read-only-root operation.
- TLS certificate bundle is provided; configure secrets and reverse-proxy settings at runtime. No credentials are baked into the image.
- No shell or package manager is included.

Use only disposable data for local smoke tests. Never point the image at existing production Vaultwarden storage during packaging validation.
