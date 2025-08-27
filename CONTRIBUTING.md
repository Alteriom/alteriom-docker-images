# Contributing to alteriom-docker-images

Thank you for your interest in contributing to alteriom-docker-images! This document provides guidelines and instructions for contributing to this Docker images project for PlatformIO and ESP platform development.

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Docker Image Standards](#docker-image-standards)
- [Testing Requirements](#testing-requirements)
- [Documentation](#documentation)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)

## Code of Conduct
This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Getting Started

### Prerequisites
- Docker 20.10+ for building and testing images
- Git configured with your GitHub account
- Bash shell for running scripts
- Access to Alteriom organization repositories

### Repository Access Setup
If you're having trouble accessing internal repositories, see our documentation on repository access configuration.

### Local Development Setup
1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/alteriom-docker-images.git`
3. Add upstream remote: `git remote add upstream https://github.com/Alteriom/alteriom-docker-images.git`
4. Make scripts executable: `chmod +x scripts/*.sh`
5. Create a feature branch: `git checkout -b feature/your-feature-name`

## Development Workflow

### Branch Naming Convention
- **Features**: `feature/description-of-feature`
- **Bug fixes**: `fix/description-of-fix`
- **Documentation**: `docs/description-of-changes`
- **Docker improvements**: `docker/description-of-changes`
- **Security updates**: `security/description-of-changes`

### Commit Message Format
We follow the [Conventional Commits](https://conventionalcommits.org/) specification for automated versioning:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New feature or Docker image enhancement
- `fix`: Bug fix or image optimization
- `docs`: Documentation changes
- `security`: Security improvements or vulnerability fixes
- `perf`: Performance improvements for image size or build time
- `test`: Adding or updating tests
- `ci`: CI/CD pipeline changes
- `chore`: Build process or auxiliary tool changes

**Examples:**
- `feat: add ESP32-C6 platform support to production image`
- `fix: resolve PlatformIO dependency conflicts in dev image`
- `docs: update README with new ESP platform examples`
- `security: update base image to python:3.11-slim for CVE fixes`
- `perf: optimize Docker layer caching for 20% build time reduction`

## Docker Image Standards

### Image Architecture
- **Base Image**: Always use `python:3.11-slim` for consistency and security
- **User Model**: Non-root user 'builder' with UID 1000
- **Working Directory**: `/workspace` for mounted project files
- **Entry Point**: PlatformIO CLI (`/usr/local/bin/platformio`)

### Multi-Platform Support
- Build for both `linux/amd64` and `linux/arm64`
- Test on both architectures when possible
- Use platform-agnostic installation methods

### Security Best Practices
- Keep base images updated
- Minimize attack surface with minimal package installation
- Run security scans with included tools
- Follow CIS Docker Benchmark guidelines

### Image Optimization
- Use multi-stage builds when appropriate
- Optimize layer caching for build performance
- Target image sizes: Production <500MB, Development <800MB
- Document optimization decisions in commit messages

## Testing Requirements

### Docker Image Testing
```bash
# Build and test images locally
docker build -t test-prod production/
docker build -t test-dev development/

# Test image functionality
docker run --rm test-prod --version
docker run --rm test-dev --version
```

### ESP Platform Testing
```bash
# Run comprehensive ESP platform tests
./scripts/test-esp-builds.sh

# Test specific image
./scripts/test-esp-builds.sh your-test-image:tag

# Test with custom project
./scripts/test-esp-builds.sh --project /path/to/your/platformio/project
```

### Verification Scripts
```bash
# Quick status check
./scripts/status-check.sh

# Comprehensive verification
./scripts/verify-images.sh

# Security scanning
./scripts/comprehensive-security-scanner.sh
```

### Testing Standards
- All Docker images must pass ESP platform build tests
- Security scans must show no critical vulnerabilities
- Images must work on both amd64 and arm64 architectures
- Build time improvements should be verified and documented

### Test Coverage Requirements
- Test all supported ESP platforms (ESP32, ESP32-S3, ESP32-C3, ESP8266)
- Verify PlatformIO functionality within containers
- Test both production and development images
- Validate security scanning integration

## Documentation

### Docker Image Documentation
- Update README.md for new features or changes
- Include usage examples for new ESP platforms
- Document any breaking changes or migration requirements
- Update OPTIMIZATION_GUIDE.md for size/performance improvements

### Security Documentation
- Update SECURITY.md for security-related changes
- Document new security tools or scanning procedures
- Include vulnerability remediation guidance

### Version Documentation
- Update CHANGELOG.md following Keep a Changelog format
- Document version compatibility and migration notes
- Include performance impact of changes

## Pull Request Process

### Before Creating a PR
1. **Build and test locally**: Ensure images build and pass tests
   ```bash
   ./scripts/build-images.sh
   ./scripts/test-esp-builds.sh
   ./scripts/comprehensive-security-scanner.sh
   ```
2. **Run security scans**: Check for vulnerabilities
3. **Update documentation**: Include relevant documentation updates
4. **Validate workflows**: Ensure only one workflow exists
   ```bash
   ./scripts/validate-workflows.sh
   ```

### PR Requirements
- [ ] Descriptive title following conventional commit format
- [ ] Link to related issues
- [ ] Docker images build successfully
- [ ] ESP platform tests pass
- [ ] Security scans complete without critical issues
- [ ] Documentation updated
- [ ] No merge conflicts
- [ ] All CI checks passing

### PR Template
```markdown
## Description
Brief description of Docker image changes

## Related Issues
Fixes #123

## Type of Change
- [ ] Docker image enhancement
- [ ] Bug fix
- [ ] New ESP platform support
- [ ] Security improvement
- [ ] Documentation update
- [ ] Performance optimization

## Testing
- [ ] Images build successfully on both architectures
- [ ] ESP platform tests pass
- [ ] Security scans complete
- [ ] Manual testing performed

## Image Impact
- [ ] Production image size: Before/After
- [ ] Development image size: Before/After
- [ ] Build time impact: Before/After
- [ ] New dependencies added (list them)

## Checklist
- [ ] Conventional commit format used
- [ ] Security best practices followed
- [ ] Documentation updated
- [ ] Tests passing
- [ ] Images optimized for size and performance
```

### Review Process
1. Create pull request against main branch
2. Assign relevant reviewers (Docker/PlatformIO experts)
3. Address review feedback promptly
4. Ensure all automated checks pass
5. Squash commits if requested before merge

## Issue Reporting

### Docker Image Issues
Use the docker_build_issue.md template and include:
- Docker version and platform
- Specific image and tag being used
- Complete error messages and logs
- Steps to reproduce the issue
- Expected vs actual behavior

### Platform Support Requests
Use the platform_support.md template for:
- New ESP platform requests
- Framework version updates
- Platform-specific build issues

### Security Vulnerabilities
Use the security_vulnerability.md template and include:
- Vulnerability details and impact
- Affected image versions
- Reproduction steps
- Proposed remediation

## Getting Help

### Resources
- [Alteriom Docker Images Documentation](./docs/)
- [PlatformIO Documentation](https://docs.platformio.org/)
- [Docker Best Practices](https://docs.docker.com/develop/best-practices/)
- [ESP Platform Documentation](https://docs.espressif.com/)

### Quick Verification
```bash
# Check repository status
./scripts/status-check.sh

# Verify your setup
./scripts/verify-images.sh

# Test ESP platforms
./scripts/test-esp-builds.sh --help
```

### Contact
- Create an issue for bugs or feature requests
- Use GitHub Discussions for questions
- Check existing documentation before asking

## Docker-Specific Guidelines

### Dockerfile Best Practices
- Use specific version tags, not `latest`
- Combine RUN commands to reduce layers
- Use `.dockerignore` to exclude unnecessary files
- Order commands by frequency of change (cache optimization)
- Clean up package caches after installation

### Build Optimization
- Leverage Docker layer caching
- Use multi-stage builds for complex images
- Minimize the number of layers
- Use `--no-cache` only when necessary

### Security Considerations
- Regular base image updates
- Scan images for vulnerabilities
- Follow principle of least privilege
- Use non-root users when possible

## Recognition

Contributors will be recognized in:
- CHANGELOG.md for their contributions
- GitHub releases for significant improvements
- Project documentation credits
- Annual contributor appreciation

Thank you for contributing to alteriom-docker-images and helping improve Docker-based ESP development workflows!