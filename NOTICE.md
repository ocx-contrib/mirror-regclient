# NOTICE

This repository packages and redistributes upstream software published by the
[regclient](https://github.com/regclient/regclient) project. The Apache-2.0
license in [`LICENSE`](LICENSE) covers the OCX pipeline files authored here. It
does **not** cover any upstream-derived asset — each package's redistributed
bytes carry their own license, recorded below.

Each package's logo is reproduced for catalog identification only, under
nominative fair use. The marks remain the property of their respective owners
and no endorsement is implied.

| Package | GHCR path | Upstream SPDX |
|---|---|---|
| `regsync` | `ghcr.io/ocx-contrib/regclient/regsync` | `Apache-2.0` |
| `regctl` | `ghcr.io/ocx-contrib/regclient/regctl` | `Apache-2.0` |
| `regbot` | `ghcr.io/ocx-contrib/regclient/regbot` | `Apache-2.0` |

All three tools are built from the **same upstream repository and the same
tag**, so they share one license, one copyright holder and one set of
third-party dependencies. The per-package sections below differ only in which
binary is redistributed.

---

## `regsync`

Upstream: <https://github.com/regclient/regclient>
Published to `ghcr.io/ocx-contrib/regclient/regsync`.

| Component | SPDX | Holder |
|---|---|---|
| regsync (`regsync-<os>-<arch>`) | **Apache-2.0** | The regclient authors |

## `regctl`

Upstream: <https://github.com/regclient/regclient>
Published to `ghcr.io/ocx-contrib/regclient/regctl`.

| Component | SPDX | Holder |
|---|---|---|
| regctl (`regctl-<os>-<arch>`) | **Apache-2.0** | The regclient authors |

## `regbot`

Upstream: <https://github.com/regclient/regclient>
Published to `ghcr.io/ocx-contrib/regclient/regbot`.

| Component | SPDX | Holder |
|---|---|---|
| regbot (`regbot-<os>-<arch>`) | **Apache-2.0** | The regclient authors |

---

## Terms

Apache-2.0 is permissive; redistribution of the compiled binaries is granted
provided the license text and attribution notices are retained. Upstream ships
raw binaries with no accompanying `LICENSE` file, so the license text is not
carried inside the mirrored artifact — this NOTICE and the
`org.opencontainers.image.licenses: "Apache-2.0"` annotation on every published
index carry the attribution instead, alongside the
`org.opencontainers.image.source` annotation pointing at the upstream
repository. The canonical text is at
<https://github.com/regclient/regclient/blob/main/LICENSE>.

The published binaries statically link third-party Go modules under permissive
licenses, enumerated in upstream's
[`go.mod`](https://github.com/regclient/regclient/blob/main/go.mod) — notably
`github.com/yuin/gopher-lua` (MIT), the Lua interpreter embedded in regbot.

## Names and marks

The `regclient`, `regsync`, `regctl` and `regbot` names are used for catalog
identification under nominative fair use. The logo shipped with each package is
the regclient project mark, sourced from the upstream brand asset at
`regclient.org/brand.svg`; all three packages carry the same file, because all
three tools are one project.

No modifications are made to any upstream artifact in this repository; they are
republished byte-for-byte inside an OCX bundle.
