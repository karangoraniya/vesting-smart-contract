// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Vesting is Ownable,ReentrancyGuard {

   // Vesting 

    uint256 Advisor = 5;
    uint256 Partnerships = 10;
    uint256 Mentors = 9;
    uint256 deno = 100;

    // 100000000

    IERC20 private token;
    address private beneficiary;
    uint256 private totalTokens;
    uint256 private start;
    uint256 private cliff;
    uint256 private duration;
    bool public vestingStarted;

    // tokens holder

    uint256 public perAdvisorTokens;
    uint256 public perPartnershipTokens;
    uint256 public perMentorsTokens;

    // tokens holder

    uint256 public totalAdvisors;
    uint256 public totalPartnerships;
    uint256 public totalMentors;

    // start date & end date

    uint256 lastUpdated;
    // uint startTime = 1654043400; // 2022-06-01 06:00:00
    uint startTime;
    uint endTime = 1685579400;  // 2023-06-01 06:00:00

    enum Roles {
        advisor,
        partnership,
        mentor
    }

    Roles private role;

    struct Beneficiary {
        uint8 role;
        bool isBeneficiary;
        uint256 tokenClaim;
        uint256 lastClaim;
    }

    mapping(address => Beneficiary) beneficiaryMap;
    
    constructor (address _token) {
        token = IERC20(_token);
    }

    event AddBeneficiary(address beneficiary, uint8 role);

    /*
     
    */
    
    function addBeneficiary(address _beneficiary, uint8 _role) external onlyOwner {
        require(beneficiaryMap[_beneficiary].isBeneficiary == false, 'already you are added');
        require(_role < 3, 'roles are not available');
        require(vestingStarted == false, 'vesting started');
        beneficiaryMap[_beneficiary].role = _role;
        beneficiaryMap[_beneficiary].isBeneficiary = true;

        emit AddBeneficiary(_beneficiary, _role);

        if (_role == 0) {
            totalAdvisors++;
        } else if (_role == 1) {
            totalPartnerships++;
        } else {
            totalMentors++;
        }
    }


    function startVesting(uint256 _cliff, uint256 _duration) external onlyOwner {
        require(vestingStarted == false, 'vesting started');
        totalTokens = token.balanceOf(address(this));
        cliff = _cliff;
        duration = _duration;
        vestingStarted = true;
        startTime = block.timestamp;
        tokenCalculate();
    }

    function tokenCalculate() private {
        perAdvisorTokens = totalTokens  * Advisor  / deno * totalAdvisors;
        perPartnershipTokens = totalTokens * Partnerships / deno * totalPartnerships;
        perMentorsTokens = totalTokens * Mentors / deno * totalMentors;
    }

    function tokenStatus() private view returns(uint256) {
        uint8 roleCheck = beneficiaryMap[msg.sender].role;
        uint256 tokenAvailable;
        uint256 claimTokens = beneficiaryMap[msg.sender].tokenClaim;

        uint256 timeStatus = block.timestamp - startTime - cliff;


        if (roleCheck == 0) {
            if (timeStatus >= duration) {
                tokenAvailable = perAdvisorTokens;
            } else {
           tokenAvailable = perAdvisorTokens * timeStatus / duration ;
            }
        } else if (roleCheck == 1) {
            if (timeStatus >= duration) {
                tokenAvailable = perPartnershipTokens;
            } else {
            tokenAvailable = perPartnershipTokens * timeStatus / duration ;
            }
        } else {
            if (timeStatus >= duration) {
                tokenAvailable = perMentorsTokens;
            } else {
            tokenAvailable = (perMentorsTokens * timeStatus) / duration ;
            }
        }
        return tokenAvailable - claimTokens;
    }


    function claimToken() external nonReentrant {
        require(vestingStarted == true, 'vesting not strated');
        require(beneficiaryMap[msg.sender].isBeneficiary == true, 'You are not beneficiary');
        require(block.timestamp >= cliff + startTime, 'vesting is in cliff period');
        require(block.timestamp - beneficiaryMap[msg.sender].lastClaim > 2629743,'already claim within last month');
        uint8 roleCheck = beneficiaryMap[msg.sender].role;
        uint256 claimedToken = beneficiaryMap[msg.sender].tokenClaim;
        

        if (roleCheck == 0) {
            require(claimedToken < perAdvisorTokens, 'you have claim all Tokens');
        } else if (roleCheck == 1) {
            require(claimedToken < perPartnershipTokens, 'you have claim all Tokens');

        } else {
            require(claimedToken < perMentorsTokens, 'you have claim all Tokens');

        }
        uint256 tokens = tokenStatus();
        //2629743

        token.transfer(msg.sender, tokens);
        beneficiaryMap[msg.sender].lastClaim = block.timestamp;
        beneficiaryMap[msg.sender].tokenClaim += tokens;
    }

}