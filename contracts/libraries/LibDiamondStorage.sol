// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library LibDiamondStorage {
    
    struct Loan {
        uint256 loanId;
        address borrower;
        address lender;
        uint256 loanAmount;
        uint256 collateralId;
        address collateralContract;
        uint256 duration;
        uint256 interestRate;
        uint256 startTime;
        LoanStatus status;
    }

    struct Collateral {
        address nftContract;
        uint256 tokenId;
        address owner;
        bool isCollateralized;
    }

    enum LoanStatus { Active, Repaid, Defaulted }

    struct DiamondStorage {
        mapping(bytes4 => address) facetAddress; // Function selector to facet mapping
        mapping(uint256 => Loan) loans; // Loan data
        mapping(address => Collateral) collateralData; // Collateral NFT data
        uint256 loanCounter; // Counter to generate unique loan IDs
        address contractOwner; // Owner of the proxy
    }

    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.storage");

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
