# Docker Configuration Examples

This directory contains example Docker and Docker Compose configurations for using Alteriom Docker images.

## Available Examples

### docker-compose-persistent.yml

Complete docker-compose configuration demonstrating how to use persistent volumes with Alteriom Docker images.

**Features:**
- Persistent PlatformIO cache for faster builds
- Both production and development service examples
- Proper volume configuration
- Usage examples and comments

**Quick Start:**
```bash
# Copy the example to your project
cp docs/examples/docker-compose-persistent.yml docker-compose.yml

# Edit as needed, then run
docker-compose run --rm alteriom-builder run -e esp32dev
```

**Benefits:**
- First build: ~5 minutes (downloads packages)
- Subsequent builds: ~30 seconds (uses cache)
- No need to re-download packages on each build

## Related Documentation

- [Persistent Volumes Guide](../guides/PERSISTENT_VOLUMES.md) - Complete guide to using persistent volumes
- [User Installation Guide](../guides/USER_INSTALLATION_GUIDE.md) - General installation and usage instructions
- [Quick Reference Card](../QUICK_REFERENCE.md) - Essential commands reference

## Feedback

If you have suggestions for additional examples or improvements to existing ones, please:
1. Open an issue at https://github.com/Alteriom/alteriom-docker-images/issues
2. Submit a pull request with your improvements
3. Share your configuration on the discussion board

## License

These examples are provided under the same MIT license as the main project.
