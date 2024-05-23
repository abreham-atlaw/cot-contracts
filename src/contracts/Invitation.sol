// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Profile.sol";
import "./Roles.sol";

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

    Profile profileContract;

    constructor(address _profileContractAddress) {
        profileContract = Profile(_profileContractAddress);
    }

    function checkPermission(InvitationStruct memory instance) private view {
        Profile.ProfileStruct memory userProfile = profileContract.getByUserKey(msg.sender);
        require(
            (userProfile.role == Roles.Role.admin || userProfile.role == Roles.Role.hr) || 
            (keccak256(abi.encodePacked((userProfile.email))) == keccak256(abi.encodePacked(instance.to))),
            "Access Denied"
        );
    }

    function getById(string memory _id) public view returns (InvitationStruct memory) {
        uint idx = idMap[_id];
        InvitationStruct memory invitation = invitations[idx];
        return invitation;
    }

    function getByInvitationId(string memory _invitationId) private view returns (InvitationStruct memory) {
        for (uint i = 0; i < invitationCount; i++) {
            if (keccak256(abi.encodePacked(invitations[i].id)) == keccak256(abi.encodePacked(_invitationId))) {
                return invitations[i];
            }
        }
        revert("Invitation Not Found");
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

    function create(uint _role, string memory _id, string memory _to, string memory _orgId, string memory _name) public {
        InvitationStruct memory instance = InvitationStruct(_role, _id, _to, _orgId, _name, true);
        checkPermission(instance);
        invitations.push(instance);
        idMap[_id] = invitationCount;
        invitationCount++;
    }

    function update(uint _role, string memory _id, string memory _to, string memory _orgId, string memory _name) public {
        uint idx = idMap[_id];
        InvitationStruct storage invitation = invitations[idx];
        checkPermission(invitation);
        invitation.role = _role;
        invitation.to = _to;
        invitation.orgId = _orgId;
        invitation.name = _name;
    }

    function deleteInstance(string memory _id) public {
        InvitationStruct memory invitation = getByInvitationId(_id);
        checkPermission(invitation); 
        uint idx = idMap[invitation.id];
        invitations[idx].is_active = false;
    }
}
