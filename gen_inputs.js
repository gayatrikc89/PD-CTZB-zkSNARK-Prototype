const fs = require("fs");
const path = require("path");

async function buildTreePath(poseidon, leaf, depth) {
  const F = poseidon.F;
  const zeros = [0n];
  for (let i = 0; i < depth; i++) {
    zeros.push(F.toObject(poseidon([zeros[i], zeros[i]])));
  }
  const pathElements = [];
  const pathIndices = [];
  let current = leaf;
  for (let i = 0; i < depth; i++) {
    pathElements.push(zeros[i].toString());
    pathIndices.push("0");
    current = F.toObject(poseidon([current, zeros[i]]));
  }
  return { root: current.toString(), pathElements, pathIndices };
}

async function emptyTree(poseidon, depth) {
  const F = poseidon.F;
  const zeros = [0n];
  for (let i = 0; i < depth; i++) {
    zeros.push(F.toObject(poseidon([zeros[i], zeros[i]])));
  }
  return {
    root: zeros[depth].toString(),
    pathElements: zeros.slice(0, depth).map((x) => x.toString()),
  };
}

(async () => {
  fs.mkdirSync(path.join(__dirname, "build"), { recursive: true });
  const { buildPoseidon } = await import("circomlibjs");
  const poseidon = await buildPoseidon();
  const F = poseidon.F;
  const dec = (x) => x.toString();
  const hash = (values) => F.toObject(poseidon(values));

  const token = {
    tau: 12345678n,
    purpose: 7n,
    scope: 100n,
    expiry: 2000n,
    cap: 5n,
    freq: 1n,
    accessType: 2n,
    incentive: 0n,
    payloadRef: 999n,
  };
  const assetId = 42n;
  const epoch = 1500n;
  const allowedPurposes = [1n, 3n, 5n, 7n, 11n, 13n, 17n, 19n];
  const policyHash = hash([assetId]);
  const skG = 11111n;
  const skOwner = 33333n;
  const skOwnerNew = 55555n;
  const sNf = 44444n;
  const pkG = hash([skG]);
  const pkOwner = hash([skOwner]);
  const pkOwnerNew = hash([skOwnerNew]);
  const nfKeyHash = hash([sNf]);
  const r = 987654321n;
  const rNew = 1234567890n;
  const attr = hash([
    token.purpose, token.scope, token.expiry, token.cap,
    token.freq, token.accessType, token.incentive, token.payloadRef,
  ]);
  const base = {
    ...Object.fromEntries(Object.entries(token).map(([k, v]) => [k, dec(v)])),
    policyHash: dec(policyHash),
    pkG: dec(pkG),
    pkOwner: dec(pkOwner),
    nfKeyHash: dec(nfKeyHash),
    r: dec(r),
  };
  const publicBase = {
    assetId: dec(assetId),
    epoch: dec(epoch),
    allowedPurposes: allowedPurposes.map(dec),
  };
  const commitment = (owner, stage, randomness) =>
    hash([token.tau, attr, policyHash, pkG, owner, nfKeyHash, stage, randomness]);
  const write = (name, value) =>
    fs.writeFileSync(path.join(__dirname, "build", `input_${name}.json`), JSON.stringify(value, null, 2));

  write("rcreate", {
    cm: dec(commitment(pkOwner, 2n, r)),
    ...publicBase,
    ...base,
  });

  const fromStage = 2n;
  const toStage = 3n;
  const edge = 8n * fromStage + toStage;
  const oldCm = commitment(pkOwner, fromStage, r);
  const newCm = commitment(pkOwnerNew, toStage, rNew);
  const oldTree = await buildTreePath(poseidon, oldCm, 32);
  write("rxfer_t2", {
    nfOld: dec(hash([skOwner, token.tau, edge])),
    cmNew: dec(newCm),
    cmTreeRoot: oldTree.root,
    edge: dec(edge),
    ...Object.fromEntries(Object.entries(token).map(([k, v]) => [k, dec(v)])),
    policyHash: dec(policyHash),
    pkG: dec(pkG),
    nfKeyHash: dec(nfKeyHash),
    rOld: dec(r),
    fromStage: dec(fromStage),
    skOwnerOld: dec(skOwner),
    cmPath: oldTree.pathElements,
    cmIdx: oldTree.pathIndices,
    rNew: dec(rNew),
    toStage: dec(toStage),
    pkOwnerNew: dec(pkOwnerNew),
  });

  const valCm = commitment(pkOwner, 4n, r);
  write("rval_t1", {
    cm: dec(valCm),
    tau: dec(token.tau),
    ...publicBase,
    ...base,
    skOwner: dec(skOwner),
  });

  const valTree = await buildTreePath(poseidon, valCm, 32);
  const emptyNf = await emptyTree(poseidon, 128);
  write("rval_t2", {
    cmTreeRoot: valTree.root,
    nfSetRoot: emptyNf.root,
    ...publicBase,
    ...base,
    skOwner: dec(skOwner),
    sNf: dec(sNf),
    cmPath: valTree.pathElements,
    cmIdx: valTree.pathIndices,
    nfPath: emptyNf.pathElements,
  });

  const buyerCm = commitment(pkOwnerNew, 6n, rNew);
  const requestI = 0n;
  const scopeHash = hash([token.scope, token.purpose, token.expiry, token.accessType]);
  const responseHash = hash([998877n]);
  const attestorKeyId = 3n;
  const attestationDigest = hash([attestorKeyId, scopeHash, responseHash]);
  const auditRandomness = 7777n;
  const auditPayload = hash([assetId, epoch, pkG, token.purpose]);
  const auditCommitment = hash([auditRandomness, auditPayload]);
  const useCommon = {
    epoch: dec(epoch),
    assetId: dec(assetId),
    scopeHash: dec(scopeHash),
    responseHash: dec(responseHash),
    attestorKeyId: dec(attestorKeyId),
    attestationDigest: dec(attestationDigest),
    auditCommitment: dec(auditCommitment),
    allowedPurposes: allowedPurposes.map(dec),
    ...Object.fromEntries(Object.entries(token).map(([k, v]) => [k, dec(v)])),
    policyHash: dec(policyHash),
    pkG: dec(pkG),
    pkOwner: dec(pkOwnerNew),
    nfKeyHash: dec(nfKeyHash),
    r: dec(rNew),
    skOwner: dec(skOwnerNew),
    requestI: dec(requestI),
    auditRandomness: dec(auditRandomness),
  };
  write("ruse_t1", {
    cm: dec(buyerCm),
    tau: dec(token.tau),
    ...useCommon,
  });

  const useTree = await buildTreePath(poseidon, buyerCm, 32);
  write("ruse_t2", {
    nfUse: dec(hash([sNf, token.tau, requestI, 1n])),
    cmTreeRoot: useTree.root,
    nfSetRoot: emptyNf.root,
    ...useCommon,
    sNf: dec(sNf),
    cmPath: useTree.pathElements,
    cmIdx: useTree.pathIndices,
    nfPath: emptyNf.pathElements,
  });

  console.log("Generated six valid input fixtures.");
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
