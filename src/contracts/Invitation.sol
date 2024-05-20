// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;


contract Invitation {
    struct InvitationStruct {
        uint role;
        string id;
        string to;
        string orgId;
        string name;
        bool is_active;
    }

    mapping(string => uint) public idMap;
    InvitationStruct[] invitations;
    uint invitationCount;

    function create(uint _role, string memory _id, string memory _to, string memory _orgId, string memory _name) public {
        invitations.push(InvitationStruct(_role, _id, _to, _orgId, _name, true));
        idMap[_id] = invitationCount;
        invitationCount++;
    }

    function getById(string memory _id) public view returns (InvitationStruct memory) {
        uint idx = idMap[_id];
        InvitationStruct memory invitation = invitations[idx];
        return invitation;
    }

    function getAll() public view returns (InvitationStruct[] memory) {
        uint activeCount = 0;
        for (uint i = 0; i < invitationCount; i++) {
            if (invitations[i].is_active) {
                activeCount++;
            }
        }

        InvitationStruct[] memory activeInvitations = new InvitationStruct[](activeCount);
        uint j = 0;
        for (uint i = 0; i < invitationCount; i++) {
            if (invitations[i].is_active) {
                activeInvitations[j] = invitations[i];
                j++;
            }
        }
        return activeInvitations;
    }

    function update(uint _role, string memory _id, string memory _to, string memory _orgId, string memory _name) public {
        uint idx = idMap[_id];
        InvitationStruct storage invitation = invitations[idx];
        invitation.role = _role;
        invitation.id = _id;
        invitation.to = _to;
        invitation.orgId = _orgId;
        invitation.name = _name;
    }

    function deleteInstance(string memory _id) public {
        uint idx = idMap[_id];
        invitations[idx].is_active = false;
    }
}
