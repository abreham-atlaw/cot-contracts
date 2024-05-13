// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

contract AssetMaintenanceRequest {
    struct AssetMaintenanceRequestStruct {
        string id;
        string assetId;
        string note;
        uint status;
        string userId;
        bool is_active; // Add is_active field
    }

    mapping(string => uint) public idMap;
    AssetMaintenanceRequestStruct[] assetMaintenanceRequests;
    uint assetMaintenanceRequestCount;

    function create(string memory _id, string memory _assetId, string memory _note, uint _status, string memory _userId) public {
        assetMaintenanceRequests.push(AssetMaintenanceRequestStruct(_id, _assetId, _note, _status, _userId, true)); // Set is_active to true on creation
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

    function update(string memory _id, string memory _assetId, string memory _note, uint _status, string memory _userId) public {
        uint idx = idMap[_id];
        AssetMaintenanceRequestStruct storage assetMaintenanceRequest = assetMaintenanceRequests[idx];
        assetMaintenanceRequest.id = _id;
        assetMaintenanceRequest.assetId = _assetId;
        assetMaintenanceRequest.note = _note;
        assetMaintenanceRequest.status = _status;
        assetMaintenanceRequest.userId = _userId;
    }

    function deleteInstance(string memory _id) public {
        uint idx = idMap[_id];
        assetMaintenanceRequests[idx].is_active = false; // Set is_active to false on deletion
    }
}
