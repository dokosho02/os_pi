set windows-shell := ["powershell.exe", "-NoLogo", "-NoProfile", "-Command"]

report_file := if os() == "windows" { env("TEMP", env("TMP", ".")) / "just-check-failed" } else { env("TMPDIR", "/tmp") / "just-check-failed" }

default:
    just --list

# Generic check: run the version command if the tool exists, otherwise record a failure without aborting
[windows]
_check tool cmd:
    @if (-not (Get-Command '{{ tool }}' -ErrorAction SilentlyContinue)) { \
        Write-Output '{{ tool }}: not installed'; \
        Add-Content -LiteralPath '{{ report_file }}' -Value '{{ tool }}'; \
    } else { \
        $global:LASTEXITCODE = 0; \
        try { \
            $output = @(& cmd.exe /d /s /c '{{ cmd }}' 2>&1); \
            $exitCode = $global:LASTEXITCODE; \
        } catch { \
            $output = @($_); \
            $exitCode = 1; \
        } \
        $output | ForEach-Object { \
            $text = if ($_ -is [System.Management.Automation.ErrorRecord]) { $_.Exception.Message } else { $_.ToString() }; \
            if ($text) { Write-Output ('{{ tool }}: ' + $text) } \
        }; \
        if ($exitCode -ne 0) { \
            Write-Output '{{ tool }}: found but failed to run'; \
            Add-Content -LiteralPath '{{ report_file }}' -Value '{{ tool }}'; \
        } \
    }; exit 0

[unix]
_check tool cmd:
    @if ! command -v {{ tool }} >/dev/null 2>&1; then \
        echo "{{ tool }}: not installed"; \
        echo "{{ tool }}" >> "{{ report_file }}"; \
    elif out=$({{ cmd }} 2>&1); then \
        printf '%s\n' "$out" | sed 's/^/{{ tool }}: /'; \
    else \
        printf '%s\n' "$out" | sed 's/^/{{ tool }}: /'; \
        echo "{{ tool }}: found but failed to run"; \
        echo "{{ tool }}" >> "{{ report_file }}"; \
    fi

# Clear the failure report from the previous run
[windows]
_reset:
    @Remove-Item -LiteralPath '{{ report_file }}' -Force -ErrorAction SilentlyContinue; exit 0

[unix]
_reset:
    @rm -f "{{ report_file }}"

check-cargo: (_check "cargo" "cargo version")
check-go: (_check "go" "go version")
check-java: (_check "java" "java -version")
check-kotlin: (_check "kotlin" "kotlin -version")
check-scala: (_check "scala" "scala -version")
check-clojure: (_check "clojure" "clojure --version")
check-uv: (_check "uv" "uv --version")
check-node: (_check "node" "node --version")
check-bun: (_check "bun" "bun --version")

# Check every tool, then print a summary of failures; exits 1 if any check failed
[windows]
check-all: _reset check-cargo check-go check-java check-kotlin check-scala check-clojure check-uv check-node check-bun
    @if (Test-Path -LiteralPath '{{ report_file }}') { \
        Write-Output ''; \
        Write-Output '==> Failed checks:'; \
        Get-Content -LiteralPath '{{ report_file }}'; \
        Remove-Item -LiteralPath '{{ report_file }}' -Force -ErrorAction SilentlyContinue; \
        exit 1; \
    } else { \
        Write-Output ''; \
        Write-Output '==> All checks passed'; \
        Remove-Item -LiteralPath '{{ report_file }}' -Force -ErrorAction SilentlyContinue; \
        exit 0; \
    }

[unix]
check-all: _reset check-cargo check-go check-java check-kotlin check-scala check-clojure check-uv check-node check-bun
    @if [ -s "{{ report_file }}" ]; then \
        echo; \
        echo "==> Failed checks:"; \
        cat "{{ report_file }}"; \
        rm -f "{{ report_file }}"; \
        exit 1; \
    else \
        echo; \
        echo "==> All checks passed"; \
        rm -f "{{ report_file }}"; \
    fi
