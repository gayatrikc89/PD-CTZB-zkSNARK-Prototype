# PD-CTZB zk-SNARK Prototype

This directory contains the six Circom relations measured in the paper:
creation, Tier-2 transfer, Tier-1/Tier-2 validation, and Tier-1/Tier-2 use.

## Protocol choices

- Commitments bind separate giver, current-owner, and nullifier-key identities.
- Transfer circuits enforce the allowed lifecycle edges.
- Tier-2 nullifier non-membership uses a 128-level sparse Merkle path.
- Giver, Custodian, and attestor signatures are verified outside Groth16 over
  digests that the circuits bind.
- `registry_attestor.js` implements the registry-side accredited-attestor
  signature check with key-version and revocation checks.
- The prototype audit object is a Poseidon commitment. It is not encryption.
- The use counter is private witness data.

## Run

```powershell
pnpm install
pnpm compile
pnpm fixtures
pnpm test
pnpm benchmark
```

`compile.js` copies circuit sources into the ignored build directory before
invoking the WASM Circom compiler. This avoids a Windows path limitation in
the compiler package.

## Measured results

Circom 2.2.2 and Groth16 over BN254 on an AMD Ryzen 7 6800H:

| Relation | Constraints | Median prove | Median verify |
|---|---:|---:|---:|
| R_create | 2,826 | 166.6 ms | 8.36 ms |
| R_xfer Tier 2 | 21,198 | 660.3 ms | 9.35 ms |
| R_val Tier 1 | 3,241 | 161.1 ms | 9.46 ms |
| R_val Tier 2 | 88,131 | 2,079.6 ms | 7.66 ms |
| R_use Tier 1 | 5,855 | 271.3 ms | 6.55 ms |
| R_use Tier 2 | 90,876 | 2,095.6 ms | 6.17 ms |

The test suite accepts all six valid witness fixtures, rejects mutations for an
illegal transfer, wrong owner key, wrong nullifier secret, scope mismatch, and
use-cap overflow, and checks valid, unknown, revoked, stale, expired, and
mutated attestor signatures.
