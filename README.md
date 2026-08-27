# swift-tls

`TLS` is the engine-neutral TLS session and peer-policy surface for the Swift Compositions ecosystem.

`TLS.Configuration` carries the selected DNS query, DNS hostname, and `TLS.PeerPolicy`. An engine must use that hostname for both handshake identity and peer authentication, then return a `TLS.Session`. The session is the only transport handed to HTTP and PostgreSQL providers: async read, write, and close.

The `TLS Apple Engine`, `TLS OpenSSL Engine`, and `TLS SChannel Engine` products are leaves. Each exposes an injected `TLS.Engine.Witness` that consumes a `Sockets.TCP.Connection`, authenticates the configured peer, and produces the session. They deliberately do not add cryptography, provider policy, HTTP policy, pooling, Foundation, or platform imports to the core target.

## Current engine blockers

Apple needs an owned Security.framework binding target; OpenSSL needs an owned module target and link contract; SChannel needs an owned WinSDK binding target. Until those targets exist, each leaf exposes the exact injected backend witness rather than fabricating a cryptographic implementation.

## Verification status

This initial branch is intentionally **UNVERIFIED**. TX-N4 prohibits build, resolve, test, CI dispatch, and compiler-driven repair in this change.
