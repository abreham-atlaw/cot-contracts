import pytest
from brownie import accounts, Invitation, Profile, Roles

@pytest.fixture(scope="module")
def create_accounts():
    needed_accounts = 3
    if len(accounts) < needed_accounts:
        for _ in range(needed_accounts - len(accounts)):
            accounts.add()  # Creates a new account in the local network
    return accounts

@pytest.fixture(scope="module")
def deploy_profile_contract(create_accounts):
    profile = Profile.deploy({"from": accounts[0]})
    return profile

@pytest.fixture(scope="module")
def deploy_roles_contract():
    roles = Roles.deploy({"from": accounts[0]})
    return roles

@pytest.fixture(scope="module")
def deploy_invitation_contract(deploy_profile_contract):
    invitation = Invitation.deploy(deploy_profile_contract.address, {"from": accounts[0]})
    return invitation

@pytest.fixture
def create_profile(deploy_profile_contract, deploy_roles_contract):
    profile_contract = deploy_profile_contract
    roles_contract = deploy_roles_contract
    profile_contract.create(0, "1", "Admin", accounts[0], "admin@example.com", "Org1", "Dept1", {"from": accounts[0]})
    profile_contract.create(1, "2", "HR", accounts[1], "hr@example.com", "Org1", "Dept1", {"from": accounts[0]})
    profile_contract.create(2, "3", "Staff", accounts[2], "staff@example.com", "Org1", "Dept1", {"from": accounts[0]})
    return profile_contract

def test_create_invitation(deploy_invitation_contract, create_profile):
    invitation_contract = deploy_invitation_contract
    invitation_contract.create(1, "inv1", "invitee@example.com", "Org1", "Invitee", {"from": accounts[0]})
    invitation = invitation_contract.getById("inv1")

    assert invitation[0] == 1  # role
    assert invitation[1] == "inv1"  # id
    assert invitation[2] == "invitee@example.com"  # to
    assert invitation[3] == "Org1"  # orgId
    assert invitation[4] == "Invitee"  # name
    assert invitation[5] == True  # is_active

def test_update_invitation(deploy_invitation_contract, create_profile):
    invitation_contract = deploy_invitation_contract
    invitation_contract.create(1, "inv1", "invitee@example.com", "Org1", "Invitee", {"from": accounts[0]})
    invitation_contract.update(2, "inv1", "newinvitee@example.com", "Org2", "New Invitee", {"from": accounts[0]})
    invitation = invitation_contract.getById("inv1")

    assert invitation[0] == 2  # role
    assert invitation[1] == "inv1"  # id
    assert invitation[2] == "newinvitee@example.com"  # to
    assert invitation[3] == "Org2"  # orgId
    assert invitation[4] == "New Invitee"  # name

def test_delete_invitation(deploy_invitation_contract, create_profile):
    invitation_contract = deploy_invitation_contract
    invitation_contract.create(1, "inv1", "invitee@example.com", "Org1", "Invitee", {"from": accounts[0]})
    invitation_contract.deleteInstance("inv1", {"from": accounts[0]})
    invitation = invitation_contract.getById("inv1")

    assert invitation[5] == False  # is_active

def test_permission_check(deploy_invitation_contract, create_profile):
    invitation_contract = deploy_invitation_contract
    with pytest.raises(Exception):
        invitation_contract.create(1, "inv1", "invitee@example.com", "Org1", "Invitee", {"from": accounts[2]})
        