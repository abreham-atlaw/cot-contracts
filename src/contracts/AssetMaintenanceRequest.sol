// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Profile.sol";
import "./Roles.sol";

contract AssetMaintenanceRequest {
    struct AssetMaintenanceRequestStruct {
        string id;
        string assetId;
        string note;
        uint status;
        string image;
        string userId;
        uint256 createDatetime; // Add createDatetime field
        bool is_active;
    }

    mapping(string => uint) public idMap;
    AssetMaintenanceRequestStruct[] assetMaintenanceRequests;
    uint assetMaintenanceRequestCount;

    Profile profileContract;

    constructor(address _profileContractAddress) {
        profileContract = Profile(_profileContractAddress);
    }

    function checkPermission(AssetMaintenanceRequestStruct memory _instance) private view returns (Profile.ProfileStruct memory) {
        Profile.ProfileStruct memory userProfile = profileContract.getByUserKey(msg.sender);
        require(
            (
                userProfile.role == Roles.Role.admin || 
                userProfile.role == Roles.Role.maintainer || 
                (
                    keccak256(abi.encodePacked((userProfile.id))) == keccak256(abi.encodePacked(_instance.userId)) &&
                    _instance.status == 0
                )
            ),
            "Access Denied"
        );
        return userProfile;
    }

    function create(
        string memory _id,
        string memory _assetId,
        string memory _note,
        uint _status,
        string memory _image,
        string memory _userId
    ) public {
        AssetMaintenanceRequestStruct memory instance = AssetMaintenanceRequestStruct(
            _id, 
            _assetId, 
            _note, 
            _status, 
            _image, 
            _userId, 
            block.timestamp, // Set creation timestamp
            true
        );
        checkPermission(instance);
        assetMaintenanceRequests.push(instance);
        idMap[_id] = assetMaintenanceRequestCount;
        assetMaintenanceRequestCount++;
    }

    function getById(string memory _id) public view returns (AssetMaintenanceRequestStruct memory) {
        uint idx = idMap[_id];
        AssetMaintenanceRequestStruct memory assetMaintenanceRequest = assetMaintenanceRequests[idx];
        return assetMaintenanceRequest;
    }

    function getAll() public view returns (AssetMaintenanceRequestStruct[] memory) {
        uint activeCount = 0;
        for (uint i = 0; i < assetMaintenanceRequestCount; i++) {
            if (assetMaintenanceRequests[i].is_active) {
                activeCount++;
            }
        }

        AssetMaintenanceRequestStruct[] memory activeAssetMaintenanceRequests = new AssetMaintenanceRequestStruct[](activeCount);
        uint j = 0;
        for (uint i = 0; i < assetMaintenanceRequestCount; i++) {
            if (assetMaintenanceRequests[i].is_active) {
                activeAssetMaintenanceRequests[j] = assetMaintenanceRequests[i];
                j++;
            }
        }
        return activeAssetMaintenanceRequests;
    }

    function update(
        string memory _id,
        string memory _assetId,
        string memory _note,
        uint _status,
        string memory _image,
        string memory _userId
    ) public {
        uint idx = idMap[_id];
        AssetMaintenanceRequestStruct storage instance = assetMaintenanceRequests[idx];
        Profile.ProfileStruct memory profile = checkPermission(instance);
        if (keccak256(abi.encodePacked((profile.id))) == keccak256(abi.encodePacked(instance.userId))) {
            instance.assetId = _assetId;
            instance.note = _note;
            instance.image = _image;
        }
        if (profile.role == Roles.Role.admin || profile.role == Roles.Role.maintainer) {
            instance.status = _status;
        }
    }

    function deleteInstance(string memory _id) public {
        uint idx = idMap[_id];
        checkPermission(assetMaintenanceRequests[idx]);
        assetMaintenanceRequests[idx].is_active = false; 
    }
}
