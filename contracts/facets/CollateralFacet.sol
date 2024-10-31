// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "../libraries/LibDiamondStorage.sol";
import "../interfaces/IERC721.sol";

contract CollateralFacet {
    using LibDiamondStorage for LibDiamondStorage.DiamondStorage;

    event CollateralDeposited(address nftContract, uint256 tokenId, address owner);
    event CollateralReleased(address nftContract, uint256 tokenId, address owner);

    function depositNFT(address _nftContract, uint256 _tokenId) external {
        IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);

        LibDiamondStorage.DiamondStorage storage ds = LibDiamondStorage.diamondStorage();
        ds.collateralData[msg.sender] = LibDiamondStorage.Collateral({
            nftContract: _nftContract,
            tokenId: _tokenId,
            owner: msg.sender,
            isCollateralized: true
        });

        emit CollateralDeposited(_nftContract, _tokenId, msg.sender);
    }

    function releaseCollateral(address _nftContract, uint256 _tokenId) external {
        LibDiamondStorage.DiamondStorage storage ds = LibDiamondStorage.diamondStorage();
        require(ds.collateralData[msg.sender].isCollateralized, "No collateral found");

        IERC721(_nftContract).transferFrom(address(this), msg.sender, _tokenId);
        delete ds.collateralData[msg.sender];

        emit CollateralReleased(_nftContract, _tokenId, msg.sender);
    }
}
