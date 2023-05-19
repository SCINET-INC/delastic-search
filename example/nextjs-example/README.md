This is a [Next.js](https://nextjs.org/) project bootstrapped with [`create-next-app`](https://github.com/vercel/next.js/tree/canary/packages/create-next-app).

## Getting Started

### Deploy Search Canister

```bash
	dfx deploy
```

### Create .env.local

Createa a .env.local file in this same dir and use the example as a guide. NOTE: you will have to take the canister id from the canister you just deployed and use that as your NEXT_PUBLIC_DELASTIC_SEARCH_CANISTER_ID var value.

### Prep UI

First run yarn, then run the dev server.

```bash
yarn
```

```bash
yarn dev
```

## Seed the Canister

```bash
yarn seed
```

## Use UI

type 'tags' into the input to load the first round of records, then click the 'next' button to load the next rounds.
