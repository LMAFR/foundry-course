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

### Types of tests

* Unit tests: to test a part of our code.
* Integration tests: to test how a part of our code interacts with other.
* Fork tests: to test how a part of our code works in a simulated real environment.
* Staging tests: to test how a part of our code works in a real environment that is not production.

## Deploy your contract

forge script script/DeployFundMe.s.sol

`If you get a path error referred to Counter.sol even if you already deleted it, remove the cache folder.`

