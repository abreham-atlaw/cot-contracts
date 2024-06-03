import pytest
from brownie import accounts, AssetCategory, Profile, Roles

@pytest.fixture(scope="module")
def create_accounts():
    needed_accounts = 2
    if len(accounts) < needed_accounts:
        for _ in range(needed_accounts - len(accounts)):
            accounts.add()  # Creates a new account in the local network
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
def deploy_asset_category_contract(deploy_profile_contract):
    asset_category = AssetCategory.deploy(deploy_profile_contract.address, {"from": accounts[0]})
    return asset_category

@pytest.fixture
def create_profiles(deploy_profile_contract):
    profile_contract = deploy_profile_contract
    profile_contract.create(0, "1", "Admin", accounts[0], "admin@example.com", "Org1", "Dept1", {"from": accounts[0]})
    profile_contract.create(3, "2", "Inventory", accounts[1], "inventory@example.com", "Org1", "Dept1", {"from": accounts[0]})
    return profile_contract

def test_create_asset_category(deploy_asset_category_contract, create_profiles):
    asset_category_contract = deploy_asset_category_contract
    asset_category_contract.create("cat1", "Electronics", "Org1", "parent1", {"from": accounts[0]})
    category = asset_category_contract.getById("cat1")

    assert category[0] == "cat1"  # id
    assert category[1] == "Electronics"  # name
    assert category[2] == "Org1"  # orgId
    assert category[3] == "parent1"  # parentCategoryId
    assert category[4] == True  # is_active

def test_update_asset_category(deploy_asset_category_contract, create_profiles):
    asset_category_contract = deploy_asset_category_contract
    asset_category_contract.create("cat1", "Electronics", "Org1", "parent1", {"from": accounts[0]})
    asset_category_contract.update("cat1", "Home Appliances", "Org2", "parent2", {"from": accounts[0]})
    category = asset_category_contract.getById("cat1")

    assert category[0] == "cat1"  # id
    assert category[1] == "Home Appliances"  # name
    assert category[2] == "Org2"  # orgId
    assert category[3] == "parent2"  # parentCategoryId

def test_delete_asset_category(deploy_asset_category_contract, create_profiles):
    asset_category_contract = deploy_asset_category_contract
    asset_category_contract.create("cat1", "Electronics", "Org1", "parent1", {"from": accounts[0]})
    asset_category_contract.deleteInstance("cat1", {"from": accounts[0]})
    category = asset_category_contract.getById("cat1")

    assert category[4] == False  # is_active

def test_get_all_active_asset_categories(deploy_asset_category_contract, create_profiles):
    asset_category_contract = deploy_asset_category_contract
    asset_category_contract.create("cat1", "Electronics", "Org1", "parent1", {"from": accounts[0]})
    asset_category_contract.create("cat2", "Furniture", "Org1", "parent2", {"from": accounts[0]})
    asset_category_contract.deleteInstance("cat1", {"from": accounts[0]})

    categories = asset_category_contract.getAll()
    assert len(categories) == 1
    assert categories[0][0] == "cat2"  # id of the remaining active category
    assert categories[0][1] == "Furniture"  # name of the remaining active category

def test_permission_check(deploy_asset_category_contract, create_profiles):
    asset_category_contract = deploy_asset_category_contract
    with pytest.raises(Exception, match="Access Denied"):
        asset_category_contract.create("cat1", "Electronics", "Org1", "parent1", {"from": accounts[1]})