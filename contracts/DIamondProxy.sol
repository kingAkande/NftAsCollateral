// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "../contracts/libraries/LibDiamondStorage.sol";

contract DiamondProxy {

    using LibDiamondStorage for LibDiamondStorage.DiamondStorage;

    constructor(address _owner) {
        LibDiamondStorage.DiamondStorage storage ds = LibDiamondStorage.diamondStorage();
        ds.contractOwner = _owner;
    }

    fallback() external payable {
        LibDiamondStorage.DiamondStorage storage ds = LibDiamondStorage.diamondStorage();
        address facet = ds.facetAddress[msg.sig];
        require(facet != address(0), "Function does not exist");

        (bool success, bytes memory result) = facet.delegatecall(msg.data);
        require(success, "Facet call failed");

        assembly {
            return(add(result, 32), mload(result))
        }
    }

    function addFacet(address _facet, bytes4[] memory _selectors) external onlyOwner {
        LibDiamondStorage.DiamondStorage storage ds = LibDiamondStorage.diamondStorage();
        for (uint256 i = 0; i < _selectors.length; i++) {
            ds.facetAddress[_selectors[i]] = _facet;
        }
    }

    modifier onlyOwner() {
        require(msg.sender == LibDiamondStorage.diamondStorage().contractOwner, "Not owner");
        _;
    }

    
}
