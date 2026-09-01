pragma circom 2.1.6;

include "circomlib/circuits/poseidon.circom";
include "circomlib/circuits/comparators.circom";
include "./merkle.circom";

template RValT2(cmDepth, nfDepth) {
    signal input cmTreeRoot;
    signal input nfSetRoot;
    signal input epoch;
    signal input assetId;
    signal input allowedPurposes[8];

    signal input tau;
    signal input purpose;
    signal input scope;
    signal input expiry;
    signal input cap;
    signal input freq;
    signal input accessType;
    signal input incentive;
    signal input payloadRef;
    signal input policyHash;
    signal input pkG;
    signal input pkOwner;
    signal input nfKeyHash;
    signal input r;
    signal input skOwner;
    signal input sNf;
    signal input cmPath[cmDepth];
    signal input cmIdx[cmDepth];
    signal input nfPath[nfDepth];

    component hAttr = Poseidon(8);
    hAttr.inputs[0] <== purpose;
    hAttr.inputs[1] <== scope;
    hAttr.inputs[2] <== expiry;
    hAttr.inputs[3] <== cap;
    hAttr.inputs[4] <== freq;
    hAttr.inputs[5] <== accessType;
    hAttr.inputs[6] <== incentive;
    hAttr.inputs[7] <== payloadRef;

    component hCm = Poseidon(8);
    hCm.inputs[0] <== tau;
    hCm.inputs[1] <== hAttr.out;
    hCm.inputs[2] <== policyHash;
    hCm.inputs[3] <== pkG;
    hCm.inputs[4] <== pkOwner;
    hCm.inputs[5] <== nfKeyHash;
    hCm.inputs[6] <== 4;
    hCm.inputs[7] <== r;

    component member = MerkleInclusion(cmDepth);
    member.leaf <== hCm.out;
    member.root <== cmTreeRoot;
    for (var i = 0; i < cmDepth; i++) {
        member.pathElements[i] <== cmPath[i];
        member.pathIndices[i] <== cmIdx[i];
    }

    component owner = Poseidon(1);
    owner.inputs[0] <== skOwner;
    owner.out === pkOwner;

    component hNfKey = Poseidon(1);
    hNfKey.inputs[0] <== sNf;
    hNfKey.out === nfKeyHash;

    component hCurrentNf = Poseidon(3);
    hCurrentNf.inputs[0] <== sNf;
    hCurrentNf.inputs[1] <== tau;
    hCurrentNf.inputs[2] <== epoch;

    component fresh = SparseMerkleNonInclusion(nfDepth);
    fresh.key <== hCurrentNf.out;
    fresh.root <== nfSetRoot;
    for (var k = 0; k < nfDepth; k++) {
        fresh.pathElements[k] <== nfPath[k];
    }

    component notExpired = LessEqThan(32);
    notExpired.in[0] <== epoch;
    notExpired.in[1] <== expiry;
    notExpired.out === 1;

    component hPolicy = Poseidon(1);
    hPolicy.inputs[0] <== assetId;
    hPolicy.out === policyHash;

    signal sum[9];
    sum[0] <== 0;
    component eq[8];
    for (var j = 0; j < 8; j++) {
        eq[j] = IsEqual();
        eq[j].in[0] <== purpose;
        eq[j].in[1] <== allowedPurposes[j];
        sum[j + 1] <== sum[j] + eq[j].out;
    }
    sum[8] === 1;
}

component main {public [cmTreeRoot, nfSetRoot, epoch, assetId, allowedPurposes]} = RValT2(32, 128);
