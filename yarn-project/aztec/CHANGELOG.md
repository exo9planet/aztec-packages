# Changelog

## [0.36.0](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.35.1...aztec-package-v0.36.0) (2024-04-30)


### Features

* Add key registry to deployment (e2e & sandbox) ([#5875](https://github.com/AztecProtocol/aztec-packages/issues/5875)) ([0881cd3](https://github.com/AztecProtocol/aztec-packages/commit/0881cd3083af70271bceda695d0c8ad21212c172)), closes [#5611](https://github.com/AztecProtocol/aztec-packages/issues/5611)
* Configure prover as separate process ([#5973](https://github.com/AztecProtocol/aztec-packages/issues/5973)) ([c0dd7b2](https://github.com/AztecProtocol/aztec-packages/commit/c0dd7b21779b99f1b9d3ed43623d3de25a332699))
* **p2p:** DiscV5 Peer Discovery ([#5652](https://github.com/AztecProtocol/aztec-packages/issues/5652)) ([0e81642](https://github.com/AztecProtocol/aztec-packages/commit/0e8164239b6a1180fd292e37faf1a0e64aa9cff4))


### Bug Fixes

* Deploy L1 contracts before starting node ([#5969](https://github.com/AztecProtocol/aztec-packages/issues/5969)) ([1908139](https://github.com/AztecProtocol/aztec-packages/commit/190813911c5e4fc7533525478ceca4162170fa6b))
* Refuse to start sequencer without a prover ([#6000](https://github.com/AztecProtocol/aztec-packages/issues/6000)) ([b30d0b6](https://github.com/AztecProtocol/aztec-packages/commit/b30d0b6481b0f0b2241f1fcc9ec9bc0f82308ce9))


### Miscellaneous

* **ci:** Prevent haywire logs ([#5966](https://github.com/AztecProtocol/aztec-packages/issues/5966)) ([b12f609](https://github.com/AztecProtocol/aztec-packages/commit/b12f60994fdd54cb4d8e18e444c207e319f9d6a6))
* Integrate new key store ([#5731](https://github.com/AztecProtocol/aztec-packages/issues/5731)) ([ab9fe78](https://github.com/AztecProtocol/aztec-packages/commit/ab9fe780e8a9fc3187a02b37ddbefa609d3bff8f)), closes [#5720](https://github.com/AztecProtocol/aztec-packages/issues/5720)
* Purging portal addresses ([#5842](https://github.com/AztecProtocol/aztec-packages/issues/5842)) ([4faccad](https://github.com/AztecProtocol/aztec-packages/commit/4faccad569e39228b0f3fbf741fc95e3a189e276))
* Renaming `noir-compiler` as `builder` ([#5951](https://github.com/AztecProtocol/aztec-packages/issues/5951)) ([185e57d](https://github.com/AztecProtocol/aztec-packages/commit/185e57d51e8bbf6194628ce62db3dd44f11634a4))
* Replace queue with facade over CircuitProver ([#5972](https://github.com/AztecProtocol/aztec-packages/issues/5972)) ([dafb3ed](https://github.com/AztecProtocol/aztec-packages/commit/dafb3edc799b2adaf285ffe57b41630040c68449))
* Using poseidon2 when computing a nullifier ([#5906](https://github.com/AztecProtocol/aztec-packages/issues/5906)) ([3a10e5e](https://github.com/AztecProtocol/aztec-packages/commit/3a10e5e75b8053dfea13a4901873d42ca01ca7c2)), closes [#5832](https://github.com/AztecProtocol/aztec-packages/issues/5832) [#1205](https://github.com/AztecProtocol/aztec-packages/issues/1205)

## [0.35.1](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.35.0...aztec-package-v0.35.1) (2024-04-16)


### Miscellaneous

* **aztec-package:** Synchronize aztec-packages versions

## [0.35.0](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.34.0...aztec-package-v0.35.0) (2024-04-16)


### ⚠ BREAKING CHANGES

* pay fee for account init ([#5601](https://github.com/AztecProtocol/aztec-packages/issues/5601))

### Features

* Pay fee for account init ([#5601](https://github.com/AztecProtocol/aztec-packages/issues/5601)) ([aca804f](https://github.com/AztecProtocol/aztec-packages/commit/aca804f96ca9e74b6b553449333e195c0639b151))

## [0.34.0](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.33.0...aztec-package-v0.34.0) (2024-04-10)


### Miscellaneous

* Reduce log verbosity in local e2e tests ([#5622](https://github.com/AztecProtocol/aztec-packages/issues/5622)) ([c496a10](https://github.com/AztecProtocol/aztec-packages/commit/c496a105eac3b78e53b7d42d4a64e88e3a4759a5))

## [0.33.0](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.32.1...aztec-package-v0.33.0) (2024-04-09)


### Features

* Jest fast transpile. no more ts-jest. ([#5530](https://github.com/AztecProtocol/aztec-packages/issues/5530)) ([1912802](https://github.com/AztecProtocol/aztec-packages/commit/19128024292a91d0f947f397ab1b0dc2cd7ef7aa))
* **SimulateTx:** Simulate constrained transaction execution with return values ([#5432](https://github.com/AztecProtocol/aztec-packages/issues/5432)) ([0249737](https://github.com/AztecProtocol/aztec-packages/commit/0249737e8b925406e9278b80fc7adc0f6ab5468d))

## [0.32.1](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.32.0...aztec-package-v0.32.1) (2024-04-02)


### Miscellaneous

* Explicit type imports ([#5519](https://github.com/AztecProtocol/aztec-packages/issues/5519)) ([2a217de](https://github.com/AztecProtocol/aztec-packages/commit/2a217de4da2031a9f3913a657a4b39201f4483bf))

## [0.32.0](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.31.0...aztec-package-v0.32.0) (2024-03-27)


### Features

* Sequencer checks list of allowed FPCs ([#5310](https://github.com/AztecProtocol/aztec-packages/issues/5310)) ([adf20dc](https://github.com/AztecProtocol/aztec-packages/commit/adf20dc4974707255daffdaf3526dc48dc035873)), closes [#5000](https://github.com/AztecProtocol/aztec-packages/issues/5000)

## [0.31.0](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.30.1...aztec-package-v0.31.0) (2024-03-26)


### Features

* Add batched signerless contract calls ([#5313](https://github.com/AztecProtocol/aztec-packages/issues/5313)) ([be60eb3](https://github.com/AztecProtocol/aztec-packages/commit/be60eb3afbf65cb9c2dec2e912e398caffb2ebd0))
* Dynamic proving ([#5346](https://github.com/AztecProtocol/aztec-packages/issues/5346)) ([6a7ccca](https://github.com/AztecProtocol/aztec-packages/commit/6a7ccca5dfa4a3354555f8b04b014da6ef72549a))
* Less earthly runners + e2e GA runners, bb bench ([#5356](https://github.com/AztecProtocol/aztec-packages/issues/5356)) ([2136a66](https://github.com/AztecProtocol/aztec-packages/commit/2136a66cc1fa2249b3ef47b787cfa1de9576dc38))

## [0.30.1](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.30.0...aztec-package-v0.30.1) (2024-03-20)


### Miscellaneous

* **aztec-package:** Synchronize aztec-packages versions

## [0.30.0](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.29.0...aztec-package-v0.30.0) (2024-03-19)


### Miscellaneous

* Add gas portal to l1 contract addresses ([#5265](https://github.com/AztecProtocol/aztec-packages/issues/5265)) ([640c89a](https://github.com/AztecProtocol/aztec-packages/commit/640c89a04d7b780795d40e239be3b3db73a16923)), closes [#5022](https://github.com/AztecProtocol/aztec-packages/issues/5022)

## [0.29.0](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.28.1...aztec-package-v0.29.0) (2024-03-18)


### Features

* Initial Earthly CI ([#5069](https://github.com/AztecProtocol/aztec-packages/issues/5069)) ([8e75fe5](https://github.com/AztecProtocol/aztec-packages/commit/8e75fe5c47250e860a4eae4dbf0973c503221720))

## [0.28.1](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.28.0...aztec-package-v0.28.1) (2024-03-14)


### Miscellaneous

* **aztec-package:** Synchronize aztec-packages versions

## [0.28.0](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.27.2...aztec-package-v0.28.0) (2024-03-14)


### ⚠ BREAKING CHANGES

* Support contracts with no constructor ([#5175](https://github.com/AztecProtocol/aztec-packages/issues/5175))

### Features

* Support contracts with no constructor ([#5175](https://github.com/AztecProtocol/aztec-packages/issues/5175)) ([df7fa32](https://github.com/AztecProtocol/aztec-packages/commit/df7fa32f34e790231e091c38a4a6e84be5407763))

## [0.27.2](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.27.1...aztec-package-v0.27.2) (2024-03-13)


### Miscellaneous

* **aztec-package:** Synchronize aztec-packages versions

## [0.27.1](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.27.0...aztec-package-v0.27.1) (2024-03-12)


### Miscellaneous

* **aztec-package:** Synchronize aztec-packages versions

## [0.27.0](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.26.6...aztec-package-v0.27.0) (2024-03-12)


### Features

* Add api for inclusion proof of outgoing message in block [#4562](https://github.com/AztecProtocol/aztec-packages/issues/4562) ([#4899](https://github.com/AztecProtocol/aztec-packages/issues/4899)) ([26d2643](https://github.com/AztecProtocol/aztec-packages/commit/26d26437022567e2d54052f21b1c937259f26c94))


### Miscellaneous

* Pin foundry ([#5151](https://github.com/AztecProtocol/aztec-packages/issues/5151)) ([69bd7dd](https://github.com/AztecProtocol/aztec-packages/commit/69bd7dd45af6b197b23c25dc883a1a5485955203))
* Remove old contract deployment flow ([#4970](https://github.com/AztecProtocol/aztec-packages/issues/4970)) ([6d15947](https://github.com/AztecProtocol/aztec-packages/commit/6d1594736e96cd744ea691a239fcd3a46bdade60))

## [0.26.6](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.26.5...aztec-package-v0.26.6) (2024-03-08)


### Miscellaneous

* **aztec-package:** Synchronize aztec-packages versions

## [0.26.5](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.26.4...aztec-package-v0.26.5) (2024-03-07)


### Features

* Integrated native ACVM ([#4903](https://github.com/AztecProtocol/aztec-packages/issues/4903)) ([3fd7025](https://github.com/AztecProtocol/aztec-packages/commit/3fd7025ab43e705cab4aa67ca057e54316a1715b))

## [0.26.4](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.26.3...aztec-package-v0.26.4) (2024-03-06)


### Miscellaneous

* **aztec-package:** Synchronize aztec-packages versions

## [0.26.3](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.26.2...aztec-package-v0.26.3) (2024-03-06)


### Miscellaneous

* **aztec-package:** Synchronize aztec-packages versions

## [0.26.2](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.26.1...aztec-package-v0.26.2) (2024-03-06)


### Miscellaneous

* **aztec-package:** Synchronize aztec-packages versions

## [0.26.1](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.26.0...aztec-package-v0.26.1) (2024-03-06)


### Miscellaneous

* **aztec-package:** Synchronize aztec-packages versions

## [0.26.0](https://github.com/AztecProtocol/aztec-packages/compare/aztec-package-v0.25.0...aztec-package-v0.26.0) (2024-03-05)


### ⚠ BREAKING CHANGES

* move noir out of yarn-project ([#4479](https://github.com/AztecProtocol/aztec-packages/issues/4479))
* note type ids ([#4500](https://github.com/AztecProtocol/aztec-packages/issues/4500))
* aztec binary ([#3927](https://github.com/AztecProtocol/aztec-packages/issues/3927))

### Features

* Aztec binary ([#3927](https://github.com/AztecProtocol/aztec-packages/issues/3927)) ([12356d9](https://github.com/AztecProtocol/aztec-packages/commit/12356d9e34994a239d5612798c1bc82fa3d26562))
* Note type ids ([#4500](https://github.com/AztecProtocol/aztec-packages/issues/4500)) ([e1da2fd](https://github.com/AztecProtocol/aztec-packages/commit/e1da2fd509c75d7886b95655d233165e087cf2ed))
* Parallel native/wasm bb builds. Better messaging around using ci cache. ([#4766](https://github.com/AztecProtocol/aztec-packages/issues/4766)) ([a924e55](https://github.com/AztecProtocol/aztec-packages/commit/a924e55393daa89fbba3a87cf019977286104b59))


### Bug Fixes

* Add new oracle contract to devnet in CI ([#4687](https://github.com/AztecProtocol/aztec-packages/issues/4687)) ([920fa10](https://github.com/AztecProtocol/aztec-packages/commit/920fa10d4d5fb476cd6d868439310452f6e8dcc5))
* Add registry contract to list ([#4694](https://github.com/AztecProtocol/aztec-packages/issues/4694)) ([3675e1d](https://github.com/AztecProtocol/aztec-packages/commit/3675e1d110eccf45986bbbcf35e29746474bb7aa))
* Aztec binary fixes ([#4273](https://github.com/AztecProtocol/aztec-packages/issues/4273)) ([84e1f7d](https://github.com/AztecProtocol/aztec-packages/commit/84e1f7dd0e005351bb742b015270ab2fd575136d))
* L1 contract address config ([#4684](https://github.com/AztecProtocol/aztec-packages/issues/4684)) ([20e7605](https://github.com/AztecProtocol/aztec-packages/commit/20e76058e3de7d0d30d6c951fa74d6dd08a68d2c))
* P2p-bootstrap ECS command + /status route ([#4682](https://github.com/AztecProtocol/aztec-packages/issues/4682)) ([21ec23d](https://github.com/AztecProtocol/aztec-packages/commit/21ec23d54fa69c3515f0d9fa23cc7ea1168d7e6e))
* Relative LogFn import ([#4328](https://github.com/AztecProtocol/aztec-packages/issues/4328)) ([1faead5](https://github.com/AztecProtocol/aztec-packages/commit/1faead5bf5e07417e2d4452a2e3ff096a273a41a))


### Miscellaneous

* Lift rollup address check & deplot kv-store to npm ([#4483](https://github.com/AztecProtocol/aztec-packages/issues/4483)) ([92d0aa4](https://github.com/AztecProtocol/aztec-packages/commit/92d0aa40ef9add4b433feed8862ba4286dc7036c))
* Move noir out of yarn-project ([#4479](https://github.com/AztecProtocol/aztec-packages/issues/4479)) ([1fe674b](https://github.com/AztecProtocol/aztec-packages/commit/1fe674b046c694e1cbbbb2edaf5a855828bb5340)), closes [#4107](https://github.com/AztecProtocol/aztec-packages/issues/4107)
* Squash yp ypb + other build improvements. ([#4901](https://github.com/AztecProtocol/aztec-packages/issues/4901)) ([be5855c](https://github.com/AztecProtocol/aztec-packages/commit/be5855cdbd1993155bd228afbeafee2c447b46a5))
* Updating viem ([#4783](https://github.com/AztecProtocol/aztec-packages/issues/4783)) ([23bc26a](https://github.com/AztecProtocol/aztec-packages/commit/23bc26a4859d9777c3e6dd49e351a4e6b13a989a))
