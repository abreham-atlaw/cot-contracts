// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;


contract Invitation {
    struct InvitationStruct {
        uint role;
        string id;
        string to;
        string orgId;
    }

    mapping(string => uint) public idMap;
    InvitationStruct[] invitations;
    uint invitationCount;

    function create(uint _role, string memory _id, string memory _to, string memory _orgId) public {
        invitations.push(InvitationStruct(_role, _id, _to, _orgId));
        idMap[_id] = invitationCount;
        invitationCount++;
    }

    function getById(string memory _id) public view returns (InvitationStruct memory) {
        uint idx = idMap[_id];
        InvitationStruct memory invitation = invitations[idx];
        return invitation;
    }

    function getAll() public view returns (InvitationStruct[] memory) {
        return invitations;
    }

    function update(uint _role, string memory _id, string memory _to, string memory _orgId) public {
        uint idx = idMap[_id];
        InvitationStruct storage invitation = invitations[idx];
        invitation.role = _role;
        invitation.id = _id;
        invitation.to = _to;
        invitation.orgId = _orgId;
    }
}
