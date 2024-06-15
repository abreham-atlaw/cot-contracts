// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Profile.sol";
import "./Roles.sol";

contract AssetRequest {
    struct AssetRequestStruct {
        string id;
        string categoryId;
        string note;
        uint status;
        string userId;
        uint departmentStatus;
        string rejectionNote;
        uint256 createDatetime; // Add createDatetime field
        bool is_active;
    }

    mapping(string => uint) public idMap;
    AssetRequestStruct[] assetRequests;
    uint assetRequestCount;

    Profile profileContract;

    constructor(address _profileContractAddress) {
        profileContract = Profile(_profileContractAddress);
    }

    function checkPermission(AssetRequestStruct memory _instance) private view returns (Profile.ProfileStruct memory){
        Profile.ProfileStruct memory userProfile = profileContract.getByUserKey(msg.sender);
        require(
            (
                userProfile.role == Roles.Role.admin || 
                userProfile.role == Roles.Role.inventory || 
                (
                    userProfile.role == Roles.Role.department &&
                    _instance.status == 0
                ) ||
                (
                    keccak256(abi.encodePacked((userProfile.id))) == keccak256(abi.encodePacked(_instance.userId)) &&
                    _instance.departmentStatus == 0
                )
            ),
            "Access Denied"
        );
        return userProfile;
    }

    function create(
        string memory _id,
        string memory _categoryId,
        string memory _note,
        uint _status,
        string memory _userId,
        uint _departmentStatus,
        string memory _rejectionNote
    ) public {
        AssetRequestStruct memory instance = AssetRequestStruct(
            _id, 
            _categoryId, 
            _note, 
            _status, 
            _userId, 
            _departmentStatus, 
            _rejectionNote, 
            block.timestamp, // Set creation timestamp
            true
        );
        checkPermission(instance);
        assetRequests.push(instance);
        idMap[_id] = assetRequestCount;
        assetRequestCount++;
    }

    function getById(string memory _id) public view returns (AssetRequestStruct memory) {
        uint idx = idMap[_id];
        AssetRequestStruct memory assetRequest = assetRequests[idx];
        return assetRequest;
    }

    function getAll() public view returns (AssetRequestStruct[] memory) {
        uint activeCount = 0;
        for (uint i = 0; i < assetRequestCount; i++) {
            if (assetRequests[i].is_active) {
                activeCount++;
            }
        }

        AssetRequestStruct[] memory activeAssetRequests = new AssetRequestStruct[](activeCount);
        uint j = 0;
        for (uint i = 0; i < assetRequestCount; i++) {
            if (assetRequests[i].is_active) {
                activeAssetRequests[j] = assetRequests[i];
                j++;
            }
        }
        return activeAssetRequests;
    }

    function update(
        string memory _id,
        string memory _categoryId,
        string memory _note,
        uint _status,
        string memory _userId,
        uint _departmentStatus,
        string memory _rejectionNote
    ) public {
        uint idx = idMap[_id];
        AssetRequestStruct storage assetRequest = assetRequests[idx];
        Profile.ProfileStruct memory profile = checkPermission(assetRequest);
        
        if (keccak256(abi.encodePacked((profile.id))) == keccak256(abi.encodePacked(assetRequest.userId))) {
            assetRequest.categoryId = _categoryId;
            assetRequest.note = _note;
        }

        if (profile.role == Roles.Role.department){
            assetRequest.departmentStatus = _departmentStatus;
        }
        
        if (profile.role == Roles.Role.admin || profile.role == Roles.Role.inventory) {
            assetRequest.status = _status;
            assetRequest.rejectionNote = _rejectionNote;
        }
    }

    function deleteInstance(string memory _id) public {
        uint idx = idMap[_id];
        checkPermission(assetRequests[idx]);
        assetRequests[idx].is_active = false; // Set is_active to false on deletion
    }
}
