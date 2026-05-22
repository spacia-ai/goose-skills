---
name: debugging-rust
description: Debug Rust compile errors, lifetime issues, and runtime panics. Cargo invocation patterns + idiomatic fixes.
extensions: []
requires: []
tools:
  - developer__shell
  - developer__text_editor
tags:
  - rust
  - debugging
  - compiler
  - standalone
min_goose_version: "1.33.0"
---

# Debugging Rust

Standalone skill — uses `developer__shell` to run `cargo` and
`developer__text_editor` to read source.

## Compile-error triage

`cargo check` first, `cargo build` only if check passes:

```
cargo check -p <crate> 2>&1 | head -60        # see errors
cargo clippy -p <crate> --all-targets -- -D warnings | tail -40
```

Read **the first error**. Subsequent ones often cascade — fixing the first
makes 5 others disappear.

## Common error patterns

| Error | First instinct |
|---|---|
| `cannot find type X` | `use` path missing. Check if X is re-exported. |
| `lifetime <'a>` mismatch | Try removing the explicit lifetime — often inference handles it. If a type owns a `String` instead of `&str`, that often fixes it. |
| `cannot move out of borrowed content` | `.clone()` or change function to take `&` instead of owned. |
| `the size for ... cannot be known at compile-time` | Wrap in `Box<>` or `Arc<>`. Trait objects need indirection. |
| `mismatched types` between `Result` variants | The error type of `?` doesn't match the function return. Add `From` impl or `.map_err()`. |
| `borrow may still be in use` | The borrow checker thinks you're using it after dropping. Often: split a mutable borrow into separate scopes with `{ ... }`. |

## Async-specific

| Error | Fix |
|---|---|
| `future cannot be sent between threads safely` | Something captured isn't `Send`. Often a `Rc` instead of `Arc`, or a `RefCell` instead of `Mutex`. |
| `cannot borrow ... as mutable because it is also borrowed as immutable` (in async) | The `.await` point splits the borrow. Drop the immutable borrow before awaiting. |
| `the trait Future ... is not implemented` | You probably forgot `.await` or wrapped the future in something that doesn't poll it. |

## Runtime panic triage

```
RUST_BACKTRACE=1 cargo run 2>&1 | tee /tmp/run.log
```

Then read backtrace from bottom (panic site) up to the first frame in your
code. Skip framework frames.

## When to suggest a refactor vs. a local fix

- One file, one function: local fix.
- Same error pattern in 5+ places: probably needs an abstraction.
- Borrow-checker is fighting you across multiple files: usually a shape problem,
  not a lifetime problem. Step back and ask what the type ownership graph
  should look like.

## Anti-patterns

- **Don't add `#[allow(...)]` to silence clippy.** Fix the warning or
  document specifically why the allow is correct.
- **Don't unwrap in library code.** Match or propagate.
- **Don't add lifetimes you don't need.** Most code doesn't need explicit
  lifetimes — let inference do its job.
