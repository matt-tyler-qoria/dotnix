---
name: golang-repository-setup
description: Conventions for setting up Go repositories. Covers Nix flake for dependencies, direnv integration, gotestsum for tests, and just for task running. Use when initialising a new Go project or reviewing repository setup.
license: MIT
compatibility: opencode
---

# Go Repository Setup

This skill defines how Go repositories are set up. Follow these conventions when creating a new Go project or reviewing an existing one's tooling setup.

## Dependency Management — Nix Flakes

**Use Nix flakes to install all development dependencies.** Do NOT use `tools.go` or `go install` for developer tooling.

Every Go repository must have a `flake.nix` at the root that provides a dev shell with all required tools.

### Minimal flake.nix

```nix
{
  description = "Project description";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Shared packages used by both dev and CI
        commonPackages = with pkgs; [
          go
          golangci-lint
          gotestsum
          just
        ];
      in
      {
        devShells = {
          # Local development shell — includes editor tooling and convenience tools
          default = pkgs.mkShell {
            packages = commonPackages ++ (with pkgs; [
              # Editor / LSP tooling (not needed in CI)
              gopls

              # Add project-specific dev tools here
              # sqlc
              # protobuf
              # grpcurl
            ]);
          };

          # CI shell — minimal, only what's needed to build, test, and lint
          ci = pkgs.mkShell {
            packages = commonPackages ++ (with pkgs; [
              # Add CI-specific tools here
              # e.g. goreleaser, ko, docker CLI
            ]);
          };
        };
      }
    );
}
```

### Dev shell vs CI shell

The flake provides two dev shells:

- **`default`** — for local development. Includes editor tooling (gopls), convenience tools, and anything that makes development ergonomic. Activated by `use flake` in `.envrc`.
- **`ci`** — for CI environments. Minimal — only tools needed to build, test, and lint. No editor tooling. Used in CI pipelines:
  ```bash
  nix develop .#ci --command just test-ci
  nix develop .#ci --command just lint
  ```

Both shells share a `commonPackages` list so core tools (Go, golangci-lint, gotestsum, just) stay in sync. Tools that only make sense locally (gopls, grpcurl) go in `default` only. Tools that only make sense in CI (goreleaser, ko) go in `ci` only.

### Why NOT tools.go

The `tools.go` pattern (blank-importing CLI tools for `go install`) has problems:

- Pollutes `go.mod` with dependencies that are not part of the application
- Version conflicts between tool dependencies and application dependencies
- Requires `go install` step that may compile differently across machines
- Not reproducible — different Go versions or CGO settings produce different binaries

Nix provides pinned, reproducible, pre-built binaries. Use it.

### Adding dependencies

When a project needs a new development tool:

1. Add the package to `flake.nix` in the `packages` list
2. Run `direnv reload` or `nix develop` to pick it up
3. Commit the updated `flake.nix` and `flake.lock`

Do NOT add tools via `go install`, `brew install`, or manual downloads.

## direnv Integration

Every repository must have a `.envrc` file that activates the Nix dev shell automatically.

### .envrc

```bash
use flake
```

That's it. When a developer `cd`s into the project, direnv loads the Nix dev shell and all tools become available.

### Setup requirements

- `direnv` must be installed (managed via the system Nix configuration, not per-project)
- `.envrc` must be committed to the repository
- Add `.direnv/` to `.gitignore` (direnv caches the shell here)

### .gitignore entries

```
.direnv/
bin/
```

## Build Output

**All binaries must be built to the `bin/` directory** at the repository root. This directory is gitignored — compiled binaries must never be committed.

```bash
go build -o bin/ ./cmd/...
```

The `just build` recipe handles this by default. If the project has multiple binaries, they all go in `bin/`:

```bash
go build -o bin/api ./cmd/api
go build -o bin/worker ./cmd/worker
```

## Testing — gotestsum

**Use `gotestsum` instead of `go test` for running tests.** It provides better output formatting, JUnit XML reports for CI, and cleaner failure summaries.

### Basic usage

```bash
# Run all tests
gotestsum ./...

# With verbose output
gotestsum --format testdox ./...

# With JUnit output for CI
gotestsum --junitfile report.xml ./...

# Run specific package
gotestsum ./internal/api/...
```

### Integration tests

```bash
# Run integration tests (with build tag)
gotestsum -- -tags=integration ./...
```

### In CI

```bash
gotestsum --junitfile report.xml --format standard-verbose -- -race -coverprofile=coverage.out ./...
```

## Task Runner — just

**Use `just` instead of `make` for task running.** `just` is a command runner, not a build system — it does not pretend files are build targets and has cleaner syntax.

### justfile

Create a `justfile` (no extension) at the repository root:

```just
# Default recipe — list available tasks
default:
    @just --list

# Run all tests
test *args:
    gotestsum {{args}} ./...

# Run tests with race detection and coverage
test-ci:
    gotestsum --junitfile report.xml --format standard-verbose -- -race -coverprofile=coverage.out ./...

# Run linter
lint:
    golangci-lint run ./...

# Format code
fmt:
    gofumpt -w .

# Build the application
build:
    go build -o bin/ ./cmd/...

# Run the application
run *args:
    go run ./cmd/... {{args}}

# Tidy dependencies
tidy:
    go mod tidy

# Generate code (sqlc, protobuf, etc.)
generate:
    go generate ./...
```

### Conventions

- The `justfile` must be committed to the repository
- Use `gotestsum` in test recipes, not `go test`
- Use `*args` for recipes that need pass-through arguments
- Include a `default` recipe that lists available tasks
- Keep recipes focused — one task per recipe
- Add project-specific recipes as needed (database migrations, Docker builds, etc.)

### Why NOT make

- Makefiles conflate build targets with task running — `.PHONY` everywhere
- Make syntax is arcane (tab sensitivity, variable expansion, shell escaping)
- `just` has clearer syntax, built-in argument passing, and better error messages
- `just` doesn't try to check file timestamps or skip tasks — it always runs what you ask

## New Repository Checklist

When setting up a new Go repository, ensure all of these exist:

1. `flake.nix` — with `default` (dev) and `ci` shells sharing common packages; dev shell includes editor tooling, CI shell is minimal
2. `flake.lock` — committed, generated by `nix flake update`
3. `.envrc` — contains `use flake`
4. `.gitignore` — includes `.direnv/` and `bin/`
5. `justfile` — with at minimum `test`, `lint`, `fmt`, and `build` recipes
6. `go.mod` / `go.sum` — application dependencies only, no tooling
7. `.golangci.yml` — linter configuration (project-specific)

## Anti-Patterns

| Pattern | Problem | Use instead |
| --- | --- | --- |
| `tools.go` | Pollutes go.mod, not reproducible | Nix flake |
| `go install` for dev tools | Not pinned, not reproducible | Nix flake |
| `Makefile` | Build system masquerading as task runner | `justfile` |
| `go test` directly | Poor output, no JUnit reports | `gotestsum` |
| `brew install` for tools | Not reproducible, macOS only | Nix flake |
| Manual setup docs | Developers skip steps | `use flake` does it all |
