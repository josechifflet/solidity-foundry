-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil scopefile build lint lint-sol prettier-check prettier-write test-coverage test-coverage-report remove update slither scope scopefile

all: remove install build

# Clean the repo
clean:; forge clean && rm -rf cache out

# Remove modules
remove:; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

# Install dependencies
install:; forge install foundry-rs/forge-std && \
          forge install OpenZeppelin/openzeppelin-contracts && \
          forge install OpenZeppelin/openzeppelin-foundry-upgrades && \
          forge install OpenZeppelin/openzeppelin-contracts-upgradeable && \
          forge install Cyfrin/foundry-devops --no-commit

# Update Dependencies
update:; forge update

# Build the project
build:; forge build

# Run tests
test:; forge test -vvv --gas-report

# Create a snapshot
snapshot:; forge snapshot

# Format the code
format:; forge fmt

# Run Anvil
anvil:; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

# Run Slither
slither:; slither . --config-file slither.config.json --checklist

# Scope command
scope:; tree ./src/ | sed 's/└/#/g; s/──/--/g; s/├/#/g; s/│ /|/g; s/│/|/g'

# Create scope file
scopefile:; @tree ./src/ | sed 's/└/#/g' | awk -F '── ' '!/\.sol$$/ { path[int((length($$0) - length($$2))/2)] = $$2; next } { p = "src"; for(i=2; i<=int((length($$0) - length($$2))/2); i++) if (path[i] != "") p = p "/" path[i]; print p "/" $$2; }' > scope.txt

# Linting commands
lint:; pnpm lint:sol && pnpm prettier:check

lint-sol:; forge fmt --check && pnpm solhint {script,src,test}/**/*.sol

prettier-check:; prettier --check **/*.{json,md,yml} --ignore-path=.prettierignore

prettier-write:; prettier --write **/*.{json,md,yml} --ignore-path=.prettierignore

# Test coverage
test-coverage:; forge coverage

test-coverage-report:; forge coverage --report lcov && genhtml lcov.info --branch-coverage --output-dir coverage

# Generate development wallet private key
dev-wallet-pk:
	./bash/generate-dev-pk.sh

# Deploy Mumbai
deploy-mumbai:; forge script DeployPiggyBox \
    -vvv \
    --verify \
    --broadcast \
    --etherscan-api-key SWWRTJ9XGU7APMI576J4WPDDS7U8YMSA7P  \
    --private-key 0xd693d40d947ba9b85b5c0502410786256cd88edee68fe02585ce397752de5a86 \
    --rpc-url https://polygon-mumbai.g.alchemy.com/v2/JqiPQfidlW2G375YrWrZ173N6BsNvMTy
