# Release Tag Playbook

Use this every time you cut a new version tag (for example, `v1.0.7`).

## Goal

- Commit release notes into `main` first
- Create an annotated tag using those same notes
- Push the tag so GitHub Actions creates the release + APK

## Preconditions

- Your feature/fix commits are already pushed to `main`
- You are on `main`
- Working tree is clean (or only expected changes)

## 1) Prepare release notes file

Create or edit:

- `.github/release-notes/vX.Y.Z.md`

Example path:

- `.github/release-notes/v1.0.7.md`

## 1.5) Update app version in pubspec.yaml (required before tag push)

Edit:

- `pubspec.yaml`

Set `version:` to the same semantic version as the tag.

Examples:

- Tag `v1.0.7` -> `version: 1.0.7+107` (or your preferred build number)
- Tag `v2.3.0` -> `version: 2.3.0+230`

Important:

- Do this before creating/pushing the tag.
- Commit this version change together with release notes.

## 2) Commit and push release notes

```bash
git checkout main
git pull --ff-only origin main
git add pubspec.yaml
git add .github/release-notes/vX.Y.Z.md
git commit -m "chore: bump app version and add release notes for vX.Y.Z"
git push origin main
```

## 3) Create annotated tag from notes file

```bash
git tag -a vX.Y.Z -F .github/release-notes/vX.Y.Z.md
```

Verify annotation locally:

```bash
git tag -n99 vX.Y.Z
```

## 4) Push tag

```bash
git push origin vX.Y.Z
```

## 5) Verify release output

Check latest release body (must not be null):

```bash
curl -s https://api.github.com/repos/h200137j/pace/releases/latest | jq -r '.tag_name, .body'
```

Optional checks:

```bash
# Check tag exists remotely
git ls-remote --tags origin vX.Y.Z

# Check release workflow runs
# (Open GitHub Actions UI for this repository)
```

## If tag already exists

### Local tag exists but not pushed

```bash
git tag -d vX.Y.Z
git tag -a vX.Y.Z -F .github/release-notes/vX.Y.Z.md
git push origin vX.Y.Z
```

### Remote tag already exists and must be replaced

Only do this if you intentionally want to retag.

```bash
git tag -d vX.Y.Z
git push origin :refs/tags/vX.Y.Z
git tag -a vX.Y.Z -F .github/release-notes/vX.Y.Z.md
git push origin vX.Y.Z
```

## If release body is still null

- Open the release in GitHub and click Edit
- Paste notes into release description and save

CLI alternative:

```bash
gh release edit vX.Y.Z --notes-file .github/release-notes/vX.Y.Z.md
```

## Quick copy template (replace version)

```bash
VERSION=v1.0.7
git checkout main
git pull --ff-only origin main
## update pubspec.yaml -> version: 1.0.7+107
git add pubspec.yaml
git add .github/release-notes/$VERSION.md
git commit -m "chore: bump app version and add release notes for $VERSION"
git push origin main
git tag -a $VERSION -F .github/release-notes/$VERSION.md
git tag -n99 $VERSION
git push origin $VERSION
curl -s https://api.github.com/repos/h200137j/pace/releases/latest | jq -r '.tag_name, .body'
```
