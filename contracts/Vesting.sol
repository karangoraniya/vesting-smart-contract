// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openZeppelin/contracts/contracts/security/ReentrancyGuard.sol";
import "@openZeppelin/contracts/access/Ownable.sol";

contract vesting {

    // Vesting 

    uint256 Advisor = 5;
    uint256 Partnerships = 0;
    uint256 Mentors = 7;
    uint256 deno = 100;

    struct vestingSchedule {
        uint256 duration;
    }

    function token() public {

    }


}