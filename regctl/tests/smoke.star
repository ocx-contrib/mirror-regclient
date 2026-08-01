# Stable smoke test — assert on the contract (exit code, version shape, the
# OCI layout regctl itself writes), never on help/version prose.
#
# regctl is a registry client, so most of its surface needs a registry. The
# `ocidir://` reference scheme is the exception and the better test anyway: it
# is regctl's own registry-free storage backend, so a create → read → list
# round trip exercises manifest construction, digest computation and tag
# resolution entirely on local disk, with no network at all.
REGCTL = "regctl.exe" if ocx.target_platform.os == ocx.os.Windows else "regctl"

# Tier 1 + 2: liveness + version SHAPE. `regctl version` prints a block whose
# first line is `VCSTag:     v0.11.5` — match the semver shape, not the vendor
# text or an exact version, so it stays green across every release.
r_version = ocx.run(REGCTL, "version")
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# Tier 3: functional behavior, hermetic. Build an empty OCI image index in a
# local `ocidir://` layout under the scratch root (ocx.run's default cwd), then
# read it back three different ways. Each step is a real contract:
#
#   index create   — writes oci-layout, index.json and the manifest blob
#   manifest head  — recomputes the digest from those bytes on disk
#   manifest get   — resolves the tag and reports the media type it stored
#   tag ls         — enumerates the tags in the layout
#
# A truncated or non-functional binary fails at the first step; a binary that
# wrote a malformed layout fails at the read-back.
r_create = ocx.run(REGCTL, "index", "create", "ocidir://oci:v1")
expect.ok(r_create)

# Digest SHAPE, not the literal value — asserting the exact sha256 of an empty
# index would pin this test to today's serialization of it.
r_head = ocx.run(REGCTL, "manifest", "head", "ocidir://oci:v1")
expect.ok(r_head)
expect.matches(r_head.stdout, r"sha256:[0-9a-f]{64}")

# The media type is the contract: `index create` must produce an OCI image
# INDEX, not an image manifest.
r_get = ocx.run(REGCTL, "manifest", "get", "ocidir://oci:v1")
expect.ok(r_get)
expect.contains(r_get.stdout, "application/vnd.oci.image.index.v1+json")

# Our own tag token survives the write/read round trip.
r_tags = ocx.run(REGCTL, "tag", "ls", "ocidir://oci")
expect.ok(r_tags)
expect.contains(r_tags.stdout, "v1")
