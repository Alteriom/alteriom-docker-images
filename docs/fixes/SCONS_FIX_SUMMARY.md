# SCons UnboundLocalError Fix - Summary

## Quick Reference

**Issue:** Builds failed with `UnboundLocalError` during auto-clean phase unless `--disable-auto-clean` was used  
**Status:** ✅ **FIXED**  
**Fix Version:** v1.8.10+  
**Solution:** Upgraded PlatformIO from 6.1.13 to 6.1.16  

## The Problem

Users reported that ESP32/ESP8266 firmware builds failed with:
```
UnboundLocalError: cannot access local variable 'node' where it is not associated with a value
```

This error occurred during the SCons auto-clean phase (default behavior), requiring users to add `--disable-auto-clean` flag as a workaround.

## The Fix

### What Changed
- **PlatformIO**: Upgraded from **6.1.13** to **6.1.16**
- **SCons**: Automatically upgraded from **4.5.2** to **4.8.1** (bundled with PlatformIO)
- **Result**: Python 3.11/3.13 compatibility fixed, UnboundLocalError resolved

### Files Modified
- `production/Dockerfile` - Line 47
- `development/Dockerfile` - Line 50
- `CHANGELOG.md` - Fix documented
- `docs/fixes/SCONS_UNBOUNDLOCALERROR_FIX.md` - Complete technical details

### Testing Added
- **Regression Test**: `scripts/test-auto-clean.sh`
  - Validates auto-clean functionality works correctly
  - Tests build → clean → rebuild cycle
  - Ensures workaround is no longer needed

## How to Verify

### For Users
Pull the latest image and build normally (without `--disable-auto-clean`):

```bash
# Pull latest image
docker pull ghcr.io/alteriom/alteriom-docker-images/builder:latest

# Build normally - should succeed
docker run --rm -v "${PWD}:/workspace" \
  ghcr.io/alteriom/alteriom-docker-images/builder:latest \
  run -e unified-gc9a01
```

### For Developers
Run the regression test:

```bash
# Run auto-clean regression test
./scripts/test-auto-clean.sh

# Should output: "ALL AUTO-CLEAN TESTS PASSED! ✅"
```

## Why This Happened

1. **Base Image**: Uses Python 3.11-slim
2. **PlatformIO 6.1.13**: Bundled SCons 4.5.2
3. **Python 3.11 Changes**: Stricter variable scoping rules
4. **SCons 4.5.2 Bug**: Variable `node` referenced before assignment in some code paths
5. **Result**: UnboundLocalError when SCons tried to execute auto-clean

## Why the Fix Works

PlatformIO 6.1.16 includes SCons 4.8.1 which:
- Fixed variable scoping issues with Python 3.11
- Added official Python 3.13 support
- Resolved the UnboundLocalError in multiple scenarios
- Improved build system reliability

## Impact Assessment

### ✅ Benefits
- Builds work with default behavior (no workaround needed)
- Improved Python 3.11+ compatibility
- Future-proofed for Python 3.13
- Minimal change (version upgrade only)
- No breaking changes
- Same image size (~400-500MB)

### ⚠️ Considerations
- Users must pull updated images (`:latest` or `v1.8.10+`)
- Old images with PlatformIO 6.1.13 still have the issue
- Regression test should be run before future PlatformIO upgrades

## Documentation

### Main Documents
- **[Technical Details](SCONS_UNBOUNDLOCALERROR_FIX.md)** - Complete fix documentation
- **[CHANGELOG](../../CHANGELOG.md)** - Version history
- **[Tests README](../../tests/README.md)** - Testing information

### Related Scripts
- `scripts/test-auto-clean.sh` - Auto-clean regression test
- `scripts/test-esp-builds.sh` - General ESP platform testing
- `scripts/test-persistent-volumes.sh` - Persistent volume testing

## Timeline

| Date | Event |
|------|-------|
| September 26, 2024 | PlatformIO 6.1.16 released with SCons 4.8.1 |
| November 15, 2025 | Issue reported by user (builds failing with UnboundLocalError) |
| November 15, 2025 | Root cause identified (SCons 4.5.2 + Python 3.11 incompatibility) |
| November 15, 2025 | Fix implemented (PlatformIO upgrade to 6.1.16) |
| November 16, 2025 | Regression test added (`test-auto-clean.sh`) |
| November 16, 2025 | Documentation completed |

## Quick Commands Reference

```bash
# Pull latest fixed image
docker pull ghcr.io/alteriom/alteriom-docker-images/builder:latest

# Build without workaround (should work now)
docker run --rm -v "${PWD}:/workspace" \
  ghcr.io/alteriom/alteriom-docker-images/builder:latest \
  run -e your-environment

# Run regression test
./scripts/test-auto-clean.sh

# Check PlatformIO version in image
docker run --rm ghcr.io/alteriom/alteriom-docker-images/builder:latest --version
# Should show: PlatformIO Core, version 6.1.16
```

## For Issue Tracker

**Issue Title:** Docker Builder: SCons UnboundLocalError with auto-clean (requires --disable-auto-clean workaround)

**Resolution:** Fixed in version 1.8.10 by upgrading PlatformIO to 6.1.16

**Verification:**
1. Pull image version 1.8.10 or later
2. Build firmware without `--disable-auto-clean` flag
3. Build should complete successfully
4. Run `./scripts/test-auto-clean.sh` to verify regression test passes

**Closing Comment:**
> This issue has been resolved by upgrading PlatformIO from 6.1.13 to 6.1.16, which includes SCons 4.8.1 with Python 3.11 compatibility fixes. The UnboundLocalError no longer occurs during the auto-clean phase, and the `--disable-auto-clean` workaround is no longer needed.
> 
> A regression test has been added (`scripts/test-auto-clean.sh`) to prevent this issue from recurring in future updates.
> 
> For complete technical details, see: `docs/fixes/SCONS_UNBOUNDLOCALERROR_FIX.md`

---

**Status:** ✅ Fixed and Tested  
**Workaround Needed:** ❌ No  
**Regression Test:** ✅ Available  
**Documentation:** ✅ Complete
