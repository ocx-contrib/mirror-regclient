# Stable smoke test — assert on the contract (exit code, version shape, a
# token round-tripped through the embedded script engine), never on help or
# version prose.
#
# regbot automates registry actions from Lua scripts. `once --dry-run` runs
# every script in a config exactly once with all external actions skipped, so a
# script that only logs is fully hermetic — no registry contact at all.
REGBOT = "regbot.exe" if ocx.target_platform.os == ocx.os.Windows else "regbot"

# Tier 1 + 2: liveness + version SHAPE. `regbot version` prints a block whose
# first line is `VCSTag:     v0.11.5` — match the semver shape, not the vendor
# text or an exact version, so it stays green across every release.
r_version = ocx.run(REGBOT, "version")
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# Tier 3: functional behavior on hermetic input. The config below parses, the
# named script is scheduled, and its Lua body executes — proving the YAML
# loader and the embedded gopher-lua interpreter are both live in this build.
ocx.write_file("bot.yml", "version: 1\nscripts:\n  - name: ocx-smoke\n    script: |\n      log \"regbot-ocx-smoke-token\"\n")
r_once = ocx.run(REGBOT, "once", "--dry-run", "-c", "bot.yml")
expect.ok(r_once)

# Script output arrives on STDERR — regbot logs everything through its
# structured logger, including `log()` calls from user scripts. Both the script
# name (from the config) and the message (from the Lua body) must appear, so
# this fails if the config were parsed but the script never ran.
expect.contains(r_once.stderr, "ocx-smoke")
expect.contains(r_once.stderr, "regbot-ocx-smoke-token")
