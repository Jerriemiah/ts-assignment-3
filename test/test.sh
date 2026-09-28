#!/usr/bin/env bash
set -u

IMAGE="diagnostic-tool"
FAILED=0
THRESHOLD=10

# Optionally build the image
  # Only build if the image doesn't exist
if ! docker images --format "{{.Repository}}" | grep -q "^${IMAGE}$"; then
    docker build -t "$IMAGE" .
fi


# ---------- Positive tests ----------

# 1. help command works (exit 0)
if docker run --rm "$IMAGE" help >/dev/null 2>&1; then
    echo "PASS: help command succeeds"
else
    echo "FAIL: help command should succeed"
    FAILED=1
fi

# 2. system command works (exit 0)
if docker run --rm "$IMAGE" system >/dev/null 2>&1; then
    echo "PASS: system command succeeds"
else
    echo "FAIL: system command should succeed"
    FAILED=1
fi

# 3. disk command works (exit 0)
if docker run --rm "$IMAGE" disk "$THRESHOLD" >/dev/null 2>&1; then
    echo "PASS: disk command succeeds"
else
    echo "FAIL: disk command should succeed"
    FAILED=1
fi

# 4. network with valid host works (exit 0 or 1 depending on reachability)
# Usually you just ensure it doesn't exit 2 (invalid input).
docker run --rm "$IMAGE" network google.com >/dev/null 2>&1
rc=$?
if [[ "$rc" -ne 2 ]]; then
    echo "PASS: network google.com does not treat input as invalid"
else
    echo "FAIL: network google.com should not exit with code 2"
    FAILED=1
fi

# Valid host for check-host
docker run --rm "$IMAGE" network localhost >/dev/null 2>&1
rc=$?
if [[ "$rc" -ne 2 ]]; then
    echo "PASS: network localhost does not treat input as invalid"
else
    echo "FAIL: network localhost should not exit with code 2"
    FAILED=1
fi

# ---------- Negative / invalid-input tests ----------

# 5. Invalid command must fail with non-zero (typically 2)
docker run --rm "$IMAGE" invalid-command >/dev/null 2>&1
rc=$?
if [[ "$rc" -ne 0 ]]; then
    echo "PASS: invalid command returns non-zero"
else
    echo "FAIL: invalid command should return non-zero"
    FAILED=1
fi

# 6. network without host should be invalid (exit 2)
docker run --rm "$IMAGE" network >/dev/null 2>&1
rc=$?
if [[ "$rc" -eq 2 ]]; then
    echo "PASS: network without host exits with code 2"
else
    echo "FAIL: network without host should exit with code 2"
    FAILED=1
fi

# 7. disk with invalid threshold (if you implemented thresholds)
docker run --rm "$IMAGE" disk abc >/dev/null 2>&1
rc=$?
if [[ "$rc" -eq 2 ]]; then
    echo "PASS: disk with invalid threshold exits with code 2"
else
    echo "FAIL: disk with invalid threshold should exit with code 2"
    FAILED=1
fi

# ---------- Summary ----------
echo
if [[ "$FAILED" -eq 0 ]]; then
    echo "All tests passed."
    exit 0
else
    echo "Some tests failed."
    exit 1
fi