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
    }

    mapping(string => uint) public idMap;
    AssetRequestStruct[] assetRequests;
    uint assetRequestCount;

    function create(string memory _id, string memory _categoryId, string memory _note, uint _status, string memory _userId) public {
        assetRequests.push(AssetRequestStruct(_id, _categoryId, _note, _status, _userId));
        idMap[_id] = assetRequestCount;
        assetRequestCount++;
    }

    function getById(string memory _id) public view returns (AssetRequestStruct memory) {
        uint idx = idMap[_id];
        AssetRequestStruct memory assetRequest = assetRequests[idx];
        return assetRequest;
    }

    function getAll() public view returns (AssetRequestStruct[] memory) {
        return assetRequests;
    }

    function update(string memory _id, string memory _categoryId, string memory _note, uint _status, string memory _userId) public {
        uint idx = idMap[_id];
        AssetRequestStruct storage assetRequest = assetRequests[idx];
        assetRequest.id = _id;
        assetRequest.categoryId = _categoryId;
        assetRequest.note = _note;
        assetRequest.status = _status;
        assetRequest.userId = _userId;
    }
}
