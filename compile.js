const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

const node = process.execPath;
const circom = path.join(__dirname, "node_modules", "circom2", "cli.js");

const circuits = [
  "rcreate",
  "rxfer_t2",
  "rval_t1",
  "rval_t2",
  "ruse_t1",
  "ruse_t2",
];

for (const name of circuits) {

  console.log(`Compiling ${name}...`);

  fs.rmSync(path.join(__dirname, `${name}_js`), {
    recursive: true,
    force: true,
  });

  fs.rmSync(path.join(__dirname, `${name}.r1cs`), {
    force: true,
  });

  fs.rmSync(path.join(__dirname, `${name}.sym`), {
    force: true,
  });

  const result = spawnSync(
    node,
    [
      circom,
      path.join("circuits", `${name}.circom`),
      "-l",
      "node_modules",
      "--r1cs",
      "--wasm",
      "--sym",
    ],
    {
      cwd: __dirname,
      stdio: "inherit",
    }
  );

  if (result.status !== 0) {
    process.exit(result.status);
  }
}
