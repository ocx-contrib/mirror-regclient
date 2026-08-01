# mirror-regclient

OCX mirrors for the [regclient](https://github.com/regclient/regclient) tool
family. One repository, one spec directory per package.

| Package | Spec | Publishes to | Announced as | Upstream SPDX |
|---|---|---|---|---|
| [regsync](https://github.com/regclient/regclient/blob/main/docs/regsync.md) — declarative registry mirroring | [`regsync/mirror.yml`](regsync/mirror.yml) | `ghcr.io/ocx-contrib/regclient/regsync` | `ocx.sh/regclient/regsync` | `Apache-2.0` |
| [regctl](https://github.com/regclient/regclient/blob/main/docs/regctl.md) — registry CLI | [`regctl/mirror.yml`](regctl/mirror.yml) | `ghcr.io/ocx-contrib/regclient/regctl` | `ocx.sh/regclient/regctl` | `Apache-2.0` |
| [regbot](https://github.com/regclient/regclient/blob/main/docs/regbot.md) — policy automation bot | [`regbot/mirror.yml`](regbot/mirror.yml) | `ghcr.io/ocx-contrib/regclient/regbot` | `ocx.sh/regclient/regbot` | `Apache-2.0` |

All three are cut from a **single upstream release** of `regclient/regclient` —
one tag ships `regsync-*`, `regctl-*` and `regbot-*` binaries side by side. Each
is mirrored as its own package so a consumer installs only the tool it wants.
Every release is discovered, re-bundled, smoke-tested per `(version, platform)`
and only then pushed with cascade tags, after which the result is announced into
the OCX index.

> This repository previously published regsync alone, from a root `mirror.yml`,
> to the flat coordinate `ocx.sh/regclient/regsync`. The grouped layout is the
> successor and adds regctl and regbot.

## Layout

```
mirror-base.yml         repo-wide policy every spec inherits via `extends:`
regsync/ regctl/ regbot/
├── mirror.yml          the spec — never at the repo root
├── metadata.json       bundle interface
├── CATALOG.md          → ocx package describe
├── logo.svg / logo.png describe assets, 512px PNG
└── tests/smoke.star    Starlark smoke test
```

`LICENSE` and `NOTICE.md` are shared at the root. Logos are **not** — each
package carries its own copy (here, the same upstream regclient mark, since all
three tools are one project), because a repo-root `logo.*` sits in no workflow's
`paths:` filter, so replacing it would publish nothing until some unrelated edit
happened to fire.

⚠️ `extends:` is a **shallow** merge of top-level keys. A spec that restates
`platforms:` to change one runner drops every `containers:` entry with it, and
nothing reds — the legs simply stop existing, and every `os.features` claim goes
back to being asserted rather than verified. Restate a block in full or not at
all.

## Platforms

Each package publishes five platform entries: both Linux arches, both macOS
arches, and `windows/amd64`.

**No `windows/arm64`** — upstream ships no arm64 Windows binary for any of the
three tools, at any version in range (checked at v0.9.0, v0.10.0, v0.11.0 and
v0.11.5). Declaring it would not have errored: a platform whose pattern matches
zero assets is *silently skipped*, so the mirror would have read green while
publishing nothing for it.

Also deliberately not carried: `linux/{ppc64le,riscv64,s390x}` (no GitHub
runner), `freebsd/amd64` (outside the OCX platform set), and the `metadata.tgz`
sidecar.

All three tools are pure-Go binaries built without cgo, so upstream ships one
Linux build per `(tool, arch)` and it is **fully static** — no `PT_INTERP`, no
`DT_NEEDED`. `os.features` states what an artifact requires *of the host*, so
both Linux keys are **bare**: tagging them `+libc.musl` would be a false
requirement that hid them from every glibc host. The `alpine:3.20` container leg
in `mirror-base.yml` is what turns that claim into evidence; the measurement
itself is recorded above each spec's `assets:` block.

## Editing

| File | Edit | Regenerate after |
|------|------|------------------|
| `mirror-base.yml`, `<pkg>/mirror.yml` | hand | yes — see below |
| `<pkg>/{metadata.json,CATALOG.md,logo.*}` | hand | — |
| `<pkg>/tests/smoke.star` | hand | — |
| `.github/workflows/*.yml` | **generated — never hand-edit** | re-run when a spec changes |

```bash
ocx-mirror package pipeline generate ci \
  --spec regsync/mirror.yml --spec regctl/mirror.yml --spec regbot/mirror.yml
```

**Name every spec, every time.** `--spec` *appends* rather than replaces, so a
command naming a subset silently stops rendering the rest while staying green —
and the drift guard then reds on a generated workflow the current spec set no
longer produces.

`verify-generated.yml` exits 65 on drift. If a generated workflow is wrong, the
spec or the renderer template is wrong — fix it there and regenerate.

Run `direnv allow` once to put the pinned toolchain on `PATH`, and invoke
`ocx-mirror` directly — never `ocx run -- ocx-mirror`, which pins
`OCX_BINARY_PIN` to the bootstrap `ocx` and false-reds the nested push.

## The binaries claim

Every spec sets `bin_scan: off` and hand-lists `binaries` in its
`metadata.json`. That is forced, not preferred: these are raw-binary mirrors
(`asset_type: binary`), so the executable **is** the bundle content root and the
PATH entry is a bare `${installPath}`. The scan only looks *below* an
`${installPath}/<subdir>` entry, so `auto` or `verify` is rejected at spec load
with exit 65. `off` with a hand-written list is the blessed shape for this asset
type — the list is one executable per package and changes only if upstream
renames a tool.

## Testing before you push

The smoke tests must pass locally against a real native bundle first — CI runs
them on macOS (10× minutes) and Windows (2×), and a Starlark dialect error reds
every version on every platform at once.

```bash
ocx-mirror package pipeline prepare --spec <pkg>/mirror.yml --version <V> --work-dir /tmp/nb
cp /tmp/nb/<V>_<date>/linux_amd64/{metadata.json,bundle-metadata.json}
ocx package test --platform linux/amd64 \
  --identifier ghcr.io/ocx-contrib/regclient/<pkg>:<V> \
  /tmp/nb/<V>_<date>/linux_amd64/bundle.tar.xz --script <pkg>/tests/smoke.star
```

Each smoke test asserts a **hermetic functional contract**, not help text:
regsync round-trips a sync config through its parser, regctl builds and reads
back a local `ocidir://` OCI layout, and regbot executes a Lua script under
`once --dry-run`. None of the three contacts a registry.

## Required secrets

| Secret | Use |
|--------|-----|
| `OCX_ANNOUNCE_TOKEN` | opens the index pull request from the `ocx-contrib/index` fork |
| `OCX_MIRROR_DISCORD_HOOK` | notify-stage Discord webhook URL |

(Inherited from the `ocx-contrib` org with visibility ALL. GHCR pushes use the
run's own `GITHUB_TOKEN` — no registry secret needed.)

## License

Apache-2.0 — see [`LICENSE`](LICENSE). Upstream assets are out of scope; each
package's redistribution license is recorded in [`NOTICE.md`](NOTICE.md).
