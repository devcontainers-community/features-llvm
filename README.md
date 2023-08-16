# LLVM Dev Container Feature

🏭 Installs the LLVM toolchain

## Usage

```jsonc
// devcontainer.json
{
  "features": {
    "ghcr.io/octocat/features/llvm": {}
  }
}
```

❓ Don't know what this ☝ means? Check out [this VS Code blog post].

### Options

- **`version`:** Pin to a specific LLVM toolchain version. Can also be `latest`
  to use the most recent version. The default is `latest`.

<!-- prettier-ignore -->
[this vs code blog post]: https://code.visualstudio.com/blogs/2022/09/15/dev-container-features
