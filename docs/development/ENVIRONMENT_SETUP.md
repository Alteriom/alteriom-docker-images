# Environment Setup Guide

This guide explains how to set up the local development environment for the alteriom-docker-images project.

## Environment Variables

The project uses environment variables for configuration. These are stored in a `.env` file for local development.

### Setup Steps

1. **Copy the example file:**
   ```bash
   cp .env.example .env
   ```

2. **Configure your tokens and settings** in the `.env` file:

### Required Configuration

#### NPM Token
- **Purpose**: Publishing packages to npm registry
- **Get token**: [NPM Settings → Access Tokens](https://www.npmjs.com/settings/tokens)
- **Required permissions**: Automation tokens or Granular access tokens with publish scope
- **Example**: `NPM_TOKEN=npm_your_actual_token_here`

#### GitHub Token
- **Purpose**: Repository metadata operations and API access
- **Get token**: [GitHub Settings → Personal Access Tokens](https://github.com/settings/tokens)
- **Required permissions**: 
  - `repo` (full repository access) for private repositories
  - `public_repo` for public repositories only
- **Example**: `GITHUB_TOKEN=ghp_your_actual_token_here`

#### Repository Settings
- **GITHUB_REPOSITORY_OWNER**: Your GitHub username or organization
- **GITHUB_REPOSITORY_NAME**: Repository name (usually `alteriom-docker-images`)
- **ORGANIZATION_TAG**: Short tag for your organization (used in tagging)
- **ORGANIZATION_NAME**: Full organization name

### Example Configuration

For the Alteriom organization:
```properties
GITHUB_REPOSITORY_OWNER=Alteriom
GITHUB_REPOSITORY_NAME=alteriom-docker-images
ORGANIZATION_TAG=alteriom
ORGANIZATION_NAME=Alteriom
```

For a personal fork:
```properties
GITHUB_REPOSITORY_OWNER=yourusername
GITHUB_REPOSITORY_NAME=alteriom-docker-images
ORGANIZATION_TAG=yourorg
ORGANIZATION_NAME=Your Organization
```

## Security Notes

- ⚠️ **Never commit the `.env` file** - it contains sensitive tokens
- ✅ The `.env` file is already in `.gitignore`
- ✅ Use `.env.example` as a template for required variables
- 🔒 Rotate tokens regularly for security
- 🔒 Use tokens with minimal required permissions

## Validation

After setting up your `.env` file, validate the configuration:

```bash
npm run metadata:validate
```

This will check that all required environment variables are set and tokens are valid.

## Troubleshooting

### Token Issues
- **NPM token invalid**: Regenerate at [NPM Settings](https://www.npmjs.com/settings/tokens)
- **GitHub token invalid**: Check permissions and regenerate at [GitHub Settings](https://github.com/settings/tokens)
- **Repository not found**: Verify `GITHUB_REPOSITORY_OWNER` and `GITHUB_REPOSITORY_NAME`

### Permission Issues
- Ensure GitHub token has `repo` scope for private repositories
- Ensure NPM token has publish permissions
- Check that you have write access to the repository

---

For more information, see the [main README](../README.md) or [admin setup guide](../admin/ADMIN_SETUP.md).
