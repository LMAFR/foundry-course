## Command to download what we were importing from chainlink in Remix

forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 --no-commit

## Command to run tests

forge test

### If you just wanna run one specific test

forge test --mt {functionName or regexPattern}

### If you want to show console logs:

Add -vv

### If you want to show also revert info:

Add -vvv

### For fork tests (tests that require a test environment to run):

Add --fork-url {url}

Where {url} is like our previous rpc-url. For example, we were applying getVersion on Sepolia testnet, so we can take sepolia testnet URL from Alchemy and use it to test that function (testPriceFeedVersionIsAccurate in our test file).

In this case, he will run Anvil from behind (as we have not defined another connection), but it will connect to Sepolia chain instead of
connecting to a simulated blank chain (that is what is done by default).

### Check test coverage:

For example, we could do: forge coverage --fork-url $SEPOLIA_RPC_URL

### Get how much is going to cost us to run a test

forge snapshot --mt {functionTestName or regex}

### Types of tests

* Unit tests: to test a part of our code.
* Integration tests: to test how a part of our code interacts with other.
* Fork tests: to test how a part of our code works in a simulated real environment.
* Staging tests: to test how a part of our code works in a real environment that is not production.

## Deploy your contract

forge script script/DeployFundMe.s.sol

`If you get a path error referred to Counter.sol even if you already deleted it, remove the cache folder.`

## Variables storage

constants and immutable variables are part of the code bytecode, so they are not included in storage.

the rest of variables are stored in storage in some way.

function variables are stored in memory, which cost like 30 times less gas than storage in read and load operations 🤡,  just while function is running.

uint256 global variables are stored in hexadecimal code in a slot of storage

lists store their length in one slot and additional content in other slots.

mappings use 2 slots, as they are key-value couples.

Storage optimization help you save gas in transactions.

### See storage using cast

If you deploy your contract you can use your contract address with cast and see how each variable have been stored, from top to bottom in code, by using indexes:

```cast storage {contract_address} index```

### See storage using forge

You can use:

```forge inspect {contractFileName} storageLayout```


