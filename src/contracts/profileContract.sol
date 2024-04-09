// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

contract Profile {
    struct ProfileStruct {
        uint role;
        string id;
        string name;
        string userKey;
        string email;
        string organizationId;
    }

    mapping(string => uint) public idMap;
    ProfileStruct[] profiles;
    uint profileCount;

    function create(uint _role, string memory _id, string memory _name, string memory _userKey, string memory _email, string memory _organizationId) public {
        profiles.push(ProfileStruct(_role, _id, _name, _userKey, _email, _organizationId));
        idMap[_userKey] = profileCount;
        profileCount++;
    }

    function getProfileByUserKey(string memory _userKey) public view returns (ProfileStruct memory) {
        uint idx = idMap[_userKey];
        ProfileStruct memory profile = profiles[idx];
        return profile;
    }

    function getAll() public view returns (ProfileStruct[] memory) {
        return profiles;
    }

    function update(string memory _userKey, uint _role, string memory _id, string memory _name, string memory _email, string memory _organizationId) public {
        uint idx = idMap[_userKey];
        ProfileStruct storage profile = profiles[idx];
        profile.role = _role;
        profile.id = _id;
        profile.name = _name;
        profile.email = _email;
        profile.organizationId = _organizationId;
    }
}
