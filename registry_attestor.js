const crypto = require("crypto");

function canonicalJson(value) {
  if (Array.isArray(value)) return `[${value.map(canonicalJson).join(",")}]`;
  if (value && typeof value === "object") {
    return `{${Object.keys(value).sort().map((key) => `${JSON.stringify(key)}:${canonicalJson(value[key])}`).join(",")}}`;
  }
  return JSON.stringify(value);
}

function attestationPayload(fields) {
  return {
    attestationDigest: String(fields.attestationDigest),
    attestorKeyId: String(fields.attestorKeyId),
    circuitId: String(fields.circuitId),
    registryEpoch: String(fields.registryEpoch),
    responseHash: String(fields.responseHash),
    scopeHash: String(fields.scopeHash),
  };
}

function signAttestation(privateKey, fields) {
  return crypto.sign(null, Buffer.from(canonicalJson(attestationPayload(fields))), privateKey);
}

function verifyAttestation(registry, fields, signature) {
  const entry = registry[String(fields.attestorKeyId)];
  if (!entry) return { ok: false, reason: "unknown_attestor" };
  const epoch = Number(fields.registryEpoch);
  if (entry.revokedAt !== undefined && epoch >= Number(entry.revokedAt)) {
    return { ok: false, reason: "revoked_attestor" };
  }
  if (entry.validFrom !== undefined && epoch < Number(entry.validFrom)) {
    return { ok: false, reason: "attestor_not_yet_valid" };
  }
  if (entry.validTo !== undefined && epoch > Number(entry.validTo)) {
    return { ok: false, reason: "attestor_expired" };
  }
  const payload = Buffer.from(canonicalJson(attestationPayload(fields)));
  const ok = crypto.verify(null, payload, entry.publicKey, signature);
  return ok ? { ok: true } : { ok: false, reason: "bad_signature" };
}

module.exports = {
  attestationPayload,
  canonicalJson,
  signAttestation,
  verifyAttestation,
};
