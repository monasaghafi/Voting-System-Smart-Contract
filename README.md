# 🏆 Auction Smart Contract

This project implements a **secure and transparent auction system** using **Solidity** on the **Ethereum blockchain**. The contract enables users to place bids within a specified auction period, ensuring **fairness, immutability, and automated winner selection**.

---

## 🚀 Features

### ✅ Auction Management
- Allows the auction **creator** to set a **bidding period**.
- Defines the **minimum bid amount** required for participation.
- Automatically determines the **highest bidder** when the auction ends.

### 🏅 Bidding Process
- Users can **place bids** if they meet the **minimum bid requirement**.
- Each bid must be **higher than the current highest bid**.
- The highest bid is **stored securely** until the auction ends.

### 🔐 Security & Fairness
- Prevents **late bids** after the auction has ended.
- Ensures **only the highest bidder wins**.
- Implements **fund withdrawal functions** to return bids to non-winning participants.

---

## 📜 Smart Contract Structure

### 1️⃣ **Data Structures**
#### `struct Bid`
- `bidder`: Address of the bidder.
- `amount`: The amount of the bid.

### 2️⃣ **Main Functions**
#### 🔧 `constructor(uint _biddingTime, uint _minBid)`
- Initializes the auction with a specified **bidding time** and **minimum bid amount**.
- Sets the **start and end time** of the auction.

#### 📌 `placeBid()`
- Allows participants to place a bid **greater than the current highest bid**.
- Refunds the previous highest bidder before updating to the new highest bid.

#### ⏹️ `endAuction()`
- **Finalizes the auction** and determines the highest bidder.
- Prevents further bids from being placed.
- Transfers the winning amount to the auction creator.

#### 💰 `withdraw()`
- Allows non-winning bidders to **withdraw their funds** after the auction has ended.

#### 🔍 `getHighestBid()`
- Returns the **current highest bid** and **highest bidder's address**.

#### ⏳ `getRemainingTime()`
- Returns the **remaining time** before the auction ends.

---

## ⚡ Deployment and Usage

### 🔧 **Deployment**
To deploy the contract, provide:
- The **duration of the auction** (in seconds).
- The **minimum bid amount** required.
