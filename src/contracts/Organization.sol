// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

contract Organization {
    
    struct OrganizationStruct {
        string id;
        string name;
    }

    mapping(string => uint) public idMap;
    OrganizationStruct[] organizations;
    uint organizationCount;

    function create(string memory _id, string memory _name) public {
        organizations.push(OrganizationStruct(_id, _name));
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

    function update(string memory _id, string memory _name) public {
        OrganizationStruct memory organization = getById(_id);
        organization.name = _name;
    }

}
