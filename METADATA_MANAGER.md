# Repository Metadata Manager

This repository uses the `@alteriom/repository-metadata-manager` NPM package to ensure compliance with organization-wide metadata standards.

## Quick Commands

```bash
# Check compliance status
npm run metadata:validate

# Generate detailed compliance report  
npm run metadata:report

# Preview what changes would be made (safe)
npm run metadata:dry-run

# Apply automated fixes (requires GitHub token with repo permissions)
npm run metadata:apply
```

## What It Does

The Repository Metadata Manager automatically:

- ✅ **Syncs repository descriptions** from package.json files
- ✅ **Manages topics/tags** based on repository type and keywords  
- ✅ **Ensures organization branding** with "alteriom" tag
- ✅ **Validates compliance** against organization standards
- ✅ **Prevents drift** by maintaining consistent metadata
- ✅ **Integrates with CI/CD** for automated validation

## Current Compliance Issues

Based on the latest report, this repository has the following compliance issues:

- ❌ Missing repository description
- ❌ Missing repository topics/tags for discoverability  
- ❌ Missing "alteriom" organization tag

## Expected Changes

When `npm run metadata:apply` is run with proper GitHub permissions, it will:

- **Set Description**: "Pre-built PlatformIO builder images for the Alteriom project (ESP32/ESP32-C3/ESP8266)..."
- **Add Topics**: `[alteriom, docker, platformio, esp32, esp32-c3, esp8266, embedded, iot, firmware, build-tools, ci-cd, automation, github-integration, compliance]`

## CI/CD Integration

The `.github/workflows/compliance.yml` workflow automatically:

- ✅ **Validates compliance** on every push and PR
- ✅ **Generates reports** for visibility
- ✅ **Auto-fixes issues** on main branch pushes
- ✅ **Triggers organization-wide validation** from the alteriom-ai-agent repository

## Manual Application

If you have appropriate GitHub permissions, you can apply the fixes manually:

```bash
# Set GitHub token (required for write operations)
export GITHUB_TOKEN="your_github_token"

# Apply the fixes
npm run metadata:apply
```

## Organization Compliance

This repository integrates with the global Alteriom compliance system:

- **Central Hub**: [alteriom-ai-agent repository](https://github.com/Alteriom/alteriom-ai-agent)
- **Global Dashboard**: [Compliance Actions](https://github.com/Alteriom/alteriom-ai-agent/actions)
- **Organization Monitoring**: All repositories monitored from central location

## Implementation Complete

The Repository Metadata Manager has been successfully implemented with:

- ✅ NPM package installed and configured
- ✅ All compliance scripts available via npm commands
- ✅ CI/CD integration for automated validation
- ✅ Ready for organization-wide compliance monitoring

To complete the compliance fixes, the `npm run metadata:apply` command needs to be run with appropriate GitHub API permissions.