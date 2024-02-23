// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Vault {
    // the address of the user offering the grant.
    address public donor;
    // the address of the beneficiary who can claim the grant.
    address public beneficiary;
    // the timestamp after which the beneficiary can claim the grant.
    uint256 public unlockTime;
    // the amount of Ether in the vault.
    uint256 public amount;

   // Emits an event when the grant is deposited.
    event GrantDeposited(
        address indexed donor,
        address indexed beneficiary,
        uint256 amount,
        uint256 unlockTime
    );
    event GrantClaimed(address indexed beneficiary, uint256 amount);

    // When deploying the contract, the donor specifies the beneficiary's address and the unlock time for the grant. Ether can be sent along with the deployment to fund the grant.
    constructor(address _beneficiary, uint256 _unlockTime) payable {
        require(
            _unlockTime > block.timestamp,
            "Unlock time must be in the future"
        );
        donor = msg.sender;
        beneficiary = _beneficiary;
        unlockTime = _unlockTime;
        amount = msg.value;
        emit GrantDeposited(donor, beneficiary, amount, unlockTime);
    }

    // The beneficiary can call this function to claim the grant after the unlockTime has passed. The function transfers the Ether to the beneficiary.
    function claimGrant() external {
        require(
            msg.sender == beneficiary,
            "Only the beneficiary can claim the grant"
        );
        require(block.timestamp >= unlockTime, "Grant is not yet unlocked");

        uint256 transferAmount = amount;
        amount = 0; // Ensure re-entrancy protection

        (bool success, ) = payable(beneficiary).call{value: transferAmount}("");
        require(success, "Transfer failed");

        emit GrantClaimed(beneficiary, transferAmount);
    }

    //  Allows anyone to check the balance of the vault.
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Fallback function to accept Ether transactions
    receive() external payable {
        require(msg.sender == donor, "Only the donor can add funds");
        amount += msg.value;
    }
}
