# Release Process

DropSweep releases are triggered by a Git tag. The tag starts a single GitHub Actions workflow that builds, signs, notarizes, and publishes the macOS app, updates the Sparkle appcast, and deploys the website through Vercel.

The GitHub Release contains the downloadable `DropSweep.app` ZIP and automatically generated release notes. A release is offered through DropSweep's in-app update check only after the workflow has also published the generated `appcast.xml` to `main`.

## Supported Tags

A release tag must use this format:

- Stable: `vX.Y.Z`, for example `v0.4.0`

`X`, `Y`, and `Z` must be numeric. The release workflow rejects other tags such as `v0.4`, `0.4.0`, or `v0.4.0-beta1`. Minor and patch versions must each be below `1000` because the workflow encodes the version as a numeric Sparkle build number.

## Preparing a Release

Before creating a tag, make sure that:

1. All intended changes have been merged into `main` through pull requests.
2. Every pull request has at least one useful label, such as `enhancement`, `bug`, `documentation`, `maintenance`, or `website`.
3. The current state of `main` builds successfully and has been verified according to the changes. For scanning or cleanup changes, this includes the relevant manual tests from `AGENTS.md`.
4. The release version is newer than the version currently published in `appcast.xml`.
5. The GitHub secrets for Developer ID signing and notarization are configured: `APPLE_ID`, `APPLE_APP_SPECIFIC_PASSWORD`, `DEVELOPER_ID_CERTIFICATE_BASE64`, and `DEVELOPER_ID_CERTIFICATE_PASSWORD`. The certificate and notarization credentials must belong to the Apple developer team used for the release.
6. The `APPLE_TEAM_ID` repository variable and the `SPARKLE_PRIVATE_KEY` secret are configured. The Sparkle private key must match the public key stored as `SUPublicEDKey` in `DropSweep/Info.plist`.
7. The GitHub secrets `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`, and `VERCEL_TOKEN` are configured for the production website deployment.
8. Squash merging is enabled for the repository so the workflow can merge its appcast pull request.

The `website` label is especially important: pull requests with this label are excluded from the generated app release notes. Changes labeled `ignore-for-release` and pull requests authored by `github-actions[bot]` are excluded as well.

## Triggering a Release

First, update the local `main` branch and confirm that its current commit is exactly the commit that should be released. Then create the desired tag and push it to GitHub:

```sh
git switch main
git pull --ff-only
git tag v0.4.0
git push origin v0.4.0
```

Pushing the tag is the actual release trigger, so verify the version carefully before pushing it. Published versions must increase monotonically; the workflow refuses to replace the Sparkle feed with an older or equal build number.

## GitHub Actions Workflow

The `.github/workflows/release.yml` workflow responds to tags beginning with `v` and then validates the complete tag format.

The workflow performs the following steps:

1. It checks out the tagged commit, validates the tag, and calculates the version and build number.
2. It imports the Developer ID Application certificate into a temporary keychain and configures Apple notarization credentials.
3. It archives the Release build, signs it with the hardened runtime enabled, exports `DropSweep.app`, and creates `DropSweep-X.Y.Z.zip`.
4. It submits the ZIP to Apple's notarization service, staples the notarization ticket to the app, recreates the ZIP, and verifies the result.
5. It creates the archive's Sparkle EdDSA signature and generates a new `appcast.xml`.
6. It creates a GitHub Release with the ZIP and automatically generated release notes from `.github/release.yml`.
7. It opens and automatically squash-merges a pull request that publishes the generated `appcast.xml` to `main`.
8. After the release metadata has been published, it deploys the website to Vercel Production.

Release-note categories are derived from pull-request labels: new features, bug fixes, documentation, maintenance, and other changes. The generated appcast contains only the new release, links its full release notes to the GitHub Release, and uses the GitHub Release asset as the update download.

## macOS Build and Sparkle Distribution

The workflow derives the app versions directly from the tag:

- `MARKETING_VERSION` is the semantic version without the leading `v`. For example, `v0.4.0` becomes `0.4.0`.
- `CURRENT_PROJECT_VERSION` is encoded as `major * 1,000,000 + minor * 1,000 + patch`. For example, `v0.4.0` becomes `4000`.

The numeric build version lets Sparkle compare releases reliably. Before building, the workflow compares it with the build currently advertised by the `appcast.xml` on `main` and stops if the new value is not greater.

The GitHub Release and the Sparkle update feed are related but separate publication steps. The release asset becomes available first. DropSweep reads its Sparkle feed from `appcast.xml` on `main`, so the new version does not appear in the app's **Check for Updates…** flow until the automated metadata pull request has been merged.

## Verifying a Release

After pushing the tag, verify the complete workflow:

1. In GitHub Actions, confirm that the **Release** workflow completed successfully, including the **Build & notarize**, **Release**, and **Deploy website** jobs.
2. Open the GitHub Release and verify its tag, title, release notes, and `DropSweep-X.Y.Z.zip` asset.
3. Download the ZIP, extract it, and confirm on a supported Mac that Gatekeeper recognizes DropSweep as a notarized app from an identified developer.
4. Confirm that the automated release-metadata pull request was squash-merged and that `appcast.xml` on `main` contains the new short version, numeric build version, download URL, and Sparkle signature.
5. From an older DropSweep version, use **Check for Updates…** and verify that Sparkle offers and installs the new release.
6. Verify that the production website shows the new release and that its download link resolves to the new GitHub Release asset.

A GitHub Release can already exist even if a later appcast publication or website deployment step fails. Verify all jobs and the in-app update path before considering the release complete.
