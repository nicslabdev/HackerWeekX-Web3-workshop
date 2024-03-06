// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import {Test, console} from "@forge-std/Test.sol";
import {Crowdfund} from "../src/Crowdfund.sol";

contract Crowdfund_Test is Test{
    Crowdfund public crowfundContract;

    address public owner = makeAddr("owner");
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");
    address public user3 = makeAddr("user3");
    address public user4 = makeAddr("user4");
    address public user5 = makeAddr("user5");


    /************************************** Modifiers **************************************/


    // Este modifier simula un escenario en el que 5 usuario van realizando inversiones.
    // Como resultado final:
    //      - user1 se convierte en el inversor mayoritario
    //      - En total se han invertido 1000 ether (STAKE_TARGET)
    modifier staking1000EtherScenario() {
        vm.prank(user1);
        crowfundContract.stake{value: 82 ether}();
        vm.prank(user2);
        crowfundContract.stake{value: 83 ether}();
        vm.prank(user3);
        crowfundContract.stake{value: 84 ether}();
        vm.prank(user4);
        crowfundContract.stake{value: 85 ether}();
        vm.prank(user5);
        crowfundContract.stake{value: 86 ether}();
        vm.prank(user1);
        crowfundContract.stake{value: 90 ether}();
        vm.prank(user2);
        crowfundContract.stake{value: 96 ether}();
        vm.prank(user3);
        crowfundContract.stake{value: 97 ether}();
        vm.prank(user4);
        crowfundContract.stake{value: 98 ether}();
        vm.prank(user5);
        crowfundContract.stake{value: 99 ether}();
        vm.prank(user1);
        crowfundContract.stake{value: 100 ether}();
        
        _;
    }


    /**************************************** Set Up ***************************************/


    // La función setUp() es ejecutada antes de cada test para establecer el escenario inicial
    function setUp() public {
        // Aumentamos el balance de cada usuario
        vm.deal(owner, 1000 ether);
        vm.deal(user1, 1000 ether);
        vm.deal(user2, 1000 ether);
        vm.deal(user3, 1000 ether);
        vm.deal(user4, 1000 ether);
        vm.deal(user5, 1000 ether);

        // El owner despliega el contrato
        vm.prank(owner);
        crowfundContract = new Crowdfund();
    }


    /***************************************** Test ****************************************/


    function test_setUp() public {
        assertEq(crowfundContract.STAKE_TARGET(), 1000 ether, "Incorrect STAKE_TARGET");
        assertEq(uint(crowfundContract.MAX_ADDMISIBLE_STAKE_INCREASE()), uint(100), "Incorrect MAX_ADDMISIBLE_STAKE_INCREASE");
        assertEq(uint(crowfundContract.MIN_ADDMISIBLE_STAKE_INCREASE()), 2, "Incorrect MIN_ADDMISIBLE_STAKE_INCREASE");
        assertEq(uint(crowfundContract.stakes(owner)), 1, "Incorrect stakes");
        assertEq(uint(crowfundContract.maxStake()), 1, "Incorrect maxStake");
        assertEq(crowfundContract.getTotalStake(), 0 ether, "Incorrect getTotalStake");
        assertEq(crowfundContract.leadInvestor(), owner, "Incorrect leadInvestor");
    }


    //---------------------------------------------------------------------------------------


    function test_stake() public {
        vm.prank(user1);
        crowfundContract.stake{value: 5 ether}();

        assertEq(uint(crowfundContract.stakes(user1)), 5, "Incorrect stakes");
        assertEq(uint(crowfundContract.maxStake()), 5, "Incorrect maxStake");
        assertEq(crowfundContract.getTotalStake(), 5 ether, "Incorrect getTotalStake");
        assertEq(crowfundContract.leadInvestor(), user1, "Incorrect leadInvestor");
    }

    function test_stake_RevertIf_OwnerIsStaking() public { 
        vm.prank(owner);
        vm.expectRevert(unicode"El dueño no puede invertir");
        crowfundContract.stake{value: 5 ether}();
    }

    function test_stake_RevertIf_CrowdfundIsClosed() staking1000EtherScenario() public {
        vm.prank(owner);
        crowfundContract.closeFund();

        vm.prank(user1);
        vm.expectRevert(unicode"La inversión está cerrada");
        crowfundContract.stake{value: 5 ether}();
    }

    function test_stake_RevertIf_CallerIsLeadInvestor() public {
        vm.prank(user1);
        crowfundContract.stake{value: 20 ether}();

        vm.prank(user1);
        vm.expectRevert(unicode"Tú ya eras el inversor mayoritario");
        crowfundContract.stake{value: 5 ether}();
    }

    function test_stake_RevertIf_StakeIncreaseIsNotMultipleOf1Ether() public {
        vm.prank(user1);
        vm.expectRevert(unicode"Solo se aceptan incrementos múltiplos de 1 ether");
        crowfundContract.stake{value: 5.5 ether}();
    }

    function test_stake_RevertIf_StakeIncreaseIsGreaterThanMaxAddmissible() public {
        vm.prank(user1);
        vm.expectRevert(unicode"Tu incremento de inversión no está en el rango");
        crowfundContract.stake{value: 101 ether}();
    }

    function test_stake_RevertIf_StakeIncreaseIsLowerThanMinAddmissible() public {
        vm.prank(user1);
        vm.expectRevert(unicode"Tu incremento de inversión no está en el rango");
        crowfundContract.stake{value: 1 ether}();
    }

    
    //---------------------------------------------------------------------------------------


    function test_closeFund() public staking1000EtherScenario() {
        uint contractBalanceBefore = crowfundContract.getTotalStake();
        uint ownerBalanceBefore = address(owner).balance;
        vm.prank(owner);
        crowfundContract.closeFund();
        uint contractBalanceAfter = crowfundContract.getTotalStake();

        assertEq(contractBalanceBefore, 1000 ether, "Incorrect balanceBefore");
        assertEq(contractBalanceAfter, 100 ether, "Incorrect balanceAfter");  
        assertEq(address(owner).balance, ownerBalanceBefore + 900 ether, "Incorrect ownerBalance");
    }

    function test_closeFund_RevertIf_CallerIsNotOwner() public {
        vm.prank(user1);
        vm.expectRevert(unicode"Tú no eres el owner");
        crowfundContract.closeFund();
    }

    function test_closeFund_RevertIf_CrowdfundIsClosed() staking1000EtherScenario() public {
        vm.prank(owner);
        crowfundContract.closeFund();

        vm.prank(owner);
        vm.expectRevert(unicode"El crowdfunding no está abierto");
        crowfundContract.closeFund();
    }

    function test_closeFund_RevertIf_TargetHasNotBeenReached() public {
        vm.prank(user1);
        crowfundContract.stake{value: 50 ether}();

        vm.prank(owner);
        vm.expectRevert(unicode"No se ha superado el target de inversión");
        crowfundContract.closeFund();
    }

    
    //---------------------------------------------------------------------------------------


    function test_withdraw() public staking1000EtherScenario() {
        vm.prank(owner);
        crowfundContract.closeFund();

        uint leadInvestorBalanceBefore = address(user1).balance;
        vm.prank(user1);
        crowfundContract.withdraw();

        assertEq(address(user1).balance, leadInvestorBalanceBefore + 100 ether, "Incorrect balanceAfter");  
    }

    function test_withdraw_RevertIf_CrowdfundIsNotClosed() public {
        vm.prank(user1);
        vm.expectRevert(unicode"El crowdfunding no está cerrado");
        crowfundContract.withdraw();
    } 

    function test_withdraw_RevertIf_CallerIsNotLeadInvestor() staking1000EtherScenario() public {
        vm.prank(owner);
        crowfundContract.closeFund();

        vm.prank(user2);
        vm.expectRevert(unicode"Tú no eres el inversor mayoritario");
        crowfundContract.withdraw();
    }
}