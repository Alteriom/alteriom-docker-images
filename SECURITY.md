# Security Policy

## Overview

Security is a top priority for the Alteriom Docker Images project. This document outlines our security policies, supported versions, vulnerability reporting procedures, and security best practices.

## Supported Versions

We actively maintain and provide security updates for the following versions:

| Version | Status | Support Level | Notes |
| ------- | ------ | ------------- | ----- |
| 1.8.x   | ✅ Supported | Full security support | Current stable release |
| 1.7.x   | ⚠️ Limited | Security fixes only | Use 1.8.x for new deployments |
| < 1.7   | ❌ Unsupported | No updates | Upgrade to 1.8.x immediately |

**Note:** We recommend always using the latest stable version (`:latest` tag) to receive the most recent security updates and patches.

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security issue in alteriom-docker-images, please follow these steps:

### How to Report

1. **DO NOT** open a public GitHub issue
2. **DO NOT** disclose the vulnerability publicly before we've had a chance to address it
3. Email security reports to: **security@alteriom.org** (or create a private security advisory)
4. Use GitHub's private vulnerability reporting feature: https://github.com/Alteriom/alteriom-docker-images/security/advisories/new

### What to Include

Please provide as much information as possible:

- **Description**: Clear description of the vulnerability
- **Affected versions**: Which image versions are impacted
- **Impact**: Potential security impact and attack scenarios
- **Steps to reproduce**: Detailed steps to reproduce the vulnerability
- **Proof of concept**: If available, code or commands demonstrating the issue
- **Suggested fix**: If you have ideas for remediation (optional)
- **Disclosure timeline**: Your expected timeline for public disclosure

### Response Timeline

- **Initial response**: Within 48 hours of report
- **Status update**: Within 5 business days with initial assessment
- **Resolution timeline**: Within 30 days for critical issues, 90 days for others
- **Public disclosure**: Coordinated with reporter after fix is available

## Security Update Process

Our security update workflow:

1. **Report received**: Vulnerability report is received and acknowledged
2. **Verification**: Security team verifies and reproduces the issue
3. **Assessment**: CVSS score assigned, severity determined
4. **Fix development**: Patch developed and tested internally
5. **Security advisory**: GitHub Security Advisory created (private)
6. **Release**: Fixed version released with security notes
7. **Notification**: Users notified via GitHub releases and advisories
8. **Public disclosure**: Full details published after users have time to update (typically 7-14 days)

## Docker Image Security Features

Our Docker images include multiple security layers:

### Container Security

- ✅ **Non-root execution**: Containers run as non-root user `builder` (UID 1000)
- ✅ **Minimal base image**: Built on `python:3.11-slim` for reduced attack surface
- ✅ **No unnecessary packages**: Only essential tools included
- ✅ **Read-only filesystem capable**: Supports read-only root filesystem
- ✅ **Security labels**: Proper metadata and security labels applied

### Build Security

- ✅ **Pinned versions**: PlatformIO version pinned (currently 6.1.13)
- ✅ **Verified sources**: All packages from trusted PyPI and Debian repositories
- ✅ **Build tools removed**: Compilation tools removed after build
- ✅ **Clean package caches**: No cached packages in final images
- ✅ **Multi-platform support**: Native builds for amd64 and arm64

### Runtime Security

- ✅ **Entrypoint validation**: Secure entrypoint with permission handling
- ✅ **Volume security**: Proper permission handling for mounted volumes
- ✅ **Network isolation**: No unnecessary network services
- ✅ **Resource limits**: Supports Docker resource constraints

## Security Scanning

We employ comprehensive automated security scanning:

### Continuous Scanning

- **Trivy**: Filesystem and container vulnerability scanning
- **Hadolint**: Dockerfile best practices analysis
- **Safety**: Python dependency vulnerability scanning
- **ClamAV**: Malware detection
- **YARA**: Pattern-based malware scanning

### Manual Security Testing

Run security scans locally:

```bash
# Comprehensive security scan
./scripts/enhanced-security-monitoring.sh

# Malware scanning
./scripts/malware-scanner.sh

# Quick security check
./scripts/verify-images.sh
```

## Security Best Practices for Users

When using our Docker images:

### Container Execution

- **Always use specific version tags** in production (not `:latest`)
- **Run with minimal privileges**: Use `--security-opt=no-new-privileges`
- **Drop capabilities**: Use `--cap-drop=ALL` unless specific capabilities needed
- **Use read-only filesystem**: Add `--read-only` flag when possible
- **Network isolation**: Use `--network=none` if network access not required

### Volume Management

- **Use non-root user**: For persistent volumes, use `--user root` with our entrypoint which drops privileges
- **Restrict permissions**: Mount volumes with appropriate permissions (e.g., `:ro` for read-only)
- **Avoid sensitive data**: Don't mount directories containing secrets or sensitive files

### Example Secure Usage

```bash
# Secure container execution with minimal privileges
docker run --rm \
  --user root \
  --security-opt=no-new-privileges \
  --cap-drop=ALL \
  --read-only \
  --tmpfs /tmp \
  -v ${PWD}:/workspace:ro \
  -v platformio_cache:/home/builder/.platformio \
  ghcr.io/alteriom/alteriom-docker-images/builder:1.8.6 \
  run -e esp32dev
```

## Known Security Considerations

### Python 3.11 + SCons Compatibility

- **Issue**: SCons 4.8.x has issues with Python 3.11
- **Mitigation**: We use PlatformIO 6.1.13 with SCons 4.7.0 (stable)
- **Status**: ✅ Resolved in v1.8.12+

### Persistent Volume Permissions

- **Issue**: Volume permissions may require root access
- **Mitigation**: Entrypoint handles permissions then drops to non-root
- **Usage**: Run with `--user root` when using persistent volumes
- **Status**: ✅ Secure by design (automatic privilege dropping)

## Compliance and Standards

Our images follow:

- **CIS Docker Benchmark**: Container security best practices
- **NIST Guidelines**: Container security standards
- **OWASP Container Security**: Top 10 container risks mitigation
- **GitHub Security Best Practices**: Supply chain security

## Security Documentation

For more detailed security information:

- [Comprehensive Security Analysis](docs/security/COMPREHENSIVE_SECURITY_ANALYSIS.md)
- [Security Monitoring](docs/security/SECURITY_MONITORING.md)
- [Security Practices Guide](docs/security/SECURITY_PRACTICES_IMPLEMENTATION_GUIDE.md)
- [Advanced Security Updates](docs/security/ADVANCED_SECURITY_UPDATE.md)

## Contact

- **Security issues**: security@alteriom.org or use GitHub private vulnerability reporting
- **General questions**: Open a GitHub issue with the security tag
- **Security advisories**: https://github.com/Alteriom/alteriom-docker-images/security/advisories

---

Thank you for helping keep alteriom-docker-images secure!
