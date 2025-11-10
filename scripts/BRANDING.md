# Branding Configuration

This project uses a dynamic branding system that allows you to customize the application name, GitHub links, and other branding elements without manually editing code files.

## How It Works

The branding system uses a combination of:
1. **package.json configuration** - Static branding config
2. **Environment variables** - Runtime overrides (higher priority)
3. **Automated script** - Patches source files before build

## Configuration

### 1. Package.json Branding Config

Edit the `branding` section in `package.json`:

```json
{
  "branding": {
    "appName": "CodemiDev",
    "description": "open-source collaborative wiki and documentation",
    "githubOrg": "codemiproject",
    "githubRepo": "forkmost",
    "poweredByText": "Powered by CodemiDev"
  }
}
```

### 2. Environment Variables (Optional Override)

You can override branding at build time using environment variables:

```bash
APP_NAME="MyCustomApp" pnpm build
GITHUB_ORG="myorg" GITHUB_REPO="myrepo" pnpm build
```

Available environment variables:
- `APP_NAME` - Application name
- `APP_DESCRIPTION` - App description
- `GITHUB_ORG` - GitHub organization/username
- `GITHUB_REPO` - GitHub repository name
- `POWERED_BY_TEXT` - "Powered by" button text

### 3. .env Files

Update the `.env.example` files for runtime configuration:

**apps/client/.env.example:**
```env
VITE_APP_NAME=CodemiDev
```

**Root .env.example:**
```env
MAIL_FROM_NAME=CodemiDev
```

## Usage

### Automatic (Recommended)

The branding replacement runs automatically before build:

```bash
pnpm build  # Automatically runs brand-replace.js before building
```

### Manual

You can manually run the branding replacement:

```bash
pnpm brand  # or: node scripts/brand-replace.js
```

### With Custom Values

```bash
APP_NAME="MyApp" GITHUB_ORG="myorg" pnpm brand
```

## What Gets Replaced

The script replaces branding in the following files:

### Frontend
- `apps/client/src/lib/config.ts` - `getAppName()` function
- `apps/client/src/features/share/components/share-branding.tsx` - "Powered by" button
- `apps/client/src/features/share/components/share-shell.tsx` - Share page header
- `apps/client/src/components/layouts/global/app-header.tsx` - Main app header
- `apps/client/src/components/ui/error-404.tsx` - Error page title
- `apps/client/src/components/settings/app-version.tsx` - Version display and GitHub link
- `apps/client/index.html` - HTML title and PWA meta tags
- `apps/client/public/manifest.json` - PWA app name

### Backend
- `apps/server/src/integrations/transactional/partials/partials.tsx` - Email footer

## Priority Order

Values are resolved in this order (highest to lowest):
1. Environment variables
2. package.json branding config
3. Default values (Forkmost)

## Examples

### Example 1: Complete Rebrand

```json
// package.json
{
  "branding": {
    "appName": "MyWiki",
    "description": "internal knowledge base",
    "githubOrg": "mycompany",
    "githubRepo": "wiki",
    "poweredByText": "Built with MyWiki"
  }
}
```

```bash
pnpm build
```

### Example 2: Temporary Override

```bash
APP_NAME="DevelopmentBuild" pnpm brand
```

### Example 3: Multiple Environment Variables

```bash
APP_NAME="CustomApp" \
GITHUB_ORG="custom-org" \
GITHUB_REPO="custom-repo" \
POWERED_BY_TEXT="Made with CustomApp" \
pnpm build
```

## Troubleshooting

### Script not running on build?

Check that `prebuild` is defined in package.json scripts:
```json
{
  "scripts": {
    "prebuild": "node scripts/brand-replace.js"
  }
}
```

### Changes not appearing?

1. Make sure you run the build command (prebuild hook runs automatically)
2. Or manually run: `pnpm brand`
3. Check that source files aren't being cached

### Want to restore original branding?

```bash
git checkout apps/client apps/server  # Revert changes
pnpm brand  # Re-run with current config
```

## Notes

- The script is idempotent - you can run it multiple times safely
- It uses regex patterns to find and replace specific branding elements
- Changes are made to source files, so you can commit them or regenerate as needed
- The `prebuild` hook ensures branding is always applied before production builds
