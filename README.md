# 🗳️ Voting System Smart Contract

This project is a **decentralized voting system** built on Ethereum using **Solidity**. It ensures **secure, transparent, and tamper-proof elections**, managed by a chairman who controls **candidate registration and voter eligibility**. The smart contract enforces fair voting rules, prevents fraud, and ensures accurate results. 

## 🚀 Features

### ✅ Candidate & Voter Management
- Candidates are stored as `bytes32` for **gas optimization**.
- The chairman grants voting rights to **eligible voters**.
- Prevents **double voting** and unauthorized access.
- Tracks whether a voter has already voted.

### ⏳ Voting Process
- **Chairman-controlled** voting period (`setVotingPeriod` function).
- Voting starts only after the `startVoting()` function is called.
- **Immutable voting results** after the `votingEnd()` function is executed.
- **Tie detection** with an automatic `TieDetected` event.

### 🔐 Security & Transparency
- **Role-based access control** restricts unauthorized actions.
- **Event logging** tracks votes and election results.
- **Time-based restrictions** prevent premature or late voting.

## 📜 Smart Contract Structure

### 1️⃣ **Data Structures**
#### `struct Voter`
- `hasVoted`: Tracks if the voter has cast their vote.
- `canVote`: Determines voter eligibility.
- `votedCandidateIndex`: Stores the index of the voted candidate.

#### `struct Candidate`
- `name`: The candidate’s name (stored as `bytes32`).
- `voteCount`: The number of votes received.

### 2️⃣ **Main Functions**
#### 🏗️ `constructor(string[] memory candidateNames, bool _chairmanCanVote)`
- Initializes the contract with candidate names.
- Converts candidate names to `bytes32` to optimize gas usage.
- Sets whether the **chairman** is allowed to vote.

#### ⏳ `setVotingPeriod(uint durationInSeconds)`
- The chairman sets the voting period (in seconds).
- Defines the **start** and **end** times for voting.

#### 🔥 `startVoting()`
- Marks the voting process as **active**.
- Emits a `VotingStarted` event.

#### ✅ `giveRightToVote(address voter)`
- Grants voting rights to a specific voter.
- Ensures the voter **has not** received voting rights before.

#### 🗳️ `vote(uint candidateIndex)`
- Allows eligible voters to cast their votes for a candidate.
- Updates the candidate's **vote count**.
- Emits a `VoteCast` event.

#### ⏹️ `votingEnd()`
- Ends the voting process.
- Determines the winner or **detects a tie**.
- Emits `VotingEnded` or `TieDetected` events.

#### 🏆 `findWinner()`
- Internally calculates the **candidate with the most votes**.
- Detects ties and **returns the result**.

#### 🔍 `getCandidate(uint index)`
- Returns the **name** and **vote count** of a candidate.

#### ⏳ `getElapsedTime()`
- Returns the **elapsed time** since voting started.

#### ⏳ `getRemainingTime()`
- Returns the **remaining time** until voting ends.

### 3️⃣ **Helper Function**
#### 🔁 `stringToBytes32(string memory source)`
- Converts a **string** to `bytes32` for **efficient storage**.

