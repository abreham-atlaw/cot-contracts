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

def test_create_asset(deploy_asset_contract, create_profile):
    asset_contract = deploy_asset_contract
    asset_contract.create("asset1", "Laptop", "category1", ["1"], "Org1", {"from": accounts[0]})
    asset = asset_contract.getById("asset1")

    assert asset[0] == "asset1"  # id
    assert asset[1] == "Laptop"  # name
    assert asset[2] == "category1"  # categoryId
    assert asset[3] == ["1"]  # ownersId
    assert asset[4] == "Org1"  # orgId
    assert asset[5] == True  # is_active

def test_update_asset(deploy_asset_contract, create_profile):
    asset_contract = deploy_asset_contract
    asset_contract.create("asset1", "Laptop", "category1", ["1"], "Org1", {"from": accounts[0]})
    asset_contract.update("asset1", "Desktop", "category2", ["2"], "Org2", {"from": accounts[0]})
    asset = asset_contract.getById("asset1")

    assert asset[0] == "asset1"  # id
    assert asset[1] == "Desktop"  # name
    assert asset[2] == "category2"  # categoryId
    assert asset[3] == ["2"]  # ownersId
    assert asset[4] == "Org2"  # orgId

def test_delete_asset(deploy_asset_contract, create_profile):
    asset_contract = deploy_asset_contract
    asset_contract.create("asset1", "Laptop", "category1", ["1"], "Org1", {"from": accounts[0]})
    asset_contract.deleteInstance("asset1", {"from": accounts[0]})
    asset = asset_contract.getById("asset1")

    assert asset[5] == False  # is_active

def test_permission_check(deploy_asset_contract, create_profile):
    asset_contract = deploy_asset_contract
    with pytest.raises(Exception):
        asset_contract.create("asset1", "Laptop", "category1", ["1"], "Org1", {"from": accounts[1]})