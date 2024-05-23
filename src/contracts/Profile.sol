// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import './Roles.sol';

contract Profile {
    
    struct ProfileStruct {
        Roles.Role role;
        string id;
        string name;
        address userKey;
        string email;
        string organizationId;
        string departmentId;
        bool is_active; // Add is_active field
    }

    mapping(string => uint) public idMap;
    ProfileStruct[] profiles;
    uint profileCount;

    function checkPermission() private view {
        address msgSender = msg.sender;
        ProfileStruct memory userProfile = getByUserKey(msgSender);
        require(
            userProfile.role == Roles.Role.admin || userProfile.role == Roles.Role.hr, 
            "Access Denied - Only Admin or HR can perform this action"
        );
    }

    function create(Roles.Role _role, string memory _id, string memory _name, address _userKey, string memory _email, string memory _organizationId, string memory _departmentId) public {
        checkPermission(); // Permission check for create
        profiles.push(ProfileStruct(_role, _id, _name, _userKey, _email, _organizationId, _departmentId, true)); // Set is_active to true on creation
        idMap[_id] = profileCount;
        profileCount++;
    }

    function getById(string memory _id) public view returns (ProfileStruct memory) {
        uint idx = idMap[_id];
        ProfileStruct memory profile = profiles[idx];
        return profile;
    }

    function getAll() public view returns (ProfileStruct[] memory) {
        uint activeCount = 0;
        for (uint i = 0; i < profileCount; i++) {
            if (profiles[i].is_active) {
                activeCount++;
            }
        }

        ProfileStruct[] memory activeProfiles = new ProfileStruct[](activeCount);
        uint j = 0;
        for (uint i = 0; i < profileCount; i++) {
            if (profiles[i].is_active) {
                activeProfiles[j] = profiles[i];
                j++;
            }
        }
        return activeProfiles;
    }

    function getByUserKey(address _userKey) public view returns (ProfileStruct memory) {
        for (uint i = 0; i < profiles.length; i++) {
            if (profiles[i].userKey == _userKey && profiles[i].is_active) { // Check if profile is active
                return profiles[i];
            }
        }
        require(false, "Active profile with the given userKey not found");
    }

    function update(Roles.Role _role, string memory _id, string memory _name, address _userKey, string memory _email, string memory _organizationId, string memory _departmentId) public {
        checkPermission(); // Permission check for update
        uint idx = idMap[_id];
        ProfileStruct storage profile = profiles[idx];
        profile.role = _role;
        profile.id = _id;
        profile.name = _name;
        profile.email = _email;
        profile.departmentId = _departmentId;
    }

    function deleteInstance(string memory _id) public {
        checkPermission(); // Permission check for delete
        uint idx = idMap[_id];
        profiles[idx].is_active = false; // Set is_active to false on deletion
    }
}
