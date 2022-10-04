# delastic search

A motoko client for elastic search on the internet computer.

## DFX Commands

### Restart DFX Replica & Deploy Canisters

#### Make Script Executable

```
chmod u+x ./scripts/restart-and-deploy.sh
```

#### Start DFX & Deploy

```
yarn restart-dfx
```

### Start dfx locally

#### Start Fresh

```
dfx start --clean
```

#### Start With Existing State

```
dfx start
```

#### Start and Run in the Background

```
dfx start --background
```

### Canister Commands

Note: All of the subsequent commands can be called with the name of a canister without '--all' if you'd like to target a specific canister.

#### Create Canisters

```
dfx canister create --all
```

#### Install Canisters

```
dfx canister install --all
```

#### Install Vessel

add these lines to .zshrc

```
vessel="./vessel-macos"
alias vessel="/usr/local/bin/vessel-macos"
```

#### Build Canisters

```
dfx build
```

#### Deploy Canisters

```
dfx deploy --all
```

#### Deploy Canisters on IC

```
dfx deploy --all --network ic
```

## Generate, Build, and Publish

In order for SCINET UIs to realize updates to the API, a new version of the api's associated github package needs to be published with the update. This is done in 3 steps:

- generate
- build
- publish

Right now versioning is done manually, so each PR needs to be paired with a semver update that reflects whether the change was a patch, minor, or major update.

Once the PR is merged, we will need to run `yarn publish`
