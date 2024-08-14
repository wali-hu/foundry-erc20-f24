// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract TestOurToken is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address Abdullah = makeAddr("Abdullah");
    address Naveed = makeAddr("Naveed");
    address Zain = makeAddr("Zain");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        // Transfer tokens to Abdullah
        vm.prank(msg.sender);
        ourToken.transfer(Abdullah, STARTING_BALANCE);
    }

    // Test the balance of Abdullah after initial transfer
    function testAbdullahBalance() public view {
        assertEq(ourToken.balanceOf(Abdullah), STARTING_BALANCE);
    }

    // Test the approve and transferFrom functionality
    function testAllowancesWorks() public {
        uint256 initialAllowance = 100 ether;

        // Abdullah approves Naveed to spend tokens on his behalf
        vm.prank(Abdullah);
        ourToken.approve(Naveed, initialAllowance);

        uint256 transferAmount = 50 ether;

        vm.prank(Naveed);
        ourToken.transferFrom(Abdullah, Naveed, transferAmount);

        assertEq(ourToken.balanceOf(Naveed), transferAmount);
        assertEq(
            ourToken.balanceOf(Abdullah),
            STARTING_BALANCE - transferAmount
        );

        // Check remaining allowance
        assertEq(
            ourToken.allowance(Abdullah, Naveed),
            initialAllowance - transferAmount
        );
    }

    // Test transferring more than the balance
    function testTransferMoreThanBalance() public {
        vm.prank(Abdullah);
        vm.expectRevert();
        ourToken.transfer(Naveed, STARTING_BALANCE + 1);
    }

    // Test allowance decrease
    function testAllowanceDecrease() public {
        uint256 initialAllowance = 1000 ether;

        // Abdullah approves Naveed to spend tokens on his behalf
        vm.prank(Abdullah);
        ourToken.approve(Naveed, initialAllowance);

        uint256 reducedAllowance = 500 ether;

        // Abdullah reduces Naveed's allowance
        vm.prank(Abdullah);
        ourToken.approve(Naveed, reducedAllowance);

        assertEq(ourToken.allowance(Abdullah, Naveed), reducedAllowance);
    }

    // Test transferring without enough allowance
    function testTransferWithoutEnoughAllowance() public {
        uint256 initialAllowance = 100 ether;
        uint256 transferAmount = 200 ether;

        // Abdullah approves Naveed to spend tokens on his behalf
        vm.prank(Abdullah);
        ourToken.approve(Naveed, initialAllowance);

        // Attempt to transfer more than the allowed amount
        vm.prank(Naveed);
        vm.expectRevert();
        ourToken.transferFrom(Abdullah, Naveed, transferAmount);
    }

    // Test self-approval and transfer
    function testSelfApprovalAndTransfer() public {
        uint256 approvalAmount = 50 ether;

        // Abdullah approves himself to spend his own tokens
        vm.prank(Abdullah);
        ourToken.approve(Abdullah, approvalAmount);

        // Abdullah transfers tokens to Zain
        vm.prank(Abdullah);
        ourToken.transferFrom(Abdullah, Zain, approvalAmount);

        assertEq(ourToken.balanceOf(Zain), approvalAmount);
        assertEq(
            ourToken.balanceOf(Abdullah),
            STARTING_BALANCE - approvalAmount
        );
    }

    // Test transfer to address(0) should revert
    function testTransferToZeroAddress() public {
        vm.prank(Abdullah);
        vm.expectRevert();
        ourToken.transfer(address(0), 1 ether);
    }

    // Test minting new tokens
    function testMintTokens() public {
        uint256 mintAmount = 50 ether;

        // Mint new tokens to Abdullah's address
        vm.prank(msg.sender); // Only the deployer can mint
        ourToken.mint(Abdullah, mintAmount);

        assertEq(ourToken.balanceOf(Abdullah), STARTING_BALANCE + mintAmount);
    }

    // Test burning tokens
    function testBurnTokens() public {
        uint256 burnAmount = 10 ether;

        // Abdullah burns some of his tokens
        vm.prank(Abdullah);
        ourToken.burn(burnAmount);

        assertEq(ourToken.balanceOf(Abdullah), STARTING_BALANCE - burnAmount);
    }

    // Test total supply after minting and burning
    function testTotalSupply() public {
        uint256 initialSupply = ourToken.totalSupply();
        uint256 mintAmount = 50 ether;
        uint256 burnAmount = 10 ether;

        // Mint new tokens
        vm.prank(msg.sender);
        ourToken.mint(msg.sender, mintAmount);

        // Burn some tokens
        vm.prank(msg.sender);
        ourToken.burn(burnAmount);

        assertEq(
            ourToken.totalSupply(),
            initialSupply + mintAmount - burnAmount
        );
    }
}
