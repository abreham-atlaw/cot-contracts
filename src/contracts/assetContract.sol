// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

contract Asset {
    struct AssetStruct {
        string id;
        string name;
        string categoryId;
        string[] ownersId;
        string orgId;
    }

    mapping(string => uint) public idMap;
    AssetStruct[] assets;
    uint assetCount;

    function create(string memory _id, string memory _name, string memory _categoryId, string[] memory _ownersId, string memory _orgId) public {
        assets.push(AssetStruct(_id, _name, _categoryId, _ownersId, _orgId));
        idMap[_id] = assetCount;
        assetCount++;
    }

    function getById(string memory _id) public view returns (AssetStruct memory) {
        uint idx = idMap[_id];
        AssetStruct memory asset = assets[idx];
        return asset;
    }

    function getAll() public view returns (AssetStruct[] memory) {
        return assets;
    }

    function update(string memory _id, string memory _name, string memory _categoryId, string[] memory _ownersId, string memory _orgId) public {
        uint idx = idMap[_id];
        AssetStruct storage asset = assets[idx];
        asset.id = _id;
        asset.name = _name;
        asset.categoryId = _categoryId;
        asset.ownersId = _ownersId;
        asset.orgId = _orgId;
    }
}
