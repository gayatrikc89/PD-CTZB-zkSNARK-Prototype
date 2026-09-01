# PD-CTZB: Privacy-Preserving Decentralized Consent Tokenization Using zk-SNARKs

This repository contains the prototype implementation accompanying the PD-CTZB research work on **privacy-preserving decentralized consent tokenization using zero-knowledge proofs**.

The prototype demonstrates how consent-related relations can be validated and used while minimizing disclosure of sensitive authorization information. The implementation uses **Circom** circuits and **Groth16 zk-SNARKs over the BN254 curve**.

---

## 1. Objective

The objective of PD-CTZB is to provide a privacy-preserving mechanism for representing and validating consent in a decentralized environment.

The prototype focuses on two privacy tiers:

* **Tier 1 – Public/commitment-based validation:**
  Consent-related information is represented through immutable commitments and publicly verifiable control information.

* **Tier 2 – Shielded validation and token use:**
  Sensitive token-transfer and token-use relations are validated through zero-knowledge proofs without requiring the underlying private values to be revealed.

The prototype therefore separates publicly verifiable control information from sensitive authorization and token-use information.

---

## 2. High-Level Workflow

The prototype follows the following conceptual workflow:

```text
Consent / Authorization Information
              |
              v
       Commitment Creation
          (rcreate)
              |
              v
      Consent Token / State
              |
       +------+------+
       |             |
       v             v
 Tier-1 Validation  Tier-2 Validation
    (rval_t1)         (rval_t2)
       |             |
       +------+------+
              |
              v
       Token Transfer
         (rxfer_t2)
              |
              v
          Token Use
       +------+------+
       |             |
       v             v
    Tier-1         Tier-2
   (ruse_t1)      (ruse_t2)
       |             |
       +------+------+
              |
              v
      Valid zk-SNARK proof
```

Each relation is represented as a Circom circuit and can be proved and verified using Groth16.

---

## 3. Prototype Components

The prototype currently contains six principal zk-SNARK circuits.

| Circuit    | Purpose                                                   |
| ---------- | --------------------------------------------------------- |
| `rcreate`  | Creates/validates the consent-related commitment relation |
| `rxfer_t2` | Validates the Tier-2 token-transfer relation              |
| `rval_t1`  | Performs Tier-1 consent/token validation                  |
| `rval_t2`  | Performs Tier-2 validation involving shielded information |
| `ruse_t1`  | Validates Tier-1 token-use conditions                     |
| `ruse_t2`  | Validates Tier-2 token-use conditions                     |

A supporting Merkle component is provided in:

```text
circuits/merkle.circom
```

---

## 4. Repository Structure

```text
PD-CTZB-zkSNARK-Prototype/
│
├── circuits/
│   ├── merkle.circom
│   ├── rcreate.circom
│   ├── rxfer_t2.circom
│   ├── rval_t1.circom
│   ├── rval_t2.circom
│   ├── ruse_t1.circom
│   └── ruse_t2.circom
│
├── build/
│   ├── *.circom
│   ├── *_vkey.json
│   ├── input_*.json
│   ├── benchmark_results.json
│   └── Verifier_rval_t1.sol
│
├── compile.js
├── gen_inputs.js
├── bench_all.js
├── check.js
├── registry_attestor.js
├── test_all.js
├── test_witnesses.js
├── test_registry_attestor.js
├── package.json
├── pnpm-lock.yaml
├── .gitignore
└── README.md
```

---

## 5. Technology Stack

The prototype was evaluated using:

* **Node.js:** v20.20.2
* **npm:** 10.8.2
* **Circom:** 2.2.2
* **circom2 npm package:** 0.2.22
* **snarkjs:** 0.7.6
* **Proof system:** Groth16
* **Elliptic curve:** BN254
* **Platform:** macOS
* **CPU:** Apple M1
* **Logical CPUs:** 8
* **Memory:** 8 GB

---

## 6. Installation

Clone the repository:

```bash
git clone https://github.com/gayatrikc89/PD-CTZB-zkSNARK-Prototype.git
cd PD-CTZB-zkSNARK-Prototype
```

Install the Node.js dependencies:

```bash
npm install
```

The required dependencies are specified in `package.json`.

The principal packages are:

```text
circom2
circomlib
circomlibjs
snarkjs
```

---

## 7. Generating Test Inputs

The prototype includes a test-input generation script:

```bash
node gen_inputs.js
```

This generates the input fixtures used by the prototype.

The resulting inputs are stored under:

```text
build/input_*.json
```

These files contain **test/experimental values for prototype evaluation** and should not be interpreted as production cryptographic secrets.

---

## 8. Compiling the Circuits

The compilation script is:

```bash
node compile.js
```

The Circom source files are located under:

```text
circuits/
```

Compilation generates the corresponding circuit artifacts and WebAssembly components required for witness generation.

Generated proving artifacts such as `.r1cs`, `.sym`, `.wasm`, `.ptau`, `.zkey`, and `.wtns` are intentionally excluded from version control.

---

## 9. Witness Generation

For a circuit such as `rval_t1`, a witness can be generated using:

```bash
npx snarkjs wtns calculate \
rval_t1_js/rval_t1.wasm \
build/input_rval_t1.json \
build/witness_rval_t1.wtns
```

The generated witness is used by Groth16 to produce the proof.

---

## 10. Groth16 Proof Generation

For example, the Tier-1 validation circuit can be proved using:

