// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/Context.sol";

contract SimpleAuction is Context {
    struct Bid {
        uint256 amount;
        bool hasBid;
    }

    address public auctionManager;
    uint256 public auctionEndTime;
    address public highestBidder;
    uint256 public highestBid;
    bool public auctionEnded;
    uint256 public startingBid;

    mapping(address => Bid) private participants;
    address[] private sortedUsers;

    event HighestBidIncreased(address indexed bidder, uint256 amount);
    event AuctionEnded(address indexed winner, uint256 amount);
    event Withdrawal(address indexed participant, uint256 amount); // Event for withdrawals

    /**
     * @dev Initializes the auction with the manager, duration, and starting bid.
     * @param _manager Address of the auction manager.
     * @param _duration Duration of the auction in seconds.
     * @param _startingBid Minimum bid amount.
     */
    constructor(address _manager, uint256 _duration, uint256 _startingBid) {
        require(_manager != address(0), "Manager address cannot be zero");
        auctionManager = _manager;
        auctionEndTime = block.timestamp + _duration;
        startingBid = _startingBid;
        highestBid = 0; // Initial highest bid is 0
        auctionEnded = false;
    }

    /**
     * @dev Modifier to restrict functions to the auction manager.
     */
    modifier onlyManager() {
        require(_msgSender() == auctionManager, "Only the auction manager can perform this action");
        _;
    }

    /**
     * @dev Modifier to ensure the auction has not ended.
     */
    modifier auctionNotEnded() {
        require(!auctionEnded, "Auction has already ended");
        _;
    }

    /**
     * @dev Modifier to ensure the auction has ended.
     */
    modifier auctionEndedOnly() {
        require(auctionEnded, "Auction has not yet ended");
        _;
    }

    /**
     * @dev Modifier to prevent the auction manager from participating.
     */
    modifier notManager() {
        require(_msgSender() != auctionManager, "Auction manager cannot participate");
        _;
    }

    /**
     * @dev Allows participants to place a bid. Bids can be lower than the current highest bid.
     */
    function bid() public payable auctionNotEnded notManager {
        require(msg.value >= startingBid, "Bid must be at least the starting bid");

        if (participants[_msgSender()].hasBid) {
            // If the user has already bid, add to their existing bid
            participants[_msgSender()].amount += msg.value;
            _removeUser(_msgSender());
        } else {
            // New bidder
            participants[_msgSender()].amount = msg.value;
            participants[_msgSender()].hasBid = true;
        }

        // Insert the user back into sortedUsers in the correct position
        _insertUserSorted(_msgSender());

        // Update highest bid and bidder if necessary
        if (participants[_msgSender()].amount > highestBid) {
            highestBid = participants[_msgSender()].amount;
            highestBidder = _msgSender();
            emit HighestBidIncreased(_msgSender(), participants[_msgSender()].amount);
        }
    }

    /**
     * @dev Internal function to remove a user from the sortedUsers array.
     * @param user Address of the user to remove.
     */
    function _removeUser(address user) internal {
        uint256 length = sortedUsers.length;
        for (uint256 i = 0; i < length; i++) {
            if (sortedUsers[i] == user) {
                sortedUsers[i] = sortedUsers[length - 1];
                sortedUsers.pop();
                break;
            }
        }
    }

    /**
     * @dev Internal function to insert a user into the sortedUsers array in descending order based on bid amount.
     * @param user Address of the user to insert.
     */
    function _insertUserSorted(address user) internal {
        uint256 userBid = participants[user].amount;
        uint256 length = sortedUsers.length;

        if (length == 0) {
            sortedUsers.push(user);
            return;
        }

        for (uint256 i = 0; i < length; i++) {
            if (userBid > participants[sortedUsers[i]].amount) {
                sortedUsers.push(sortedUsers[length - 1]); // Expand the array
                for (uint256 j = length; j > i; j--) {
                    sortedUsers[j] = sortedUsers[j - 1];
                }
                sortedUsers[i] = user;
                return;
            }
        }

        // If not inserted yet, append at the end
        sortedUsers.push(user);
    }

    /**
     * @dev Allows participants to cancel their bid and withdraw their funds.
     */
    function cancelation() public auctionNotEnded {
        require(participants[_msgSender()].hasBid, "You do not have a bid");

        // Remove the user from sortedUsers
        _removeUser(_msgSender());

        // Reset participant's bid
        participants[_msgSender()].hasBid = false;

        // Update highest bid and bidder if necessary
        if (highestBidder == _msgSender()) {
            if (sortedUsers.length > 0) {
                highestBidder = sortedUsers[0];
                highestBid = participants[highestBidder].amount;
            } else {
                highestBidder = address(0);
                highestBid = 0;
            }
        }

        // Allow the user to withdraw their bid
        // Since we're using the withdrawal pattern, the user can call withdraw to get their funds
    }

    /**
     * @dev Ends the auction and transfers the highest bid to the auction manager.
     */
    function auctionEnd() public onlyManager auctionNotEnded {
        require(block.timestamp >= auctionEndTime, "Auction end time has not been reached yet");

        auctionEnded = true;

        if (highestBidder != address(0)) {
            // Transfer the highest bid to the auction manager
            uint256 amount = participants[highestBidder].amount;
            participants[highestBidder].amount = 0; // Prevent reentrancy
            (bool success, ) = payable(auctionManager).call{value: amount}("");
            require(success, "Transfer to auction manager failed");

            emit AuctionEnded(highestBidder, amount);
        } else {
            // No bids were placed
            emit AuctionEnded(address(0), 0);
        }
    }

    /**
     * @dev Allows participants to withdraw their bids. Highest bidder cannot withdraw as their bid has been transferred to the manager.
     */
    function withdraw() public {
        require(auctionEnded, "Auction has not ended yet");
        require(_msgSender() != auctionManager, "Auction manager cannot withdraw");

        uint256 amount = participants[_msgSender()].amount;
        require(amount > 0, "No funds to withdraw");

        // Reset the bid amount before transferring to prevent reentrancy attacks
        participants[_msgSender()].amount = 0;

        (bool success, ) = payable(_msgSender()).call{value: amount}("");
        require(success, "Failed to withdraw funds");

        emit Withdrawal(_msgSender(), amount);
    }

    /**
     * @dev Returns the elapsed time since the auction end time.
     * @return Elapsed time in seconds. Negative if the auction has not ended yet.
     */
    function elapsedTime() public view returns (int256) {
        if (block.timestamp >= auctionEndTime) {
            return int256(block.timestamp - auctionEndTime);
        } else {
            return -int256(auctionEndTime - block.timestamp);
        }
    }

    /**
     * @dev Returns the list of all bidders sorted in descending order of their bid amounts.
     * @return Array of bidder addresses.
     */
    function getSortedUsers() public view returns (address[] memory) {
        return sortedUsers;
    }

    /**
     * @dev Returns the bid amount of a specific participant.
     * @param user Address of the participant.
     * @return The bid amount of the participant.
     */
    function getBidAmount(address user) public view returns (uint256) {
        return participants[user].amount;
    }
}
