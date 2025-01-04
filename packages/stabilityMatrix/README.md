# Update version

Update the version and set the hash to `""`, and run the following from the flake root:

```bash
$(nix-build -A outputs.packages.x86_64-linux.stabilityMatrix.fetch-deps) packages/stabilityMatrix/deps.json
```

At first this will error and emit the correct hash. Set the source hash. Then run again.