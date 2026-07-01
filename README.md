# mirror-regclient

OCX mirror repo for the [regclient](https://github.com/regclient/regclient)
project. Currently publishes **regsync** (the registry mirroring tool) to
`ocx.sh/regclient/regsync` with cascade tags after a smoke test per
`(version, platform)`. regctl / regbot may be added later.

The regsync spec lives at the repo root (`mirror.yml`). The OCX mirror
generator is one-spec-per-repo — it writes `.github/workflows/` relative to
the spec, and GitHub only runs root workflows with fixed filenames. Adding a
second tool therefore needs a generator that emits per-tool workflow names;
until then regsync stays at root.

## Editing

| File | Edit | Regenerate after |
|------|------|------------------|
| `mirror.yml` | hand | `ocx-mirror pipeline generate ci` |
| `tests/smoke.star` | hand | — |
| `metadata*.json`, `CATALOG.md`, `logo.*` | hand | — |
| `.github/workflows/*.yml` | generated | re-run when `mirror.yml` changes |

CI fails on drift via `ocx-mirror pipeline generate ci --check`.

## Required secrets

| Secret | Use |
|--------|-----|
| `OCX_MIRROR_REGISTRY_TOKEN` + `OCX_MIRROR_REGISTRY_USER` | `ocx package push` to `ocx.sh` |
| `OCX_MIRROR_DISCORD_HOOK` | notify-stage Discord webhook URL |

(Inherited from the `ocx-contrib` org with visibility ALL.)

## License

Apache-2.0 — see [`LICENSE`](LICENSE). Upstream assets are out of
scope; see [`NOTICE.md`](NOTICE.md).
