import pytest
from brownie import accounts, AssetRequest, Profile, Roles

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
def deploy_asset_request_contract(deploy_profile_contract):
    asset_request = AssetRequest.deploy(deploy_profile_contract.address, {"from": accounts[0]})
    return asset_request

@pytest.fixture
def create_profile(deploy_profile_contract, deploy_roles_contract):
    profile_contract = deploy_profile_contract
    roles_contract = deploy_roles_contract
    profile_contract.create(0, "1", "Admin", accounts[0], "admin@example.com", "Org1", "Dept1", {"from": accounts[0]})
    profile_contract.create(1, "2", "Staff", accounts[1], "staff@example.com", "Org1", "Dept1", {"from": accounts[0]})
    profile_contract.create(2, "3", "Department", accounts[2], "department@example.com", "Org1", "Dept1", {"from": accounts[0]})
    return profile_contract

def test_create_asset_request(deploy_asset_request_contract, create_profile):
    asset_request_contract = deploy_asset_request_contract
    asset_request_contract.create("request1", "category1", "Need a new laptop", 0, "1", 0, "", {"from": accounts[0]})
    request = asset_request_contract.getById("request1")

    assert request[0] == "request1"  # id
    assert request[1] == "category1"  # categoryId
    assert request[2] == "Need a new laptop"  # note
    assert request[3] == 0  # status
    assert request[4] == "1"  # userId
    assert request[5] == 0  # departmentStatus
    assert request[6] == ""  # rejectionNote
    assert request[7] == True  # is_active

def test_update_asset_request(deploy_asset_request_contract, create_profile):
    asset_request_contract = deploy_asset_request_contract
    asset_request_contract.create("request1", "category1", "Need a new laptop", 0, "1", 0, "", {"from": accounts[0]})
    asset_request_contract.update("request1", "category2", "Need a new desktop", 1, "1", 0, "", {"from": accounts[0]})
    request = asset_request_contract.getById("request1")

    assert request[0] == "request1"  # id
    assert request[1] == "category2"  # categoryId
    assert request[2] == "Need a new desktop"  # note
    assert request[3] == 1  # status
    assert request[4] == "1"  # userId
    assert request[5] == 0  # departmentStatus
    assert request[6] == ""  # rejectionNote

def test_delete_asset_request(deploy_asset_request_contract, create_profile):
    asset_request_contract = deploy_asset_request_contract
    asset_request_contract.create("request1", "category1", "Need a new laptop", 0, "1", 0, "", {"from": accounts[0]})
    asset_request_contract.deleteInstance("request1", {"from": accounts[0]})
    request = asset_request_contract.getById("request1")

    assert request[7] == False  # is_active

def test_permission_check(deploy_asset_request_contract, create_profile):
    asset_request_contract = deploy_asset_request_contract
    with pytest.raises(Exception):
        asset_request_contract.create("request1", "category1", "Need a new laptop", 0, "1", 0, "", {"from": accounts[1]})