# GitHub Publication Notes

## Recommended Visibility

Use a public repository when the goal is to show the codebase and product direction.

Present ClipPocket as a work-in-progress native macOS utility, not as a finished commercial release.

## Repository Contents

Commit:

- source code
- Xcode project files
- app assets inside `apps/mac/ClipPocket/Resources`
- documentation
- GitHub workflow files
- root README
- `.gitignore`
- license notice

Do not commit:

- `.dmg` files
- zipped app builds
- `DerivedData`
- Xcode user state
- `.DS_Store`
- local environment files
- temporary design scratch files

## Distribution Artifacts

For public GitHub, keep the repository source-first.

When ClipPocket is ready for external installs, attach the `.dmg` to a GitHub Release instead of committing it to the repository.

## Before First Public Push

Run:

```sh
xcodebuild -project apps/mac/ClipPocket.xcodeproj -scheme ClipPocket -configuration Release build
```

Check:

- README describes the app honestly
- app builds locally
- no private files are staged
- no local `.dmg` files are staged
- no `xcuserdata` or `.xcuserstate` files are staged
- GitHub Actions build is present

## Suggested First Commit

```sh
git init
git add .
git commit -m "Prepare ClipPocket for public GitHub"
git branch -M main
```

Then create a new public GitHub repository and push:

```sh
git remote add origin git@github.com:<account>/<repo>.git
git push -u origin main
```

Replace `<account>` and `<repo>` with the real GitHub account and repository name.
