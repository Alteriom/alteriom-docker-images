# Current Repository Status - October 10, 2025

## 🔴 Docker Images Status: NOT PUBLISHED YET

**Error you're seeing:**
```
Error response from daemon: Head "https://ghcr.io/v2/alteriom/alteriom-docker-images/builder/manifests/latest": denied: denied
```

**This is EXPECTED** - The Docker images have not been built and published yet.

## ✅ What's Working

1. **Repository structure** - All files properly organized
2. **Documentation** - Complete and accurate
3. **GitHub Actions workflow** - Configured and ready
4. **Scripts** - All helper scripts in place

## 🚀 What You Need to Do (First-Time Setup)

### Step 1: Trigger the First Build

1. Go to: https://github.com/Alteriom/alteriom-docker-images/actions
2. Click on "Build and Publish Docker Images" workflow (or "ESP32/ESP8266 Docker Pipeline")
3. Click the "Run workflow" button (top right)
4. Select branch: `main`
5. Click "Run workflow" (green button)
6. **Wait 20-30 minutes** for the build to complete

### Step 2: Make Packages Public

After the build completes successfully:

#### For the Builder (Production) Image:
1. Visit: https://github.com/Alteriom/alteriom-docker-images/pkgs/container/alteriom-docker-images%2Fbuilder
2. Click "Package settings" (gear icon)
3. Scroll to "Danger Zone" at bottom
4. Click "Change visibility"
5. Select "Public"
6. Type the package name to confirm
7. Click "I understand, change package visibility"

#### For the Dev (Development) Image:
1. Visit: https://github.com/Alteriom/alteriom-docker-images/pkgs/container/alteriom-docker-images%2Fdev
2. Repeat the same steps as above

### Step 3: Verify It Works

After making packages public, test the pull command:

```bash
# Should work now!
docker pull ghcr.io/alteriom/alteriom-docker-images/builder:latest

# Or use the verification script
./scripts/verify-images.sh
```

## 📋 Expected Timeline

- **Build time**: 20-30 minutes (first build takes longer)
- **Making public**: 2 minutes (manual steps)
- **Total time**: ~25-35 minutes

## ⚠️ Important Notes

### Correct Package URLs (lowercase!)

GHCR requires lowercase repository names:

✅ **CORRECT:**
```bash
ghcr.io/alteriom/alteriom-docker-images/builder:latest
ghcr.io/alteriom/alteriom-docker-images/dev:latest
```

❌ **INCORRECT:**
```bash
ghcr.io/Alteriom/alteriom-docker-images/builder:latest  # Capital A won't work
```

### Build Triggers

After initial setup, builds will run automatically:
- **Daily**: 02:00 UTC (development image only)
- **PR merges**: Both images rebuild
- **Manual**: Via Actions tab anytime

## 🔍 Troubleshooting

### "denied: denied" Error
- **Cause**: Images not published OR packages not public
- **Solution**: Complete Steps 1 and 2 above

### Build Fails
- **Check**: GitHub Actions logs at https://github.com/Alteriom/alteriom-docker-images/actions
- **Common issues**: 
  - Network connectivity
  - GitHub token permissions
  - Dockerfile syntax errors

### Can't Make Package Public
- **Check**: You need admin/write access to the repository
- **Check**: Package must exist first (complete Step 1)

## 📚 Complete Documentation

For detailed instructions, see:
- **[README.md](README.md)** - Main documentation
- **[docs/guides/USER_INSTALLATION_GUIDE.md](docs/guides/USER_INSTALLATION_GUIDE.md)** - Complete setup guide
- **[docs/admin/ADMIN_SETUP.md](docs/admin/ADMIN_SETUP.md)** - Administrator documentation

## 🎯 After Setup

Once images are published and public, users can:

```bash
# Pull the image
docker pull ghcr.io/alteriom/alteriom-docker-images/builder:latest

# Build ESP32 firmware
cd /path/to/your/platformio/project
docker run --rm -v ${PWD}:/workspace \
  ghcr.io/alteriom/alteriom-docker-images/builder:latest \
  pio run -e esp32dev
```

## ✅ Checklist

- [ ] Triggered first build via GitHub Actions
- [ ] Waited for build to complete (~20-30 min)
- [ ] Made `builder` package public
- [ ] Made `dev` package public  
- [ ] Tested: `docker pull ghcr.io/alteriom/alteriom-docker-images/builder:latest`
- [ ] Verified with: `./scripts/verify-images.sh`

---

**Current Date**: October 10, 2025  
**Status**: Awaiting initial build and publication  
**Next Action**: Go to Actions tab and trigger the workflow

**Quick Link**: https://github.com/Alteriom/alteriom-docker-images/actions
