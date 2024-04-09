// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

contract AssetCategoryContract {
    struct AssetCategoryStruct {
        string name;
        string id;
        string orgId;
    }

    mapping(string => uint) public idMap;
    AssetCategoryStruct[] assetCategories;
    uint assetCategoryCount;

    function create(string memory _name, string memory _id, string memory _orgId) public {
        assetCategories.push(AssetCategoryStruct(_name, _id, _orgId));
        idMap[_id] = assetCategoryCount;
        assetCategoryCount++;
    }

    function getById(string memory _id) public view returns (AssetCategoryStruct memory) {
        uint idx = idMap[_id];
        AssetCategoryStruct memory assetCategory = assetCategories[idx];
        return assetCategory;
    }

    function getAll() public view returns (AssetCategoryStruct[] memory) {
        return assetCategories;
    }

    function update(string memory _id, string memory _name, string memory _orgId) public {
        uint idx = idMap[_id];
        AssetCategoryStruct storage assetCategory = assetCategories[idx];
        assetCategory.name = _name;
        assetCategory.orgId = _orgId;
    }
}