```bash
npx snarkjs groth16 prove \
build/rval_t1_final.zkey \
build/witness_rval_t1.wtns \
build/proof_rval_t1.json \
build/public_rval_t1.json
```

The command produces:

```text
proof_rval_t1.json
public_rval_t1.json
```

The proof contains the zero-knowledge proof object, while the public file contains the public signals required for verification.

---

## 11. Proof Verification

The generated proof can be verified using the verification key:

```bash
npx snarkjs groth16 verify \
build/rval_t1_vkey.json \
build/public_rval_t1.json \
build/proof_rval_t1.json
```

A successful verification produces:

```text
[INFO] snarkJS: OK!
```

This confirms that the proof is valid with respect to the circuit and the supplied public signals.

---

## 12. Automated Tests

The prototype provides automated witness and registry tests.

Run:

```bash
node test_all.js
```

The test suite exercises the prototype circuits and registry-attestor functionality.

The current test execution reported:

```text
Witness tests passed: 11 cases.
Registry attestor tests passed: 6 cases.
```

The witness-test script also reports assertion failures for several deliberately supplied test cases. These correspond to invalid constraint conditions and demonstrate that the circuits reject inputs that do not satisfy their specified relations.

The successful valid cases therefore should be distinguished from intentionally failing constraint cases.

---

## 13. Performance Benchmarking

The benchmark script is:

```bash
node bench_all.js
```

The script evaluates:

* Number of constraints
* Proving time
* Verification time
* Proof size

The benchmark uses repeated proof-generation and verification measurements and reports the median values.

### Measured Results

The following results were obtained on an **Apple M1, 8 GB RAM system** using Groth16 over BN254.

| Circuit    | Constraints | Public Inputs | Median Proving Time (ms) | Median Verification Time (ms) | Proof JSON (bytes) |
| ---------- | ----------: | ------------: | -----------------------: | ----------------------------: | -----------------: |
| `rcreate`  |       2,826 |            11 |                    235.1 |                         10.25 |                722 |
| `rxfer_t2` |      21,198 |             4 |                  1,194.3 |                         10.81 |                725 |
| `rval_t1`  |       3,241 |            12 |                    334.0 |                         10.85 |                722 |
| `rval_t2`  |      88,131 |            12 |                  4,472.4 |                         10.24 |                723 |
| `ruse_t1`  |       5,855 |            17 |                    407.5 |                          8.38 |                725 |
| `ruse_t2`  |      90,876 |            18 |                  4,579.9 |                          8.64 |                724 |

The complete machine-readable benchmark report is available at:

```text
build/benchmark_results.json
```

### Interpretation

The results demonstrate the expected relationship between circuit complexity and proving cost.

The Tier-2 validation/use circuits contain substantially more constraints than their Tier-1 counterparts and consequently require several seconds for proof generation on the evaluation machine.

In contrast, Groth16 verification remains approximately within the 8–11 ms range across the evaluated circuits.

These measurements are prototype measurements and should be interpreted in the context of the specified hardware and software environment.

---

## 14. Verification Key and Solidity Verifier

Verification keys for the evaluated circuits are provided under:

```text
build/*_vkey.json
```

A Solidity verifier generated for the `rval_t1` circuit is provided as:

```text
build/Verifier_rval_t1.sol
```

It was generated using:

```bash
npx snarkjs zkey export solidityverifier \
build/rval_t1_final.zkey \
build/Verifier_rval_t1.sol
```

This demonstrates the possibility of integrating the zk-SNARK verification process with an Ethereum-compatible smart-contract environment.

---

## 15. Large Generated Artifacts

The following generated artifacts are intentionally **not included in the Git repository**:

```text
*.ptau
*.zkey
*.wtns
*.r1cs
*.sym
*_js/
node_modules/
```

This is intentional.

The complete local prototype generated approximately hundreds of megabytes of proving-system artifacts. Keeping these files outside Git avoids unnecessary repository growth while retaining the source circuits, input fixtures, verification keys, benchmark results, and scripts required to understand and reproduce the implementation.

The `.gitignore` file documents these exclusions.

---

## 16. Reproducibility

To reproduce the experimental workflow:

```bash
git clone https://github.com/gayatrikc89/PD-CTZB-zkSNARK-Prototype.git
cd PD-CTZB-zkSNARK-Prototype

npm install
node gen_inputs.js
node compile.js
```

The Groth16 setup/proving artifacts can then be generated using `snarkjs` for the required circuits.

For an individual circuit, the general workflow is:

```text
Circom source
     |
     v
Compilation
     |
     v
R1CS + WASM
     |
     v
Witness generation
     |
     v
Groth16 setup / zKey
     |
     v
Proof generation
     |
     v
Proof verification
```

---

## 17. Security and Experimental Disclaimer

This repository contains a **research prototype** intended for experimental evaluation and reproducibility.

It should not be considered production-ready cryptographic software.

The supplied input values are experimental/test fixtures. They should not be reused as production credentials, private keys, secrets, or authorization material.

Security-critical deployment would require additional analysis, independent cryptographic review, secure parameter management, production-grade key management, trusted setup considerations, and comprehensive testing.

---

## 18. Citation

If you use this prototype or its implementation in academic work, please cite the associated PD-CTZB research publication.


---

## 19. Repository

**GitHub:**
https://github.com/gayatrikc89/PD-CTZB-zkSNARK-Prototype

---

## 20. License

This project is released for research and academic use. Please refer to the repository license and associated publication for applicable terms.
