const fs = require("fs");
const path = require("path");

const cases = [
  ["rcreate", null],
  ["rxfer_t2", null],
  ["rval_t1", null],
  ["rval_t2", null],
  ["ruse_t1", null],
  ["ruse_t2", null],
  ["rxfer_t2", (x) => { x.edge = "20"; }],
  ["rval_t1", (x) => { x.skOwner = "999"; }],
  ["rval_t2", (x) => { x.sNf = "999"; }],
  ["ruse_t1", (x) => { x.scopeHash = "1"; }],
  ["ruse_t2", (x) => { x.requestI = x.cap; }],
];

(async () => {
  const snarkjs = await import("snarkjs");
  let failures = 0;
  for (let index = 0; index < cases.length; index++) {
    const [name, mutate] = cases[index];
    const input = JSON.parse(fs.readFileSync(path.join(__dirname, "build", `input_${name}.json`)));
    if (mutate) mutate(input);
    const output = path.join(__dirname, "build", `test_${index}_${name}.wtns`);
    let accepted = true;
    try {
      await snarkjs.wtns.calculate(
  input,
  path.join(__dirname, `${name}_js`, `${name}.wasm`),
  output
);
    } catch (err) {
    console.error(`\n${name} failed:`);
    console.error(err);
    accepted = false;
}
    if (fs.existsSync(output)) fs.rmSync(output);
    const expected = mutate === null;
    if (accepted !== expected) {
      console.error(`${name}: expected ${expected ? "accept" : "reject"}, got ${accepted ? "accept" : "reject"}`);
      failures++;
    }
  }
  if (failures) process.exit(1);
  console.log(`Witness tests passed: ${cases.length} cases.`);
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
