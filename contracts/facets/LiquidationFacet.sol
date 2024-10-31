// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "../libraries/LibDiamondStorage.sol";
import "../interfaces/IERC721.sol";

contract LiquidationFacet {
    using LibDiamondStorage for LibDiamondStorage.DiamondStorage;

    event LoanDefaulted(uint256 loanId, address lender, address nftContract, uint256 tokenId);

    function liquidateLoan(uint256 _loanId) external {
        LibDiamondStorage.DiamondStorage storage ds = LibDiamondStorage.diamondStorage();
        LibDiamondStorage.Loan storage loan = ds.loans[_loanId];

        require(loan.status == LibDiamondStorage.LoanStatus.Active, "Loan is not active");
        require(block.timestamp > loan.startTime + loan.duration, "Loan duration not yet over");
        require(msg.sender == loan.lender, "Only lender can liquidate");

        loan.status = LibDiamondStorage.LoanStatus.Defaulted;

        // Seize the collateral NFT
        LibDiamondStorage.Collateral storage collateral = ds.collateralData[loan.borrower];
        require(collateral.isCollateralized, "No collateral found");

        IERC721(collateral.nftContract).transferFrom(address(this), msg.sender, collateral.tokenId);
        collateral.isCollateralized = false;

        emit LoanDefaulted(_loanId, msg.sender, collateral.nftContract, collateral.tokenId);
    }
}
