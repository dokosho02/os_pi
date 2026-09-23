report_file := env("TMPDIR", "/tmp") / "just-check-failed"

default:
    just --list

# Generic check: run the version command if the tool exists, otherwise record a failure without aborting
_check tool cmd:
    @if ! command -v {{tool}} >/dev/null 2>&1; then \
        echo "{{tool}}: not installed"; \
        echo "{{tool}}" >> "{{report_file}}"; \
    elif out=$({{cmd}} 2>&1); then \
        printf '%s\n' "$out" | sed 's/^/{{tool}}: /'; \
    else \
        printf '%s\n' "$out" | sed 's/^/{{tool}}: /'; \
        echo "{{tool}}: found but failed to run"; \
        echo "{{tool}}" >> "{{report_file}}"; \
    fi

# Clear the failure report from the previous run
_reset:
    @rm -f "{{report_file}}"

check-cargo:   (_check "cargo"   "cargo version")
check-go:      (_check "go"      "go version")
check-java:    (_check "java"    "java -version")
check-kotlin:  (_check "kotlin"  "kotlin -version")
check-scala:   (_check "scala"   "scala -version")
check-clojure: (_check "clojure" "clojure --version")
check-uv:      (_check "uv"      "uv --version")
check-node:    (_check "node"    "node --version")
check-bun:     (_check "bun"     "bun --version")

# Check every tool, then print a summary of failures; exits 1 if any check failed
check-all: _reset check-cargo check-go check-java check-kotlin check-scala check-clojure check-uv check-node check-bun
    @if [ -s "{{report_file}}" ]; then \
        echo; \
        echo "==> Failed checks:"; \
        cat "{{report_file}}"; \
        rm -f "{{report_file}}"; \
        exit 1; \
    else \
        echo; \
        echo "==> All checks passed"; \
        rm -f "{{report_file}}"; \
    fi
