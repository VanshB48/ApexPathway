# Quickstart & Verification Guide: Foundations & Secret Hygiene

**Feature**: `001-project-initialization`
**Phase**: Phase 1 Design

This guide details the exact steps and runnable commands to initialize, verify, and test the repository foundations and secret hygiene safeguards.

---

## 1. Prerequisites Check

Verify required runtimes are installed:

```powershell
# 1. Java 21 LTS
java -version

# 2. Node.js 20+ and npm 10+
node --version
npm --version

# 3. Docker (Optional for DB verification)
docker --version
```

---

## 2. Setup & Bootstrapping Commands

### Step 2.1: Initialize Root Starter Files
Ensure the following files exist in the project root:
- `.env.example`
- `.gitignore`
- `docker-compose.yml`
- `README.md`

### Step 2.2: Install Pre-Commit Secret Scanner Hook
Run the installation script to configure `.git/hooks/pre-commit`:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/install-git-hooks.ps1
```

---

## 3. Verification & Acceptance Testing

### Test 1: Secret Leakage Hook Verification (Blocked Commit)
Simulate an accidental secret commit:
```powershell
# 1. Create a temporary staged file with a simulated secret key
Set-Content -Path "test_secret.txt" -Value "GEMINI_API_KEY=AIzaSyA1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q"
git add test_secret.txt

# 2. Attempt to commit
git commit -m "test: accidental secret commit"

# Expected Outcome:
# The pre-commit hook MUST intercept the commit, print a RED security alert, and exit with code 1.

# 3. Cleanup
git reset HEAD test_secret.txt
Remove-Item test_secret.txt
```

### Test 2: Multi-Tier .gitignore Verification
Verify that `.env.local` and database storage files are strictly ignored:
```powershell
New-Item -ItemType File -Path ".env.local" -Force
git status --porcelain

# Expected Outcome:
# .env.local must NOT appear in untracked files list.
Remove-Item .env.local
```

### Test 3: Backend Build & Dependency Resolution
```powershell
cd backend
mvn clean compile
cd ..

# Expected Outcome:
# [INFO] BUILD SUCCESS
```

### Test 4: Frontend Asset Compilation
```powershell
cd frontend
npm install
npm run build
cd ..

# Expected Outcome:
# Vite outputs compiled production bundle in frontend/dist/ with zero TypeScript errors.
```
