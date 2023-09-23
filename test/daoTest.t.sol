//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";
import {Box} from "src/Box.sol";
import {GovToken} from "src/GovToken.sol";
import {MyGovernor} from "src/MyGovernor.sol";
import {TimeLock} from "src/TimeLock.sol";
contract daoTest is Test {

Box box;
GovToken govToken;
MyGovernor myGovernor;
TimeLock timeLock;
address public USER = makeAddr("user");
uint256 public constant INITIAL_SUPPLY = 100 ether;
uint256 public  constant MIN_DELAY = 3600;
uint256 public constant VOTING_PERIOD = 50400; 
address[] proposers;
address[] executors;
uint256[] values;
bytes[] calldatas;
address[] targets;



function setUp() external  {
govToken = new GovToken();
govToken.mint(USER,INITIAL_SUPPLY);

vm.startPrank(USER);
govToken.delegate(USER);
timeLock = new TimeLock(MIN_DELAY, proposers, executors);

myGovernor = new MyGovernor(govToken,timeLock);
bytes32 proposerRole  = timeLock.PROPOSER_ROLE();
bytes32 executorRole = timeLock.EXECUTOR_ROLE();
bytes32 adminRole = timeLock.TIMELOCK_ADMIN_ROLE();

timeLock.grantRole(proposerRole, address(myGovernor));
timeLock.grantRole(executorRole,address(0));
timeLock.revokeRole(adminRole,USER);
vm.stopPrank();

box = new Box();
box.transferOwnership(address(timeLock));
}

function testCantUpdateBoxWithoutGovernance() public {
vm.expectRevert();
box.store(1);
}

function testGovernanceUpdateBox() public {
    uint256 valueToUpdate = 888;
    string memory description = "proposal to change number to 888";
    bytes memory encodeFunctionCall =  abi.encodeWithSignature("store(uint256)", valueToUpdate);
    values.push(0);
    calldatas.push(encodeFunctionCall);
    targets.push(address(box));

    uint256 proposalId = myGovernor.propose(targets,values,calldatas,description);
    console.log("Proposal State :",uint256(myGovernor.state(proposalId)));

    vm.warp(block.timestamp + 2);
    vm.warp(block.number + 2);

    console.log("Proposal State: ", uint256(myGovernor.state(proposalId)));

    string memory reason = "because i want to";
    uint8 voteWay = 1;
    vm.prank(USER);
    myGovernor.castVoteWithReason(proposalId, voteWay, reason);


}

}
