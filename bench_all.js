const fs = require("fs");
const os = require("os");
const path = require("path");
const { spawnSync } = require("child_process");

const node = process.execPath;
const snarkCli = path.join(__dirname, "node_modules", "snarkjs", "build", "cli.cjs");
const build = path.join(__dirname, "build");
const circuits = ["rcreate", "rxfer_t2", "rval_t1", "rval_t2", "ruse_t1", "ruse_t2"];

function run(args, options = {}) {
  const result = spawnSync(node, [snarkCli, ...args], {
    cwd: __dirname,
    encoding: "utf8",
    input: options.input,
    stdio: options.capture ? "pipe" : "inherit",
    maxBuffer: 64 * 1024 * 1024,
  });
  if (result.status !== 0) {
    throw new Error(`snarkjs ${args.join(" ")} failed\n${result.stderr || ""}`);
  }
  return result.stdout || "";
}

function median(values) {
  const sorted = [...values].sort((a, b) => a - b);
  return sorted[Math.floor(sorted.length / 2)];
}

(async () => {
  fs.mkdirSync(build, { recursive: true });
  const pot = path.join("build", "pot17_final.ptau");
  if (!fs.existsSync(path.join(__dirname, pot))) {
    run(["powersoftau", "new", "bn128", "17", "build/pot17_0000.ptau"]);
    run(["powersoftau", "contribute", "build/pot17_0000.ptau", "build/pot17_0001.ptau", "--name=pd-ctzb", "-e=pd-ctzb-phase1"]);
    run(["powersoftau", "prepare", "phase2", "build/pot17_0001.ptau", pot]);
  }

  const snarkjs = await import("snarkjs");
  const results = [];
  for (const name of circuits) {
    console.log(`Benchmarking ${name}...`);
    const r1cs = `build/${name}.r1cs`;
    const wasm = path.join(__dirname, `${name}_js`, `${name}.wasm`);
    const zkey0 = `build/${name}_0000.zkey`;
    const zkey = `build/${name}_final.zkey`;
    const vkeyPath = `build/${name}_vkey.json`;
    if (!fs.existsSync(path.join(__dirname, zkey))) {
      run(["groth16", "setup", r1cs, pot, zkey0]);
      run(["zkey", "contribute", zkey0, zkey, "--name=pd-ctzb", "-e=pd-ctzb-phase2"]);
      run(["zkey", "export", "verificationkey", zkey, vkeyPath]);
    }

    const input = JSON.parse(fs.readFileSync(path.join(build, `input_${name}.json`), "utf8"));
    const vkey = JSON.parse(fs.readFileSync(path.join(__dirname, vkeyPath), "utf8"));
    await snarkjs.groth16.fullProve(input, wasm, path.join(__dirname, zkey));

    const proveMs = [];
    let proof;
    let publicSignals;
    for (let i = 0; i < 3; i++) {
      const start = process.hrtime.bigint();
      const result = await snarkjs.groth16.fullProve(input, wasm, path.join(__dirname, zkey));
      proveMs.push(Number(process.hrtime.bigint() - start) / 1e6);
      proof = result.proof;
      publicSignals = result.publicSignals;
    }

    const verifyMs = [];
    for (let i = 0; i < 10; i++) {
      const start = process.hrtime.bigint();
      const valid = await snarkjs.groth16.verify(vkey, publicSignals, proof);
      if (!valid) throw new Error(`${name} proof did not verify`);
      verifyMs.push(Number(process.hrtime.bigint() - start) / 1e6);
    }

    const info = run(["r1cs", "info", r1cs], { capture: true });
    const constraints = Number(info.match(/# of Constraints:\s+(\d+)/)[1]);
    const publicInputs = Number(info.match(/# of Public Inputs:\s+(\d+)/)[1]);
    results.push({
      name,
      constraints,
      publicInputs,
      proverMedianMs: median(proveMs),
      verifierMedianMs: median(verifyMs),
      proofJsonBytes: Buffer.byteLength(JSON.stringify(proof)),
    });
  }

  const report = {
    generatedAt: new Date().toISOString(),
    platform: `${os.platform()} ${os.release()} ${os.arch()}`,
    cpu: os.cpus()[0]?.model,
    logicalCpus: os.cpus().length,
    memoryBytes: os.totalmem(),
    node: process.version,
    circom: "circom2 npm 0.2.22 / Circom 2.2.2",
    proofSystem: "Groth16 over BN254",
    results,
  };
  fs.writeFileSync(path.join(build, "benchmark_results.json"), JSON.stringify(report, null, 2));
  console.table(results.map((r) => ({
    circuit: r.name,
    constraints: r.constraints,
    prove_ms: r.proverMedianMs.toFixed(1),
    verify_ms: r.verifierMedianMs.toFixed(2),
    proof_json_bytes: r.proofJsonBytes,
  })));
  process.exit(0);
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
