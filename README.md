# DelasticSearch

A motoko client for elastic search on the internet computer.

This repository contains the motoko module and types which can be imported into another motoko project, as well as the typescript types and clients for the corresponding motoko code which can be utilized by any javascript client.

delastic-search is incredibly flexible, and allows for storing and querying multiple data models given one uniform schema.

## Usage

delastic-search involves creating an object that serves as an index for all of your records. Said index has keys which represent the tokens associated with records stored in the index, and their values are lists of records associated with the tokens. Each record needs to have a unique id (Text), an entityType (Text) for filtering, and attributes (Union of several other types).

### Basics

To utilize delastic-search, all you need to do is create a new canister that exposes three methods, one for querying the index, one for updating a record across the index, and another for clearing the index of a record, as well as a stable index variable. Each of these methods will perform actions with the index via the DS package given their function arguments.

Please see an example implementation via this file: src/canisters/delastic_search.mo

### queryIndex

DS.queryIndex method expects the index, the queryString, and the entityType if there is one. This method will return the top 10 search results given the queryString and will filter the results via the entityType if it's present.

### updateIndex

DS.updateIndex expects the index, the record to be added or modified, the indexKeys, and oldIndexKeys.

indexKeys represent the keys in the index that you want to the record to be associated with. They are referenced during queries via the queryString in DS.queryIndex.

oldIndexKeys represent stale keys in the index that need to be purged of a record when its data changes. If you no longer want a record to be associated with a certain key, then include it in the oldIndexKeys array and DS will do the purging for you.

DS.updateIndex accounts for adding new records and updating existing ones.

### removeRecord

DS.removeRecord expects the index, the record to be removed, and the indexKeys the record is currently paired with.

## Installation

Using delastic-search is fairly simple. The package is installable via vessel in a motoko project and via an npm package in a javascript project.

### Motoko Projects

In a motoko project, simply add the package to your package-set.dhall's additions array like so:

```
let additions =
[
	{
		name = "delastic_search",
		repo = "https://github.com/scinet-inc/delastic-search",
		version = "v0.3.1",
		dependencies = [  "base" ]
	}
] : List Package
```

And add the package to your vessel.dhall:

```
{
  dependencies = [ "base", "matchers", "uuid", "delastic_search" ],
  compiler = None Text
}
```

Then, in your motoko code, import the package as so:

```
import DS "mo:delastic_search/ds";
```

And reference it like this:

```
let indexedRecords = DS.queryIndex(index, queryString, entityType);
```

### Javascript Clients

delastic-search also has a typescript/javascript npm package which exports types and a js client that make querying or mutating the index incredibly simple.

#### Install

npm

```
npm i @scinet-inc/delastic-search
```

or yarn

```
yarn add @scinet-inc/delastic-search
```

#### Application

Import the types and module for creating the client

```
import {
  delastic_search,
  delastic_search_types,
} from '@scinet-inc/delastic-search';
```

Create the client

```
const actor = delastic_search.createClient(
		DELASTIC_SEARCH_CANISTER_ID,
		agent
	);
```

NOTE: Do not forget to swap out DELASTIC_SEARCH_CANISTER_ID for whatever your canister id is.

Finally, call whatever method you need via the actor variable created in the previous step.

```
actor.queryIndex(queryString, 'all').then(async (queryRes) => {
	if ('ok' in queryRes) {
		// call function with queryRes['ok']
	} else {
		// handle error
	}
});
```

If you'd like to filter your results given a specific entityType, swap the 'all' argument for whatever entityType you want.
