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

    function checkPermission() private view {
        Profile.ProfileStruct memory userProfile = profileContract.getByUserKey(msg.sender);
        require(
            userProfile.role == Roles.Role.admin ||
			userProfile.role == Roles.Role.inventory,
            "Access Denied"
        );
    }

    function findOwnerIndex(string memory _assetId, string memory _userId) private view returns (string memory) {
        uint idx = idMap[_assetId];
        AssetStruct memory asset = assets[idx];
        for (uint i = 0; i < asset.ownersId.length; i++) {
            if (keccak256(abi.encodePacked(asset.ownersId[i])) == keccak256(abi.encodePacked(_userId))) {
                return asset.ownersId[i];
            }
        }
        revert("User is not an owner of the Asset");
    }

    function create(string memory _id, string memory _name, string memory _categoryId, string[] memory _ownersId, string memory _orgId) public {
		AssetStruct memory instance = AssetStruct(_id, _name, _categoryId, _ownersId, _orgId, true);
		checkPermission();
        assets.push(instance); // is_active is true by default
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
		checkPermission();
        assets[idx].is_active = false;
    }

    function update(string memory _id, string memory _name, string memory _categoryId, string[] memory _ownersId, string memory _orgId) public {

        uint idx = idMap[_id];
        AssetStruct storage asset = assets[idx];
        checkPermission();
		asset.name = _name;
        asset.categoryId = _categoryId;
        asset.ownersId = _ownersId;
        asset.orgId = _orgId;
    }
}
