// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import {Test, console} from "@forge-std/Test.sol";
import {Crowdfund} from "../src/Crowdfund.sol";

contract Crowdfund_Test is Test{
    Crowdfund public crowfundContract;

    uint constant DECIMALS = 10**15;

    address public owner = makeAddr("owner");
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");
    address public user3 = makeAddr("user3");
    address public user4 = makeAddr("user4");
    address public user5 = makeAddr("user5");


    /************************************** Modifiers **************************************/


    // Este modifier simula un escenario en el que 5 usuarios realizan inversiones.
    // Como resultado final:
    //      - user1 se convierte en el inversor mayoritario
    //      - En total se han invertido 1000 finney == 1000 * 10**15 wei == 1 ether (STAKE_TARGET)
    modifier staking1000FinneyScenario() {
        vm.prank(user1);
        crowfundContract.stake{value: 82 * DECIMALS}();
        vm.prank(user2);
        crowfundContract.stake{value: 83 * DECIMALS}();
        vm.prank(user3);
        crowfundContract.stake{value: 84 * DECIMALS}();
        vm.prank(user4);
        crowfundContract.stake{value: 85 * DECIMALS}();
        vm.prank(user5);
        crowfundContract.stake{value: 86 * DECIMALS}();
        vm.prank(user1);
        crowfundContract.stake{value: 90 * DECIMALS}();
        vm.prank(user2);
        crowfundContract.stake{value: 96 * DECIMALS}();
        vm.prank(user3);
        crowfundContract.stake{value: 97 * DECIMALS}();
        vm.prank(user4);
        crowfundContract.stake{value: 98 * DECIMALS}();
        vm.prank(user5);
        crowfundContract.stake{value: 99 * DECIMALS}();
        vm.prank(user1);
        crowfundContract.stake{value: 100 * DECIMALS}();
        
        _;
    }


    /**************************************** Set Up ***************************************/


    // La función setUp() es ejecutada antes de cada test para establecer el escenario inicial
    function setUp() public {
        // Aumentamos el balance de cada usuario
        // La unidad por defecto es el wei, por lo que 1 ether = 1000 finney = 1e18 wei 
        // Como DECIMALS es 10**15, estamos asignando 300 finney a cada usuario
        vm.deal(owner, 300 * DECIMALS);
        vm.deal(user1, 300 * DECIMALS);
        vm.deal(user2, 300 * DECIMALS);
        vm.deal(user3, 300 * DECIMALS);
        vm.deal(user4, 300 * DECIMALS);
        vm.deal(user5, 300 * DECIMALS);

        // El owner despliega el contrato
        vm.prank(owner);
        crowfundContract = new Crowdfund();
    }


    /***************************************** Test ****************************************/


    function test_setUp() public {
        assertEq(crowfundContract.STAKE_TARGET(), 1000, "Incorrect STAKE_TARGET");
        assertEq(uint(crowfundContract.MAX_ADMISSIBLE_STAKE_INCREASE()), 100, "Incorrect MAX_ADDMISIBLE_STAKE_INCREASE");
        assertEq(uint(crowfundContract.MIN_ADMISSIBLE_STAKE_INCREASE()), 2, "Incorrect MIN_ADDMISIBLE_STAKE_INCREASE");
        assertEq(uint(crowfundContract.stakes(owner)), 1, "Incorrect stakes");
        assertEq(uint(crowfundContract.maxStake()), 1, "Incorrect maxStake");
        assertEq(crowfundContract.getTotalStake(), 0, "Incorrect getTotalStake");
        assertEq(crowfundContract.leadInvestor(), owner, "Incorrect leadInvestor");
    }


    //---------------------------------------------------------------------------------------


    function test_stake() public {
        vm.prank(user1);
        crowfundContract.stake{value: 5 * DECIMALS}();

        assertEq(uint(crowfundContract.stakes(user1)), 5, "Incorrect stakes");
        assertEq(uint(crowfundContract.maxStake()), 5, "Incorrect maxStake");
        assertEq(crowfundContract.getTotalStake(), 5 * DECIMALS, "Incorrect getTotalStake");
        assertEq(crowfundContract.leadInvestor(), user1, "Incorrect leadInvestor");
    }

    function test_stake_RevertIf_OwnerIsStaking() public { 
        vm.prank(owner);
        vm.expectRevert(unicode"El dueño no puede invertir");
        crowfundContract.stake{value: 5 * DECIMALS}();
    }

    function test_stake_RevertIf_CrowdfundIsClosed() staking1000FinneyScenario() public {
        vm.prank(owner);
        crowfundContract.closeFund();

        vm.prank(user1);
        vm.expectRevert(unicode"La inversión está cerrada");
        crowfundContract.stake{value: 5 * DECIMALS}();
    }

    function test_stake_RevertIf_StakeIncreaseIsNotMultipleOfFinney() public {
        vm.prank(user1);
        vm.expectRevert(unicode"Solo se aceptan incrementos múltiplos de 1 finney");
        crowfundContract.stake{value: 55 * 10**14}();
    }

    function test_stake_RevertIf_StakeIncreaseIsGreaterThanMaxAdmissible() public {
        vm.prank(user1);
        vm.expectRevert(unicode"Tu incremento de inversión no está en el rango");
        crowfundContract.stake{value: 101 * DECIMALS}();
    }

    function test_stake_RevertIf_StakeIncreaseIsLowerThanMinAdmissible() public {
        vm.prank(user1);
        vm.expectRevert(unicode"Tu incremento de inversión no está en el rango");
        crowfundContract.stake{value: 1 * DECIMALS}();
    }

    
    //---------------------------------------------------------------------------------------


    function test_closeFund() public staking1000FinneyScenario() {
        uint contractBalanceBefore = crowfundContract.getTotalStake();
        uint ownerBalanceBefore = address(owner).balance;
        vm.prank(owner);
        crowfundContract.closeFund();
        uint contractBalanceAfter = crowfundContract.getTotalStake();

        assertEq(contractBalanceBefore, 1000 * DECIMALS, "Incorrect balanceBefore");
        assertEq(contractBalanceAfter, 100 * DECIMALS, "Incorrect balanceAfter");  
        assertEq(address(owner).balance, ownerBalanceBefore + 900 * DECIMALS, "Incorrect ownerBalance");
    }

    function test_closeFund_RevertIf_CallerIsNotOwner() public {
        vm.prank(user1);
        vm.expectRevert(unicode"Tú no eres el owner");
        crowfundContract.closeFund();
    }

    function test_closeFund_RevertIf_CrowdfundIsClosed() staking1000FinneyScenario() public {
        vm.prank(owner);
        crowfundContract.closeFund();

        vm.prank(owner);
        vm.expectRevert(unicode"El crowdfunding no está abierto");
        crowfundContract.closeFund();
    }

    function test_closeFund_RevertIf_TargetHasNotBeenReached() public {
        vm.prank(user1);
        crowfundContract.stake{value: 50 * DECIMALS}();

        vm.prank(owner);
        vm.expectRevert(unicode"No se ha superado el target de inversión");
        crowfundContract.closeFund();
    }

    
    //---------------------------------------------------------------------------------------


    function test_withdraw() public staking1000FinneyScenario() {
        vm.prank(owner);
        crowfundContract.closeFund();

        uint leadInvestorBalanceBefore = address(user1).balance;
        vm.prank(user1);
        crowfundContract.withdraw();

        assertEq(address(user1).balance, leadInvestorBalanceBefore + 100 * DECIMALS, "Incorrect balanceAfter");  
    }

    function test_withdraw_RevertIf_CrowdfundIsNotClosed() public {
        vm.prank(user1);
        vm.expectRevert(unicode"El crowdfunding no está cerrado");
        crowfundContract.withdraw();
    } 

    function test_withdraw_RevertIf_CallerIsNotLeadInvestor() staking1000FinneyScenario() public {
        vm.prank(owner);
        crowfundContract.closeFund();

        vm.prank(user2);
        vm.expectRevert(unicode"Tú no eres el inversor mayoritario");
        crowfundContract.withdraw();
    }
}