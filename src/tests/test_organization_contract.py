import pytest
from brownie import accounts, Organization, Profile, Roles

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

@pytest.fixture
def deploy_organization_contract(deploy_profile_contract):
    organization = Organization.deploy(deploy_profile_contract.address, {"from": accounts[0]})
    return organization

@pytest.fixture
def create_profile(deploy_profile_contract, deploy_roles_contract):
    profile_contract = deploy_profile_contract
    roles_contract = deploy_roles_contract
    profile_contract.create(0, "Org1", "Admin", accounts[0], "admin@example.com", "org1", "Dept1", {"from": accounts[0]})
    profile_contract.create(2, "Org1", "Staff", accounts[1], "staff@example.com", "org1", "Dept1", {"from": accounts[0]})
    return profile_contract

def test_create_organization(deploy_organization_contract, create_profile):
    organization_contract = deploy_organization_contract
    organization_contract.create("org1", "Organization One", {"from": accounts[0]})
    organization = organization_contract.getById("org1")

    assert organization[0] == "org1"  # id
    assert organization[1] == "Organization One"  # name

def test_update_organization(deploy_organization_contract, create_profile):
    organization_contract = deploy_organization_contract
    organization_contract.create("org1", "Organization One", {"from": accounts[0]})

    with pytest.raises(Exception):
        organization_contract.update("org1", "New Organization One", {"from": accounts[1]})
    
    organization_contract.update("org1", "New Organization One", {"from": accounts[0]})
    organization = organization_contract.getById("org1")

    assert organization[0] == "org1"  # id
    assert organization[1] == "Organization One"  # name


def test_get_all_organizations(deploy_organization_contract, create_profile):
    organization_contract = deploy_organization_contract
    organization_contract.create("org1", "Organization One", {"from": accounts[0]})
    organization_contract.create("org2", "Organization Two", {"from": accounts[0]})
    
    all_organizations = organization_contract.getAll()
    assert len(all_organizations) == 2
    assert all_organizations[0][0] == "org1"
    assert all_organizations[0][1] == "Organization One"
    assert all_organizations[1][0] == "org2"
    assert all_organizations[1][1] == "Organization Two"