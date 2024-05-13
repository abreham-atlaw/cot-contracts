// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

contract AssetRequest {
    struct AssetRequestStruct {
        string id;
        string categoryId;
        string note;
        uint status;
        string userId;
        uint departmentStatus;
        bool is_active; // Add is_active field
    }

    mapping(string => uint) public idMap;
    AssetRequestStruct[] assetRequests;
    uint assetRequestCount;

    function create(string memory _id, string memory _categoryId, string memory _note, uint _status, string memory _userId, uint _departmentStatus) public {
        assetRequests.push(AssetRequestStruct(_id, _categoryId, _note, _status, _userId, _departmentStatus, true)); // Set is_active to true on creation
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

    function update(string memory _id, string memory _categoryId, string memory _note, uint _status, string memory _userId, uint _departmentStatus) public {
        uint idx = idMap[_id];
        AssetRequestStruct storage assetRequest = assetRequests[idx];
        assetRequest.id = _id;
        assetRequest.categoryId = _categoryId;
        assetRequest.note = _note;
        assetRequest.status = _status;
        assetRequest.userId = _userId;
        assetRequest.departmentStatus = _departmentStatus;
    }

    function deleteInstance(string memory _id) public {
        uint idx = idMap[_id];
        assetRequests[idx].is_active = false; // Set is_active to false on deletion
    }
}
