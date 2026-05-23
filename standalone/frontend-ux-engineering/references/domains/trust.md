# Domain — trust (auth, privacy, consent)

Passkeys and WebAuthn for authentication; layered notices and granular consent for privacy. Trust UX is a first-order design discipline, not a legal afterthought.

## Why trust UX is a first-order discipline

If your auth flow is brittle, your CWV doesn't matter — users can't get in. If your privacy notice is opaque, your accessibility doesn't matter — users don't know what you're doing with their data. Trust UX is upstream of every other UX concern; bad trust experiences erase the value of everything downstream.

The 2026 baseline:

- **Authentication:** passkeys are the default; passwords with password-manager support are an acceptable fallback; passwords-without-password-managers are obsolete.
- **Privacy:** layered notices, granular consent, easy withdrawal, just-in-time disclosure at the point of collection.

## Authentication

### Passkeys / WebAuthn

A passkey is a public/private keypair stored on the user's device (or synced via a credential manager like iCloud Keychain, 1Password, Google Password Manager, Bitwarden, Dashlane). The private key never leaves the device or the credential manager. Authentication is a challenge-response signed with the private key.

Why passkeys win:

- **Phishing-resistant.** A passkey is bound to the origin (e.g., `example.com`). It will not authenticate to a look-alike domain. Most phishing attacks become impossible.
- **No shared secret to steal.** Server breaches of password hashes become non-events because there's nothing to steal.
- **Faster than passwords.** No typing; biometric or PIN unlock in < 1 second.
- **Better UX.** No "forgot password" flow for the common case.
- **Standardized.** WebAuthn is a W3C recommendation. Apple, Google, and Microsoft are all-in.

Implementation requirements:

- **Visible passkey management.** Account settings show created passkeys with friendly names ("MacBook Pro", "iPhone 15") and the ability to remove them. Without this, users can't recover when a device is lost.
- **Multiple passkeys allowed per account.** Users have multiple devices. Don't force one-passkey-per-account.
- **Recovery flow.** What happens if a user loses their only device? Common patterns: recovery email with a one-time code; recovery passkey on a separate device; recovery codes printed at registration; SMS as last-resort fallback (note: phone-number changes are common and SMS is phishable, so SMS alone is weak).
- **Conditional UI** for sign-in. The browser's password manager UI surfaces stored passkeys for the current origin during the sign-in form fill. The form must support it (`autocomplete="username webauthn"`).
- **Fallback to password.** While the world transitions, a passkey-or-password sign-in is fine. Passkey-only is acceptable when your audience can manage it.
- **Account creation supports passkey-from-the-start.** Don't make users create a password and then "upgrade" to a passkey; let them create a passkey at registration.

### NIST AAL2 phishing-resistant requirement

NIST SP 800-63B (Digital Identity Guidelines) defines authentication assurance levels (AAL). AAL2 — required for moderate-impact federal applications and increasingly required by regulated industries — now requires at least one phishing-resistant authentication option. Passkeys / WebAuthn are the dominant phishing-resistant option. Passwords + TOTP / SMS are *not* phishing-resistant.

If your product serves regulated users (government, healthcare, finance), passkeys are not optional.

### Common authentication anti-patterns

- **Password-only with no MFA.** Below modern baseline.
- **SMS-only MFA.** Phishable, sim-swappable. Acceptable as last-resort fallback only.
- **Passkey created, no management UI.** User can't see what they created, can't remove on device loss.
- **One passkey per account.** User can't add a second device.
- **Sign-in form without passkey support.** `autocomplete="username webauthn"` missing; conditional UI doesn't fire.
- **Recovery flow that dead-ends.** "Email a recovery link" to an email account that requires the lost device to access.
- **Forced password rotation every 90 days.** NIST explicitly deprecated this. Users pick weaker passwords or write them down.

## Privacy

### Layered notices

A layered notice has three levels:

1. **First layer (in-line, brief).** At the point of collection. One sentence + link. "Your email is used to send you order updates and to recover your account. [Learn more]"
2. **Second layer (expanded).** A medium-detail summary, often modal or hover. Covers purposes, retention, third parties.
3. **Third layer (full policy).** The legal document. Linked but not the only available information.

