const { spawnSync } = require("child_process");

for (const script of ["test_witnesses.js", "test_registry_attestor.js"]) {
  const result = spawnSync(process.execPath, [script], { cwd: __dirname, stdio: "inherit" });
  if (result.status !== 0) process.exit(result.status || 1);
}
