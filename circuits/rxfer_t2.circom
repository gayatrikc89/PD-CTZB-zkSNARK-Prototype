pragma circom 2.1.6;

include "circomlib/circuits/poseidon.circom";
include "circomlib/circuits/comparators.circom";
include "circomlib/circuits/bitify.circom";
include "./merkle.circom";

template RXferT2(cmDepth) {
    signal input nfOld;
    signal input cmNew;
    signal input cmTreeRoot;
    signal input edge;

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
    signal input nfKeyHash;

    signal input rOld;
    signal input fromStage;
    signal input skOwnerOld;
    signal input cmPath[cmDepth];
    signal input cmIdx[cmDepth];

    signal input rNew;
    signal input toStage;
    signal input pkOwnerNew;

    edge === 8 * fromStage + toStage;

    component edgeEq[4];
    signal edgeSum[5];
    edgeSum[0] <== 0;
    var allowedEdges[4] = [19, 28, 37, 46];
    for (var e = 0; e < 4; e++) {
        edgeEq[e] = IsEqual();
        edgeEq[e].in[0] <== edge;
        edgeEq[e].in[1] <== allowedEdges[e];
        edgeSum[e + 1] <== edgeSum[e] + edgeEq[e].out;
    }
    edgeSum[4] === 1;

    component stageOldRange = Num2Bits(3);
    stageOldRange.in <== fromStage;
    component stageNewRange = Num2Bits(3);
    stageNewRange.in <== toStage;

    component hAttr = Poseidon(8);
    hAttr.inputs[0] <== purpose;
    hAttr.inputs[1] <== scope;
    hAttr.inputs[2] <== expiry;
    hAttr.inputs[3] <== cap;
    hAttr.inputs[4] <== freq;
    hAttr.inputs[5] <== accessType;
    hAttr.inputs[6] <== incentive;
    hAttr.inputs[7] <== payloadRef;

    component hOldOwner = Poseidon(1);
    hOldOwner.inputs[0] <== skOwnerOld;

    component hOld = Poseidon(8);
    hOld.inputs[0] <== tau;
    hOld.inputs[1] <== hAttr.out;
    hOld.inputs[2] <== policyHash;
    hOld.inputs[3] <== pkG;
    hOld.inputs[4] <== hOldOwner.out;
    hOld.inputs[5] <== nfKeyHash;
    hOld.inputs[6] <== fromStage;
    hOld.inputs[7] <== rOld;

    component member = MerkleInclusion(cmDepth);
    member.leaf <== hOld.out;
    member.root <== cmTreeRoot;
    for (var i = 0; i < cmDepth; i++) {
        member.pathElements[i] <== cmPath[i];
        member.pathIndices[i] <== cmIdx[i];
    }

    component hNf = Poseidon(3);
    hNf.inputs[0] <== skOwnerOld;
    hNf.inputs[1] <== tau;
    hNf.inputs[2] <== edge;
    hNf.out === nfOld;

    component hNew = Poseidon(8);
    hNew.inputs[0] <== tau;
    hNew.inputs[1] <== hAttr.out;
    hNew.inputs[2] <== policyHash;
    hNew.inputs[3] <== pkG;
    hNew.inputs[4] <== pkOwnerNew;
    hNew.inputs[5] <== nfKeyHash;
    hNew.inputs[6] <== toStage;
    hNew.inputs[7] <== rNew;
    hNew.out === cmNew;
}

component main {public [nfOld, cmNew, cmTreeRoot, edge]} = RXferT2(32);
