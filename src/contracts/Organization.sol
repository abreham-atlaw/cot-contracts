// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Profile.sol";
import "./Roles.sol";

contract Organization {
    
    struct OrganizationStruct {
        string id;
        string name;
    }

    mapping(string => uint) public idMap;
    OrganizationStruct[] organizations;
    uint organizationCount;

    Profile profileContract;

    constructor(address _profileContractAddress) {
        profileContract = Profile(_profileContractAddress);
    }

    function checkPermission(OrganizationStruct memory instance) private view {
        Profile.ProfileStruct memory userProfile = profileContract.getByUserKey(msg.sender);
        require(
            userProfile.role == Roles.Role.admin && keccak256(abi.encodePacked((userProfile.organizationId))) == keccak256(abi.encodePacked((instance.id))),
            "Access Denied - Only Admins with matching orgId can perform this action"
        );
    }

    function create(string memory _id, string memory _name) public {
        OrganizationStruct memory instance = OrganizationStruct(_id, _name);
        organizations.push(instance);
        idMap[_id] = organizationCount;
        organizationCount++;
    }

    function getById(string memory _id) public view returns (OrganizationStruct memory) {
        uint idx = idMap[_id];
        OrganizationStruct memory organization = organizations[idx];
        return organization;
    }

    function getAll() public view returns (OrganizationStruct[] memory) {
        return organizations;
    }

    function update(string memory _id, string memory _name) public view {
        OrganizationStruct memory organization = getById(_id);
        checkPermission(organization);
        organization.name = _name;
    }
}
