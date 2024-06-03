import pytest
from brownie import accounts, Asset, Profile

@pytest.fixture(scope="module")
def create_accounts():
    needed_accounts = 2
    if len(accounts) < needed_accounts:
        for _ in range(needed_accounts - len(accounts)):
            accounts.add()  # Creates a new account in the local network
    return accounts

@pytest.fixture(scope="module")
def deploy_profile_contract(create_accounts):
    profile = Profile.deploy({"from": accounts[0]})
    print(profile)
    return profile

@pytest.fixture(scope="module")
def deploy_asset_contract(deploy_profile_contract):
    asset = Asset.deploy(deploy_profile_contract.address, {"from": accounts[0]})
    print(asset)
    return asset

@pytest.fixture
def create_profile(deploy_profile_contract):
    profile_contract = deploy_profile_contract
    profile_contract.create(0, "1", "Admin", accounts[0], "admin@example.com", "Org1", "Dept1", {"from": accounts[0]})
    profile_contract.create(3, "2", "Staff", accounts[1], "staff@example.com", "Org1", "Dept1", {"from": accounts[0]})
    return profile_contract

def test_create_profile( create_profile):
    profile_contract = create_profile
    profile_contract.create(0, "1", "Admin", accounts[0], "admin@example.com", "Org1", "Dept1", {"from": accounts[0]})
    profile = profile_contract.getById("1")

    assert profile[0] == 0  # role
    assert profile[1] == "1"  # id
    assert profile[2] == "Admin"  # name
    assert profile[3] == accounts[0].address  # userKey
    assert profile[4] == "admin@example.com"  # email
    assert profile[5] == "Org1"  # organizationId
    assert profile[6] == "Dept1"
    assert profile[7] == True

def test_update_profile(create_profile):
    profile_contract = create_profile
    profile_contract.create(0, "1", "Admin", accounts[0], "admin@example.com", "Org1", "Dept1", {"from": accounts[0]})
    profile_contract.update(3, "1", "Staff", accounts[1], "staff@example.com", "Org1", "Dept1", {"from": accounts[0]})
    profile = profile_contract.getById("1")

    assert profile[0] == 3  # role
    assert profile[1] == "1"  # id
    assert profile[2] == "Staff"  # name
    assert profile[3] == accounts[0].address  # userKey
    assert profile[4] == "staff@example.com"  # email
    assert profile[5] == "Org1"  # organizationId
    assert profile[6] == "Dept1"
    assert profile[7] == True

def test_delete_profile(create_profile):
    profile_contract = create_profile
    profile_contract.create(0, "1", "Admin", accounts[0], "admin@example.com", "Org1", "Dept1", {"from": accounts[0]})
    profile_contract.deleteInstance("1", {"from": accounts[0]})
    profile = profile_contract.getById("1")

    assert profile[7] == False  # is_active

def test_getByUserKey_profile(create_profile):
    profile_contract = create_profile
    profile_contract.create(0, "1", "Admin", accounts[0], "admin@example.com", "Org1", "Dept1", {"from": accounts[0]})
    profile = profile_contract.getByUserKey(accounts[0])

    assert profile[0] == 0  # role
    assert profile[1] == "1"  # id
    assert profile[2] == "Admin"  # name
    assert profile[3] == accounts[0].address  # userKey
    assert profile[4] == "admin@example.com"  # email
    assert profile[5] == "Org1"  # organizationId
    assert profile[6] == "Dept1"
    assert profile[7] == True


def test_permission_check(deploy_asset_contract, create_profile):
    profile_contract = create_profile
    with pytest.raises(Exception):
        profile_contract.create("asset1", "Laptop", "category1", ["1"], "Org1", {"from": accounts[1]})