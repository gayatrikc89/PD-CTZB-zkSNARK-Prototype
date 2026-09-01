pragma circom 2.1.6;

include "circomlib/circuits/poseidon.circom";
include "circomlib/circuits/comparators.circom";

template RUseT1() {
    signal input cm;
    signal input tau;
    signal input epoch;
    signal input assetId;
    signal input scopeHash;
    signal input responseHash;
    signal input attestorKeyId;
    signal input attestationDigest;
    signal input auditCommitment;
    signal input allowedPurposes[8];

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
    signal input requestI;
    signal input auditRandomness;

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
    hCm.inputs[6] <== 6;
    hCm.inputs[7] <== r;
    hCm.out === cm;

    component owner = Poseidon(1);
    owner.inputs[0] <== skOwner;
    owner.out === pkOwner;

    component hPolicy = Poseidon(1);
    hPolicy.inputs[0] <== assetId;
    hPolicy.out === policyHash;

    component notExpired = LessEqThan(32);
    notExpired.in[0] <== epoch;
    notExpired.in[1] <== expiry;
    notExpired.out === 1;

    component bounded = LessThan(16);
    bounded.in[0] <== requestI;
    bounded.in[1] <== cap;
    bounded.out === 1;

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

    component hScope = Poseidon(4);
    hScope.inputs[0] <== scope;
    hScope.inputs[1] <== purpose;
    hScope.inputs[2] <== expiry;
    hScope.inputs[3] <== accessType;
    hScope.out === scopeHash;

    // The registry verifies the attestor signature over this digest.
    component hAttestation = Poseidon(3);
    hAttestation.inputs[0] <== attestorKeyId;
    hAttestation.inputs[1] <== scopeHash;
    hAttestation.inputs[2] <== responseHash;
    hAttestation.out === attestationDigest;

    component hAuditPayload = Poseidon(4);
    hAuditPayload.inputs[0] <== assetId;
    hAuditPayload.inputs[1] <== epoch;
    hAuditPayload.inputs[2] <== pkG;
    hAuditPayload.inputs[3] <== purpose;
    component hAudit = Poseidon(2);
    hAudit.inputs[0] <== auditRandomness;
    hAudit.inputs[1] <== hAuditPayload.out;
    hAudit.out === auditCommitment;
}

component main {public [cm, tau, epoch, assetId, scopeHash, responseHash, attestorKeyId, attestationDigest, auditCommitment, allowedPurposes]} = RUseT1();
