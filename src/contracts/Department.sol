// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Profile.sol";
import "./Roles.sol";

contract Department {
    
    struct DepartmentStruct {
        string id;
        string name;
        string headId;
        string orgId;
        bool is_active; // Add is_active field
    }

    mapping(string => uint) public idMap;
    DepartmentStruct[] departments;
    uint departmentCount;

    Profile profileContract;

    constructor(address _profileContractAddress) {
        profileContract = Profile(_profileContractAddress);
    }

    function checkPermission() private view {
        Profile.ProfileStruct memory userProfile = profileContract.getByUserKey(msg.sender);
        require(userProfile.role == Roles.Role.admin, "Access Denied - Only Admins can perform this action");
    }

    function create(string memory _id, string memory _name, string memory _headId, string memory _orgId) public {
        checkPermission(); 
        departments.push(DepartmentStruct(_id, _name, _headId, _orgId, true)); // Set is_active to true on creation
        idMap[_id] = departmentCount;
        departmentCount++;
    }

    function getById(string memory _id) public view returns (DepartmentStruct memory) {
        uint idx = idMap[_id];
        DepartmentStruct memory department = departments[idx];
        return department;
    }

    function getAll() public view returns (DepartmentStruct[] memory) {
        uint activeCount = 0;
        for (uint i = 0; i < departmentCount; i++) {
            if (departments[i].is_active) {
                activeCount++;
            }
        }

        DepartmentStruct[] memory activeDepartments = new DepartmentStruct[](activeCount);
        uint j = 0;
        for (uint i = 0; i < departmentCount; i++) {
            if (departments[i].is_active) {
                activeDepartments[j] = departments[i];
                j++;
            }
        }
        return activeDepartments;
    }

    function update(string memory _id, string memory _name, string memory _headId, string memory _orgId) public {
        checkPermission(); // Permission check for update
        uint idx = idMap[_id];
        DepartmentStruct storage department = departments[idx];
        department.name = _name;
        department.headId = _headId;
        department.orgId = _orgId;
    }

    function deleteInstance(string memory _id) public {
        checkPermission(); // Permission check for delete
        uint idx = idMap[_id];
        departments[idx].is_active = false; // Set is_active to false on deletion
    }
}
