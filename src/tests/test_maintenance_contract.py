import pytest
from brownie import accounts, AssetMaintenanceRequest, Profile, Roles

@pytest.fixture(scope="module")
def create_accounts():
    needed_accounts = 3
    if len(accounts) < needed_accounts:
        for _ in range(needed_accounts - len(accounts)):
            accounts.add()
    return accounts

@pytest.fixture(scope="module")
def deploy_roles_contract():
    roles = Roles.deploy({"from": accounts[0]})
    return roles

@pytest.fixture(scope="module")
def deploy_profile_contract(deploy_roles_contract):
    profile = Profile.deploy({"from": accounts[0]})
    return profile

@pytest.fixture
def deploy_asset_maintenance_request_contract(deploy_profile_contract):
    asset_maintenance_request = AssetMaintenanceRequest.deploy(deploy_profile_contract.address, {"from": accounts[0]})
    return asset_maintenance_request

@pytest.fixture
def create_profiles(deploy_profile_contract):
    profile_contract = deploy_profile_contract
    profile_contract.create(0, "1", "Admin", accounts[0], "admin@example.com", "Org1", "Dept1", {"from": accounts[0]})
    profile_contract.create(1, "2", "Maintainer", accounts[1], "maintainer@example.com", "Org1", "Dept1", {"from": accounts[0]})
    profile_contract.create(2, "3", "User", accounts[2], "user@example.com", "Org1", "Dept1", {"from": accounts[0]})
    return profile_contract

def test_create_asset_maintenance_request(deploy_asset_maintenance_request_contract, create_profiles):
    asset_maintenance_request_contract = deploy_asset_maintenance_request_contract
    asset_maintenance_request_contract.create("req1", "asset1", "Initial note", 0, "image1", "2", {"from": accounts[1]})
    request = asset_maintenance_request_contract.getById("req1")

    assert request[0] == "req1"  # id
    assert request[1] == "asset1"  # assetId
    assert request[2] == "Initial note"  # note
    assert request[3] == 0  # status
    assert request[4] == "image1"  # image
    assert request[5] == "2"  # userId
    assert request[6] == True  # is_active

def test_update_asset_maintenance_request(deploy_asset_maintenance_request_contract, create_profiles):
    asset_maintenance_request_contract = deploy_asset_maintenance_request_contract
    asset_maintenance_request_contract.create("req1", "asset1", "Initial note", 0, "image1", "2", {"from": accounts[1]})
    asset_maintenance_request_contract.update("req1", "asset2", "Updated note", 0, "image2", "2", {"from": accounts[1]})
    request = asset_maintenance_request_contract.getById("req1")

    assert request[0] == "req1"  # id
    assert request[1] == "asset2"  # assetId
    assert request[2] == "Updated note"  # note
    assert request[3] == 0  # status
    assert request[4] == "image2"  # image
    assert request[5] == "2"  # userId

def test_delete_asset_maintenance_request(deploy_asset_maintenance_request_contract, create_profiles):
    asset_maintenance_request_contract = deploy_asset_maintenance_request_contract
    asset_maintenance_request_contract.create("req1", "asset1", "Initial note", 0, "image1", "2", {"from": accounts[1]})
    asset_maintenance_request_contract.deleteInstance("req1", {"from": accounts[0]})
    request = asset_maintenance_request_contract.getById("req1")

    assert request[6] == False  # is_active

def test_get_all_active_asset_maintenance_requests(deploy_asset_maintenance_request_contract, create_profiles):
    asset_maintenance_request_contract = deploy_asset_maintenance_request_contract
    asset_maintenance_request_contract.create("req1", "asset1", "Initial note", 0, "image1", "2", {"from": accounts[1]})
    asset_maintenance_request_contract.create("req2", "asset2", "Initial note", 0, "image2", "3", {"from": accounts[2]})
    asset_maintenance_request_contract.create("req3", "asset3", "Initial note", 0, "image3", "3", {"from": accounts[2]})

    # Deleting one of the requests to make it inactive
    asset_maintenance_request_contract.deleteInstance("req2", {"from": accounts[0]})

    # Getting all active requests
    active_requests = asset_maintenance_request_contract.getAll()
    
    # Checking that only active requests are returned
    assert len(active_requests) == 2
    assert active_requests[0][0] == "req1"
    assert active_requests[1][0] == "req3"