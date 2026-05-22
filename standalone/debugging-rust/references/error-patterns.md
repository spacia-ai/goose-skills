# Rust error patterns

Lazy-load when you hit a compile error or panic and need the canonical
fix. Common rustc / clippy errors mapped to idiomatic fixes.

## Compile errors

### E0382 — "borrow of moved value"

Cause: used a value after passing it by value (move) to a function /
match arm / closure.

Fixes, in preference order:

1. **Borrow instead of move** — pass `&x` instead of `x` if the callee
   only reads.
2. **Clone if cheap** — `x.clone()` if `x: T: Clone` and the clone is
   small (`String`, `Vec` of primitives, `Arc<T>`).
3. **Restructure** — if you need both halves, split the work so each
   half gets ownership of its piece.

Anti-fix: wrapping in `Arc<Mutex<T>>` just to dodge the borrow checker.
That's a runtime cost to avoid thinking about ownership.

### E0507 — "cannot move out of borrowed content"

Cause: tried to move a value out of an `&T` (e.g. matching a `Vec`
behind a borrow and binding the element by value).

Fix: bind by reference (`&x`) in the pattern, or call `.clone()` /
`.to_owned()` if you need ownership.

### E0596 — "cannot borrow as mutable"

Cause: holding an `&T`, trying to mutate.

Fixes:

1. Change the binding to `let mut x = ...` if you own it.
2. Change the function parameter to `&mut T` if it's a parameter.
3. If neither, you're holding an immutable reference to something
   someone else owns — and you shouldn't mutate it from here.

### Lifetime errors (`'_`, `'a`, "does not live long enough")

90% of the time, the fix is **not** to add explicit lifetime
annotations. The fix is to restructure so the borrow doesn't outlive
the borrowed value. Common patterns:

- **Returning a reference to a local** — return the owned value instead
  (`String` not `&str`).
- **Storing a reference in a struct** — store the owned value, or use
  `Rc<T>` / `Arc<T>`.
- **Closure captures a reference** — use `move ||` and clone what the
  closure needs.

Add explicit `'a` only when you really mean "this reference lives at
least as long as that other reference."

### `Future is not Send`

Cause: holding a non-`Send` value (e.g. `std::sync::MutexGuard`,
`Rc<T>`) across an `.await`.

Fix: drop the guard before the `.await`, or use a `.await`-aware lock
(`tokio::sync::Mutex`).

```rust
// Bad:
let guard = mutex.lock().unwrap();  // std::sync::Mutex
do_something().await;               // guard held across await
guard.update();

// Good:
{
    let mut guard = mutex.lock().unwrap();
    guard.update();
}
do_something().await;
```

## Runtime panics

### "called `Option::unwrap()` on a `None` value"

The fix is almost never to add a `match` to handle the `None`. The fix
is usually:

- Find the upstream caller that's passing `None` and figure out why.
- Or: change the type to `Result<T, ConcreteError>` so the error
  carries context.

`unwrap()` in library code is a bug. In `fn main()` it's acceptable
*if* the invariant is documented.

### "thread 'main' panicked at ... index out of bounds"

`vec[i]` panics; `vec.get(i)` returns `Option<&T>`. Prefer `.get` when
the index might be invalid, and handle the `None`.

## Cargo / build issues

### "could not compile <crate>" with no obvious error

Run:

```
cargo clean -p <crate>
cargo check -p <crate> 2>&1 | head -100
```

Stale `target/` artifacts after a rustc upgrade or a `git checkout`
between branches with different deps cause this often. `cargo clean`
on the specific crate is cheaper than a full clean.

### Slow incremental builds

Check `target/` size. If >10 GB, `cargo clean` and rebuild — incremental
state gets corrupted over time.

## When to escalate

If 15 minutes of fix-attempts haven't moved the error needle, stop
iterating. Read the rustc error in full (it usually points at the
right line + suggests a fix), check `cargo check`'s output for a
prior error you missed (rustc cascades), and re-read the surrounding
code with the actual ownership rules in mind.
