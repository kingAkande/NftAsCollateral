// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "../libraries/LibDiamondStorage.sol";

contract PaymentFacet {
    using LibDiamondStorage for LibDiamondStorage.DiamondStorage;

    event LoanRepaid(uint256 loanId, address borrower, uint256 amount);

    function repayLoan(uint256 _loanId) external payable {
        LibDiamondStorage.DiamondStorage storage ds = LibDiamondStorage.diamondStorage();
        LibDiamondStorage.Loan storage loan = ds.loans[_loanId];

        require(loan.status == LibDiamondStorage.LoanStatus.Active, "Loan is not active");
        require(loan.borrower == msg.sender, "Not the borrower");

        uint256 repaymentAmount = calculateRepayment(loan);
        require(msg.value >= repaymentAmount, "Insufficient repayment amount");

        loan.status = LibDiamondStorage.LoanStatus.Repaid;

        // Transfer the repayment to the lender
        payable(loan.lender).transfer(repaymentAmount);

        emit LoanRepaid(_loanId, msg.sender, repaymentAmount);
    }

    function calculateRepayment(LibDiamondStorage.Loan memory loan) public view returns (uint256) {
        uint256 elapsedTime = block.timestamp - loan.startTime;
        uint256 interest = (loan.loanAmount * loan.interestRate * elapsedTime) / (365 days * 100);
        return loan.loanAmount + interest;
    }
}
