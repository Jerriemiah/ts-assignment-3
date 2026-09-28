#!/usr/bin/env bash
#!/usr/bin/env bash
set -u

PASS=0
FAIL=0

pass() {
    echo "PASS: $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "FAIL: $1"
    FAIL=$((FAIL + 1))
}

echo "======================================"
echo "Assignment 3 - Lint Test"
echo "Files and Bash Syntax Validation"
echo "======================================"
echo


# Checking for Required files
for f in README.md app/app.sh scripts/lint.sh scripts/build.sh tests/test.sh Dockerfile compose.yaml .dockerignore .github/workflows/ci.yml; do
    [[ -f "$f" ]] && pass "Required file exists: $f" || fail "Missing required file: $f"
done

# Bash syntax checks
for f in app/*.sh scripts/*.sh tests/*.sh; do
    [[ -f "$f" ]] || continue
    bash -n "$f" > /dev/null 2>&1 && pass "Bash syntax: $f" || fail "Bash syntax error: $f"
done

# Executable checks
for f in app/app.sh scripts/lint.sh scripts/build.sh tests/test.sh; do
    [[ -x "$f" ]] && pass "Executable: $f" || fail "Not executable: $f"
done