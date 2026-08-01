# Stable smoke test — assert on the contract (exit code, version shape,
# echoed config tokens), never on help/version prose. regsync is a registry
# mirroring tool; its offline-testable surface is `version` and `config`.
REGSYNC = "regsync.exe" if ocx.target_platform.os == ocx.os.Windows else "regsync"

# Tier 1 + 2: liveness + version SHAPE. `regsync version` prints a block that
# includes `VCSTag:     v0.11.5` — match the semver shape, not the vendor text
# or an exact version, so it stays green across every release.
r_version = ocx.run(REGSYNC, "version")
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# Tier 3: functional behavior on hermetic input. `regsync config -c <file>`
# parses the sync config fully offline (no registry contact) and echoes it
# back normalized. Assert our own input tokens survive the parse+emit round
# trip — a contract on the parser, not prose.
ocx.write_file("sync.yml", "version: 1\nsync:\n  - source: registry.example.org/repo:latest\n    target: localhost:5000/repo:latest\n    type: image\n")
r_config = ocx.run(REGSYNC, "config", "-c", "sync.yml")
expect.ok(r_config)
expect.contains(r_config.stdout, "registry.example.org/repo")
expect.contains(r_config.stdout, "localhost:5000/repo")
