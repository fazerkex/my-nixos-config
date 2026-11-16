# Maintenance and development

Backups are intentionally not configured, as requested. No Restic package,
backup service, credential file or backup schedule was added.

## Rebuild and update

Run from this repository, or use the existing Fish aliases:

```sh
rebuild -b          # flake checks and system build; no activation
rebuild            # same validation/build, then sudo activation
update -b          # explicitly update inputs, validate and build only
update             # update, validate/build, then sudo activation
```

`rebuild` preserves flake.lock by default and never stages or commits files.
The legacy `-U` and `-n` flags are accepted. Commit-message arguments are no
longer accepted; use `git diff`, `git add <reviewed files>`, and `git commit`.
Updates can change the lockfile even if a subsequent build fails; review it.
Approve activation separately when asking an agent to run these commands.

## Cleanup and rollback

```sh
clean --dry-run 30  # show the plan and list generations, without deleting
clean 30           # explicitly expire old generations, collect and optimise
```

The final collector no longer uses `-d`, so it cannot erase every retained
old generation after the age cutoff. Retention must be positive. Integrated
Home Manager follows the NixOS generations, with no separate HM cleanup call.
The dry run lists all generations, not an exact predicted deletion set.
The existing weekly 14-day Nix GC policy remains in effect; no second nh
cleanup timer is enabled. Any cleanup removes rollback options for expired
generations. No cleanup was executed while implementing this change.

## Development environment

```sh
nix develop        # enter this repository's development shell
nix fmt            # format a file passed as an argument, e.g. nix fmt flake.nix
nix flake check    # all-Nix formatting, ShellCheck, maintenance regression tests
```

To format all Nix files: `rg --files -g '*.nix' -0 | xargs -0 nixfmt`.
`statix check .` and `deadnix .` are advisory lint commands; legacy unused
arguments are not yet enforced as CI failures. The initial all-file formatting
includes whitespace-only changes to hardware and host modules; hardware,
boot, filesystem and desktop settings were not changed.

`.envrc` runs `use flake`. After rebuilding, start a new Fish shell and run
`direnv allow` in this repository after reviewing it. nix-direnv caches the
shell. Enable each other project's .envrc only after reviewing that project.
Per-project development shells are preferable to global language runtimes.

Home Manager now owns direnv and Brave (the duplicate system entries are gone).
VS Code uses Nix IDE + nixd for language features, with nixfmt on save.
Installed tools: nixd, nixfmt, statix, deadnix, shellcheck, jq and fd.
`nh` is configured for /home/mka/NixOS: try `nh os build` for a build with
readable output and generation differences. `nh os switch` activates and still
requires explicit approval when run by an agent.

GitHub Actions runs the flake checks on pushes and pull requests. Action
implementations are pinned to commits. CI does not activate the system or
build the entire desktop; use `rebuild -b` locally for the full build.

## Rootless Docker

On the next approved system activation the rootful daemon is disabled,
rootless Docker is enabled, and mka is removed from the docker group.
Before this change the rootful daemon had no containers or named volumes.
Its old data is retained; nothing under /var/lib/docker is deleted or migrated.
Images may need pulling again for the separate rootless daemon.

Log out of the desktop and back in after activation so group membership and
DOCKER_HOST refresh. In a new terminal:

```sh
systemctl --user status docker
printenv DOCKER_HOST
docker info
docker ps
```

DOCKER_HOST should point to unix:///run/user/1000/docker.sock; Docker info
should list rootless in its security options. Use `docker` and `lazydocker`
as your user, without sudo. No lingering is enabled. Rootless containers are
not equivalent to rootful containers: privileged host access and some network
features differ. Rootless mode reduces host privileges; it is not a substitute
for reviewing commands executed by an agent.

Changes are built and checked before pushing. System activation and runtime
verification of the new Docker/shell/editor setup require a subsequent approved
rebuild and fresh login.
