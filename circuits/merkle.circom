pragma circom 2.1.6;

include "circomlib/circuits/poseidon.circom";
include "circomlib/circuits/bitify.circom";
include "circomlib/circuits/mux1.circom";

// Switch (leaf, sibling) order based on index bit
template DualMux() {
    signal input in[2];
    signal input s;        // 0 or 1
    signal output out[2];

    s * (1 - s) === 0;
    out[0] <== (in[1] - in[0]) * s + in[0];
    out[1] <== (in[0] - in[1]) * s + in[1];
}

// Standard Merkle inclusion proof with Poseidon-2 internal hashing.
// Proves: hash chain from leaf using pathElements + pathIndices == root.
template MerkleInclusion(levels) {
    signal input leaf;
    signal input root;
    signal input pathElements[levels];
    signal input pathIndices[levels];

    component sel[levels];
    component hasher[levels];

    for (var i = 0; i < levels; i++) {
        sel[i] = DualMux();
        if (i == 0) {
            sel[i].in[0] <== leaf;
        } else {
            sel[i].in[0] <== hasher[i-1].out;
        }
        sel[i].in[1] <== pathElements[i];
        sel[i].s <== pathIndices[i];

        hasher[i] = Poseidon(2);
        hasher[i].inputs[0] <== sel[i].out[0];
        hasher[i].inputs[1] <== sel[i].out[1];
    }

    root === hasher[levels - 1].out;
}

// Non-inclusion via sparse Merkle tree: prove that the leaf at the deterministic
// position derived from `key` is exactly 0. (Spent nullifier slots store 1; fresh slots store 0.)
// The sparse position is the low `levels` bits of Poseidon(key). Deployments
// use 128 levels, so accidental path collisions have 128-bit birthday cost.
template SparseMerkleNonInclusion(levels) {
    signal input key;             // the nullifier
    signal input root;            // current nfSet root
    signal input pathElements[levels];

    // Derive position bits from Poseidon(key)
    component posHash = Poseidon(1);
    posHash.inputs[0] <== key;

    component posBits = Num2Bits(254);
    posBits.in <== posHash.out;

    // Take the low `levels` bits as the path
    component checker = MerkleInclusion(levels);
    checker.leaf <== 0;            // non-membership: slot is empty (zero)
    checker.root <== root;
    for (var i = 0; i < levels; i++) {
        checker.pathElements[i] <== pathElements[i];
        checker.pathIndices[i]  <== posBits.out[i];
    }
}
