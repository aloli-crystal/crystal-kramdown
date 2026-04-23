# my-library

[![CI](https://example.com/badge.svg)](https://example.com/ci)

A **small** library for doing *things*.

## Installation

Add the following to your `shard.yml`:

```yaml
dependencies:
  my-library:
    github: acme/my-library
    version: "~> 1.0"
```

Then run:

```
shards install
```

## Usage

```crystal
require "my-library"

MyLibrary.do_thing("hello")
# => "HELLO"
```

## Features

- Zero dependencies
- Pure Crystal
- MIT licensed

## Supported platforms

| OS      | Arch       | Status      |
|---------|------------|-------------|
| Linux   | x86_64     | Supported   |
| Linux   | aarch64    | Supported   |
| macOS   | arm64      | Supported   |
| Windows | x86_64     | Best-effort |

## Links

- [Documentation](https://example.com/docs)
- [Issue tracker](https://example.com/issues)

> **Note**: this is a README-shaped fixture used by integration tests.

---

## License

Released under the [MIT license](LICENSE).
