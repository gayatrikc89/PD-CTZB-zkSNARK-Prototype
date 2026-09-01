(async () => {
  const { buildPoseidon } = await import("circomlibjs");

  const poseidon = await buildPoseidon();
  const F = poseidon.F;

  const hash = (x) => F.toObject(poseidon(x));

  const assetId = 42n;

  const policyHash = hash([assetId]);

  console.log("policyHash =", policyHash.toString());

  const skG = 11111n;
  const skOwner = 33333n;
  const sNf = 44444n;

  const pkG = hash([skG]);
  const pkOwner = hash([skOwner]);
  const nfKeyHash = hash([sNf]);

  console.log("pkG =", pkG.toString());
  console.log("pkOwner =", pkOwner.toString());
  console.log("nfKeyHash =", nfKeyHash.toString());

  const attr = hash([
    7n,
    100n,
    2000n,
    5n,
    1n,
    2n,
    0n,
    999n
  ]);

  console.log("attr =", attr.toString());

  const cm = hash([
    12345678n,
    attr,
    policyHash,
    pkG,
    pkOwner,
    nfKeyHash,
    2n,
    987654321n
  ]);

  console.log("cm =", cm.toString());
})();
