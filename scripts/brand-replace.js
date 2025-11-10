#!/usr/bin/env node

/**
 * Brand Replacement Script
 *
 * This script replaces hardcoded branding references (like "Forkmost")
 * with values from package.json config or environment variables.
 *
 * Priority: ENV vars > package.json config > defaults
 */

const fs = require('fs');
const path = require('path');

// Load package.json
const packageJson = JSON.parse(
  fs.readFileSync(path.join(__dirname, '../package.json'), 'utf8')
);

// Get branding config from package.json or defaults
const branding = packageJson.branding || {};

const APP_NAME = process.env.APP_NAME || branding.appName || 'Forkmost';
const APP_DESCRIPTION = process.env.APP_DESCRIPTION || branding.description || 'open-source collaborative wiki and documentation';
const GITHUB_ORG = process.env.GITHUB_ORG || branding.githubOrg || 'Vito0912';
const GITHUB_REPO = process.env.GITHUB_REPO || branding.githubRepo || 'forkmost';
const POWERED_BY_TEXT = process.env.POWERED_BY_TEXT || branding.poweredByText || `Powered by ${APP_NAME}`;

console.log('🎨 Starting brand replacement...');
console.log(`   App Name: ${APP_NAME}`);
console.log(`   GitHub: ${GITHUB_ORG}/${GITHUB_REPO}`);
console.log('');

// Files to patch with their replacement patterns
const filesToPatch = [
  {
    path: 'apps/client/src/lib/config.ts',
    replacements: [
      { from: /(export function getAppName\(\): string \{\s*return )".*?";/g, to: `$1"${APP_NAME}";` }
    ]
  },
  {
    path: 'apps/client/src/features/share/components/share-branding.tsx',
    replacements: [
      { from: /href="https:\/\/github\.com\/[^/]+\/[^"]+"/g, to: `href="https://github.com/${GITHUB_ORG}/${GITHUB_REPO}"` },
      { from: />\s*Powered by [^<]+</g, to: `>\n        ${POWERED_BY_TEXT}<` }
    ]
  },
  {
    path: 'apps/client/src/features/share/components/share-shell.tsx',
    replacements: [
      { from: /\|\| ".*?"\}/g, to: `|| "${APP_NAME}"}` }
    ]
  },
  {
    path: 'apps/client/src/components/layouts/global/app-header.tsx',
    replacements: [
      { from: /\|\| ".*?"\}/g, to: `|| "${APP_NAME}"}` }
    ]
  },
  {
    path: 'apps/client/src/components/ui/error-404.tsx',
    replacements: [
      { from: /- .+?\`\}/g, to: `- ${APP_NAME}\`}` }
    ]
  },
  {
    path: 'apps/client/src/components/settings/app-version.tsx',
    replacements: [
      { from: /https:\/\/github\.com\/[^/]+\/[^/]+\/releases/g, to: `https://github.com/${GITHUB_ORG}/${GITHUB_REPO}/releases` },
      { from: /- .+?</g, to: `- ${APP_NAME}<` }
    ]
  },
  {
    path: 'apps/server/src/integrations/transactional/partials/partials.tsx',
    replacements: [
      { from: /\} .+?, open-source collaborative wiki and documentation/g, to: `} ${APP_NAME}, ${APP_DESCRIPTION}` }
    ]
  },
  {
    path: 'apps/client/index.html',
    replacements: [
      { from: /<title>.*?<\/title>/g, to: `<title>${APP_NAME}</title>` },
      { from: /content=".*?" name="apple-mobile-web-app-title"/g, to: `content="${APP_NAME}" name="apple-mobile-web-app-title"` },
      { from: /content=".*?" name="application-name"/g, to: `content="${APP_NAME}" name="application-name"` }
    ]
  },
  {
    path: 'apps/client/public/manifest.json',
    replacements: [
      { from: /"name":\s*".*?"/g, to: `"name": "${APP_NAME}"` },
      { from: /"short_name":\s*".*?"/g, to: `"short_name": "${APP_NAME}"` }
    ]
  }
];

let patchedCount = 0;
let errorCount = 0;

// Apply patches
filesToPatch.forEach(({ path: filePath, replacements }) => {
  const fullPath = path.join(__dirname, '..', filePath);

  try {
    if (!fs.existsSync(fullPath)) {
      console.log(`⚠️  Skipping: ${filePath} (not found)`);
      return;
    }

    let content = fs.readFileSync(fullPath, 'utf8');
    let modified = false;

    replacements.forEach(({ from, to }) => {
      if (from.test(content)) {
        content = content.replace(from, to);
        modified = true;
      }
    });

    if (modified) {
      fs.writeFileSync(fullPath, content, 'utf8');
      console.log(`✅ Patched: ${filePath}`);
      patchedCount++;
    } else {
      console.log(`⏭️  No changes: ${filePath}`);
    }
  } catch (error) {
    console.error(`❌ Error patching ${filePath}:`, error.message);
    errorCount++;
  }
});

console.log('');
console.log(`🎉 Brand replacement complete!`);
console.log(`   Patched: ${patchedCount} files`);
if (errorCount > 0) {
  console.log(`   Errors: ${errorCount} files`);
  process.exit(1);
}
