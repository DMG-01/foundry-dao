//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
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
address[] proposers;
address[] executors;


function setUp() external  {
govToken = new GovToken();
govToken.mint(USER,INITIAL_SUPPLY);

vm.startPrank(USER);
govToken.delegate(USER);
timeLock = new TimeLock(MIN_DELAY, proposers, executors);

myGovernor = new MyGovernor(govToken,timeLock);
}
}