const assert = require("assert");
const crypto = require("crypto");
const {
  signAttestation,
  verifyAttestation,
} = require("./registry_attestor");

const { publicKey, privateKey } = crypto.generateKeyPairSync("ed25519");

const fields = {
  attestorKeyId: "3",
  registryEpoch: "1500",
  circuitId: "ruse_t2:v1",
  scopeHash: "1001",
  responseHash: "2002",
  attestationDigest: "3003",
};

const registry = {
  "3": { publicKey, validFrom: 1000, validTo: 2000 },
};

const signature = signAttestation(privateKey, fields);
assert.deepStrictEqual(verifyAttestation(registry, fields, signature), { ok: true });

assert.strictEqual(
  verifyAttestation({}, fields, signature).reason,
  "unknown_attestor",
);

assert.strictEqual(
  verifyAttestation({ "3": { publicKey, revokedAt: 1400 } }, fields, signature).reason,
  "revoked_attestor",
);

assert.strictEqual(
  verifyAttestation(registry, { ...fields, responseHash: "9999" }, signature).reason,
  "bad_signature",
);

assert.strictEqual(
  verifyAttestation({ "3": { publicKey, validFrom: 1600 } }, fields, signature).reason,
  "attestor_not_yet_valid",
);

assert.strictEqual(
  verifyAttestation({ "3": { publicKey, validTo: 1400 } }, fields, signature).reason,
  "attestor_expired",
);

console.log("Registry attestor tests passed: 6 cases.");
