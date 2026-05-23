# Checklist — authentication with passkeys

Passkey UX is auth UX in 2026. This checklist is the minimum bar for shipping passkey-supporting auth.

## Registration (creating a passkey)

- [ ] **Passkey is the default option** on the create-account flow, not buried behind "advanced security."
- [ ] **Passkey creation works at registration.** Don't force users to create a password, then "upgrade" to a passkey.
- [ ] **`navigator.credentials.create()` is called with proper parameters**:
  - `publicKey.rp.id` is the registrable domain (no `https://`, no path, no port).
  - `publicKey.user.id` is a stable, opaque ID (not the email or username — those can change).
  - `publicKey.user.displayName` is a human-readable name.
  - `publicKey.authenticatorSelection.residentKey: "preferred"` (so the passkey is discoverable for sign-in).
  - `publicKey.authenticatorSelection.userVerification: "preferred"`.
  - `publicKey.pubKeyCredParams` includes algorithms `-7` (ES256) and `-257` (RS256) at minimum.
- [ ] **Friendly name asked or auto-generated.** "MacBook Pro", "Pixel 8", "1Password" — so users can recognize the passkey in management UI.
- [ ] **Server stores credentialId, public key, sign count, transports, and creation timestamp.**
- [ ] **Multiple passkeys per account allowed.** Users have multiple devices.

## Sign-in

- [ ] **Sign-in form supports conditional UI.** `<input autocomplete="username webauthn">`. The browser surfaces matching passkeys when the field is focused.
- [ ] **`navigator.credentials.get()` runs in conditional UI mode** (`mediation: "conditional"`) on page load.
- [ ] **Fallback to password is available** while the world transitions. Passkey-only is fine for products whose audience can manage it.
- [ ] **Sign-in does not require username if a discoverable passkey exists.** Browser prompts for the passkey directly.
- [ ] **Server verifies the assertion**: signature, challenge, origin, RP ID, sign count.
- [ ] **Sign count is monotonically increasing.** If it decreases or stays the same after multiple sign-ins, treat as a possible cloned credential — flag for review.

## Account management

- [ ] **Visible passkey list in account settings.** Each entry shows: friendly name, creation date, last-used date.
- [ ] **User can rename a passkey.**
- [ ] **User can remove a passkey** (with a confirmation step).
- [ ] **User cannot remove the only remaining authenticator** without setting up a fallback (recovery email, backup passkey).
- [ ] **Add-passkey flow is discoverable** in account settings, not buried.
- [ ] **Cross-device passkey creation is supported** where the platform supports it (e.g., Mac creating a passkey on a phone via QR code).

## Recovery

- [ ] **Recovery flow exists for users who lose their only passkey.** No dead ends.
- [ ] **Recovery options include at least one phishing-resistant path** (e.g., second passkey on a backup device, recovery codes printed at registration). SMS-only is not phishing-resistant.
- [ ] **Recovery flow is rate-limited and monitored** (suspicious recovery attempts trigger account holds, not silent succeeds).
- [ ] **Recovery emails / codes have short validity windows** (e.g., 15 minutes for one-time codes).
- [ ] **Successful recovery prompts the user to add a new passkey** before completing.

## Security and edge cases

- [ ] **Origin and RP ID validation on every assertion.** Reject any assertion not from the expected origin.
- [ ] **Challenge is unique per attempt** and stored server-side; reject reused challenges.
- [ ] **HTTPS only.** WebAuthn requires it.
- [ ] **No fallback that downgrades phishing resistance** without user awareness. (E.g., if a user signs in with a passkey, don't silently fall back to SMS-only on retry.)
- [ ] **Suspicious activity is surfaced.** New device, unfamiliar location, repeated failures — notify the user via a parallel channel.

## Compliance

- [ ] **AAL2 phishing-resistant requirement met** for any user that needs it (regulated industries — government, healthcare, finance). Passkeys satisfy AAL2 phishing-resistant; password + TOTP / SMS does not.
- [ ] **Privacy notice covers authentication data**: what's stored, how long, with whom shared.
- [ ] **Data export includes authentication audit log** if required by jurisdiction.

## UX polish

- [ ] **Friendly empty state** for users with no passkeys yet — clear "Add a passkey" CTA in account settings.
- [ ] **Error messages explain what to do.** "Your passkey couldn't be used. Try again, or add a new passkey." Not "Authentication failed (E_INVALID_AUTHENTICATOR_RESPONSE)."
- [ ] **Loading state during sign-in** (passkey verification can take 1-2 seconds on some devices).
- [ ] **Clear language.** Use "passkey", not "FIDO credential" or "platform authenticator." Users don't know those terms.

## Common passkey UX anti-patterns

- **Passkey created but never managed.** No visible list, no remove option. Lost device = locked-out user.
- **One passkey per account.** Can't add a second device.
- **Passkey-or-nothing without recovery.** Lost device = unrecoverable account.
- **Conditional UI not enabled.** Users have a passkey but the sign-in form doesn't surface it; they fall back to password.
- **`autocomplete="username"`** without `webauthn` — passkey conditional UI doesn't fire.
- **SMS as the only fallback.** Phishable, sim-swappable.
- **"Are you sure?" on every sign-in.** Trains users to click through prompts; defeats the point.
- **Passkey creation buried in advanced settings.** Adoption stays low.
- **Different passkey terminology in different parts of the product.** "Security keys", "passkeys", "platform authenticators" — pick one user-facing term.

## Bibliography

- "Web Authentication: An API for accessing Public Key Credentials" — W3C (WebAuthn Level 3).
- passkeys.dev — FIDO Alliance + Apple + Google + Microsoft developer reference.
- NIST SP 800-63B — Digital Identity Guidelines.
- Apple Developer documentation: "Sign in with a passkey".
- Google: "Passkey Implementation in Chrome" — web.dev.
