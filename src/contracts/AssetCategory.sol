// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Profile.sol";
import "./Roles.sol";

contract AssetCategory {

    struct AssetCategoryStruct {
        string id;
        string name;
        string orgId;
        string parentCategoryId;
        uint256 createDatetime; // Add createDatetime field
        bool is_active; // Add is_active field
    }

    mapping(string => uint) public idMap;
    AssetCategoryStruct[] assetCategories;
    uint assetCategoryCount;

    Profile profileContract;

    constructor(address _profileContractAddress) {
        profileContract = Profile(_profileContractAddress);
    }

    modifier onlyAuthorized() {
        Profile.ProfileStruct memory userProfile = profileContract.getByUserKey(msg.sender);
        require(
            userProfile.role == Roles.Role.admin || userProfile.role == Roles.Role.inventory,
            "Access Denied"
        );
        _;
    }

    function create(
        string memory _id,
        string memory _name,
        string memory _orgId,
        string memory _parentCategoryId
    ) public onlyAuthorized {
        assetCategories.push(
            AssetCategoryStruct(_id, _name, _orgId, _parentCategoryId, block.timestamp, true)
        ); // Set is_active to true and record creation timestamp
        idMap[_id] = assetCategoryCount;
        assetCategoryCount++;
    }

    function getById(string memory _id) public view returns (AssetCategoryStruct memory) {
        uint idx = idMap[_id];
        AssetCategoryStruct memory assetCategory = assetCategories[idx];
        return assetCategory;
    }

    function getAll() public view returns (AssetCategoryStruct[] memory) {
        uint activeCount = 0;
        for (uint i = 0; i < assetCategoryCount; i++) {
            if (assetCategories[i].is_active) {
                activeCount++;
            }
        }

        AssetCategoryStruct[] memory activeAssetCategories = new AssetCategoryStruct[](activeCount);
        uint j = 0;
        for (uint i = 0; i < assetCategoryCount; i++) {
            if (assetCategories[i].is_active) {
                activeAssetCategories[j] = assetCategories[i];
                j++;
            }
        }
        return activeAssetCategories;
    }

    function update(
        string memory _id,
        string memory _name,
        string memory _orgId,
        string memory _parentCategoryId
    ) public onlyAuthorized {
        uint idx = idMap[_id];
        AssetCategoryStruct storage assetCategory = assetCategories[idx];
        assetCategory.name = _name;
        assetCategory.orgId = _orgId;
        assetCategory.parentCategoryId = _parentCategoryId;
    }

    function deleteInstance(string memory _id) public onlyAuthorized {
        uint idx = idMap[_id];
        assetCategories[idx].is_active = false; 
    }
}
