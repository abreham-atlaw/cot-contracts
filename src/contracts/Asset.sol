// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Profile.sol";
import "./Roles.sol";

contract Asset {

    struct AssetStruct {
        string id;
        string name;
        string categoryId;
        string[] ownersId;
        string orgId;
        bool is_active;
    }

    mapping(string => uint) public idMap;
    AssetStruct[] assets;
    uint assetCount;

    Profile profileContract;

    constructor(address _profileContractAddress) {
        profileContract = Profile(_profileContractAddress); 
    }

    function create(string memory _id, string memory _name, string memory _categoryId, string[] memory _ownersId, string memory _orgId) public {
        assets.push(AssetStruct(_id, _name, _categoryId, _ownersId, _orgId, true)); // is_active is true by default
        idMap[_id] = assetCount;
        assetCount++;
    }

    function getById(string memory _id) public view returns (AssetStruct memory) {
        uint idx = idMap[_id];
        AssetStruct memory asset = assets[idx];
        return asset;
    }

    function getAll() public view returns (AssetStruct[] memory) {
        uint activeCount = 0;
        for (uint i = 0; i < assetCount; i++) {
            if (assets[i].is_active) {
                activeCount++;
            }
        }

        AssetStruct[] memory activeAssets = new AssetStruct[](activeCount);
        uint j = 0;
        for (uint i = 0; i < assetCount; i++) {
            if (assets[i].is_active) {
                activeAssets[j] = assets[i];
                j++;
            }
        }
        return activeAssets;
    }

    function deleteInstance(string memory _id) public {
        uint idx = idMap[_id];
        assets[idx].is_active = false;
    }

    function update(string memory _id, string memory _name, string memory _categoryId, string[] memory _ownersId, string memory _orgId) public {
        uint idx = idMap[_id];
        AssetStruct storage asset = assets[idx];
        Profile.ProfileStruct memory userProfile = profileContract.getByUserKey(msg.sender);
        require(userProfile.role == Roles.Role.admin || userProfile.role == Roles.Role.inventory || keccak256(abi.encodePacked((userProfile.id))) == keccak256(abi.encodePacked((asset.ownersId[asset.ownersId.length - 1]))), "Access Denied");
        asset.id = _id;
        asset.name = _name;
        asset.categoryId = _categoryId;
        asset.ownersId = _ownersId;
        asset.orgId = _orgId;
    }
}
