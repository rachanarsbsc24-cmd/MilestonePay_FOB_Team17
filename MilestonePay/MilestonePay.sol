
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MilestonePay {
    address public client;
    address payable public freelancer;

    uint256 public paymentAmount;
    bool public isFunded;
    bool public isCompleted;

    constructor(address payable _freelancer) {
        require(_freelancer != address(0), "Invalid freelancer");
        require(_freelancer != msg.sender, "Client and freelancer must differ");

        client = msg.sender;
        freelancer = _freelancer;
    }

    function deposit() external payable {
        require(msg.sender == client, "Only client can deposit");
        require(!isFunded, "Already funded");
        require(msg.value > 0, "Deposit must be greater than zero");

        paymentAmount = msg.value;
        isFunded = true;
    }

    function approveMilestone() external {
        require(msg.sender == client, "Only client can approve");
        require(isFunded, "No funds deposited");
        require(!isCompleted, "Milestone already completed");

        isCompleted = true;
    }

    function releasePayment() external {
        require(msg.sender == client, "Only client can release payment");
        require(isFunded, "No funds deposited");
        require(isCompleted, "Milestone not approved");

        uint256 amount = paymentAmount;

        isFunded = false;
        paymentAmount = 0;

        (bool success, ) = freelancer.call{value: amount}("");
        require(success, "Payment transfer failed");
    }
}
