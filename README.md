VestingCliffTrap

Overview;

The Vesting Cliff Trap is a Drosera-compatible proof-of-concept (PoC) designed to monitor vesting contracts for cliff unlock events. Token cliffs can create sudden selling pressure when large allocations unlock all at once. This trap provides early detection and protection by automatically flagging vesting contracts once their cliff is reached.

How It Works
	•	Collect: The trap observes the target vesting contract’s cliffTimestamp and current block timestamp.
	•	ShouldRespond: If the current time is greater than or equal to the cliff, the trap triggers a response.
	•	Response: The associated response contract flags the vesting contract on-chain. Other users, dApps, or traps can query this registry to identify tokens that just unlocked.

Why It Matters
	•	Detects risky unlock events before they impact the market.
	•	Helps protect traders from buying into tokens that are about to face major selling pressure.
	•	Provides on-chain proof of vesting cliff triggers for automated risk systems.

Usage
	1.	Deploy the trap on Hoodi testnet.
	2.	Configure drosera.toml with the trap JSON artifact and the deployed response contract address.
	3.	Once deployed, the trap continuously monitors the vesting contract and automatically flags it upon unlock.

Files
	•	VestingCliffTrap.sol – Trap contract monitoring vesting cliff timestamps.
	•	CliffResponse.sol – Response contract that flags risky vesting contracts on-chain.
	•	drosera.toml – Configuration for Drosera operators.
	•	VestingMock.sol – A mock vesting contract used for testing the trap locally.

Testing (Optional)

You can deploy VestingMock.sol to simulate a vesting contract with a cliff.
	•	Set a custom cliffTimestamp.
	•	Run the trap against it.
	•	Observe how the trap triggers once the cliff time is reached.