Why layered: users don't read full privacy policies. Users *do* read a sentence at the moment they're filling a field. Place the disclosure where the decision happens.

### Granular consent

Where the regime requires consent (GDPR, certain US state laws, sectoral rules), consent should be:

- **Specific.** Per-purpose. "Marketing emails" and "service emails" are different.
- **Informed.** User knows what they're consenting to (see layered notices).
- **Affirmative.** Pre-ticked boxes are not consent.
- **Withdrawable.** Withdrawal is as easy as giving consent. A one-click toggle in account settings, not a six-step "delete my account" flow.

### Just-in-time disclosure

Privacy information appears at the moment of decision, not buried in a settings page or a footer-linked policy.

- At the point of camera/microphone access: "We use your camera to scan barcodes. We don't record or store the camera feed."
- At the point of location: "We use your location to show stores near you. Your location is not stored."
- At the point of contact upload: "We use your contacts to find friends already on the service. Contacts are sent to our server but not stored."
- At the point of file upload: "Files you upload are processed and stored on our servers. They are accessible to you and to anyone you share with."

This pattern dramatically reduces consent fatigue and improves comprehension.

### Account-level privacy controls

Users should be able to:

- See what data the product has on them.
- Export it (data portability).
- Delete it (right to erasure, where applicable).
- Modify granular consent toggles.
- See and revoke connected third-party integrations.

Most products underbuild this. The minimum is a discoverable "Privacy" section in account settings with toggles for each granular consent and a "Download my data" / "Delete my account" path.

### Consent banners

Cookie banners are the most-loathed UX of the web era. The reasons:

- They appear before content paints (CLS-and-irritation factory).
- They deceive ("Accept all" prominent, "Reject all" buried).
- They don't actually honor consent (consent banner clicked, tracking happens anyway).
- They reappear on every visit because consent isn't stored.
- They block content access, violating the "withdrawable as easily as given" principle.

If you must have one:

- Reserve space for it server-rendered or in initial HTML so it doesn't cause CLS.
- "Accept all" and "Reject all" with equal visual weight.
- Persist consent across sessions so users don't have to keep dismissing.
- Honor the consent — if user rejects, no tracking fires.
- A persistent way to revisit and change settings (account settings or footer link).

If you can avoid one (e.g., by not using third-party tracking, or by using server-side analytics that don't trigger consent requirements), do.

## Common trust UX anti-patterns

- **Trusting tracking pixels with consent management.** Tracking fires on page load before consent banner appears. Audit your network panel.
- **"Required cookies" includes analytics.** Analytics is not required for the user; it's required for you. Don't lie about it.
- **Privacy policy in legal jargon only.** A 4000-word document with "data subject" and "processing purpose" comprehensible to lawyers, not to users. Layered notices solve this.
- **Account deletion that takes 30 days "for security."** Real deletion or anonymization is implementable in seconds. Long delays exist for retention, not security.
- **Password requirements that make passwords weaker.** "Must contain a special character, a number, an uppercase, a lowercase, between 8 and 12 characters" → users pick `Password1!`. NIST recommends long passwords with no composition rules.
- **Re-prompting for password to "confirm".** If the user is signed in, you have authentication. Re-prompting just trains users that prompts are normal — perfect for phishing.
- **Sending the password to the server in cleartext (over HTTPS or otherwise).** Use a salted hash function on the server; never log the password.
- **OAuth scopes that demand "read all your data" for trivial integration.** Request the minimum scope.

## Bibliography

- "Web Authentication: An API for accessing Public Key Credentials" — W3C (WebAuthn Level 3).
- "Passkeys" — passkeys.dev (FIDO Alliance + Apple + Google + Microsoft developer docs).
- "Digital Identity Guidelines" — NIST SP 800-63 (revisions 3 and 4).
- "General Data Protection Regulation" — EU.
- "Anatomy of a Privacy Notice" — UK Information Commissioner's Office (ICO).
- "Layered Privacy Notices" — Article 29 Working Party guidance.
- "Sign-In with a Passkey" — Apple Developer documentation.
- "Passkey Implementation in Chrome" — web.dev.
