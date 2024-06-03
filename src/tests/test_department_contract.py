import pytest
from brownie import accounts, Department, Profile, Roles

@pytest.fixture(scope="module")
def create_accounts():
    needed_accounts = 3
    if len(accounts) < needed_accounts:
        for _ in range(needed_accounts - len(accounts)):
            accounts.add()
    return accounts

@pytest.fixture(scope="module")
def deploy_profile_contract(create_accounts):
    profile = Profile.deploy({"from": accounts[0]})
    return profile

@pytest.fixture
def deploy_roles_contract():
    roles = Roles.deploy({"from": accounts[0]})
    return roles

@pytest.fixture()
def deploy_department_contract(deploy_profile_contract):
    department = Department.deploy(deploy_profile_contract.address, {"from": accounts[0]})
    return department

@pytest.fixture
def create_profile(deploy_profile_contract, deploy_roles_contract):
    profile_contract = deploy_profile_contract
    roles_contract = deploy_roles_contract
    profile_contract.create(0, "Admin1", "Admin", accounts[0], "admin@example.com", "Org1", "Dept1", {"from": accounts[0]})
    profile_contract.create(1, "Staff1", "Staff", accounts[1], "staff@example.com", "Org1", "Dept1", {"from": accounts[0]})
    return profile_contract

def test_create_department(deploy_department_contract, create_profile):
    department_contract = deploy_department_contract
    department_contract.create("dept1", "Department One", "Head1", "Org1", {"from": accounts[0]})
    department = department_contract.getById("dept1")

    assert department[0] == "dept1"  # id
    assert department[1] == "Department One"  # name
    assert department[2] == "Head1"  # headId
    assert department[3] == "Org1"  # orgId
    assert department[4] is True  # is_active

def test_update_department(deploy_department_contract, create_profile):
    department_contract = deploy_department_contract
    department_contract.create("dept1", "Department One", "Head1", "Org1", {"from": accounts[0]})

    with pytest.raises(Exception):
        department_contract.update("dept1", "New Department One", "NewHead1", "NewOrg1", {"from": accounts[1]})
    
    department_contract.update("dept1", "New Department One", "NewHead1", "NewOrg1", {"from": accounts[0]})
    department = department_contract.getById("dept1")

    assert department[0] == "dept1"  # id
    assert department[1] == "New Department One"  # name
    assert department[2] == "NewHead1"  # headId
    assert department[3] == "NewOrg1"  # orgId

def test_get_all_departments(deploy_department_contract, create_profile):
    department_contract = deploy_department_contract
    department_contract.create("dept1", "Department One", "Head1", "Org1", {"from": accounts[0]})
    department_contract.create("dept2", "Department Two", "Head2", "Org2", {"from": accounts[0]})

    all_departments = department_contract.getAll()
    assert len(all_departments) == 2
    assert all_departments[0][0] == "dept1"
    assert all_departments[0][1] == "Department One"
    assert all_departments[1][0] == "dept2"
    assert all_departments[1][1] == "Department Two"

def test_delete_department(deploy_department_contract, create_profile):
    department_contract = deploy_department_contract
    department_contract.create("dept1", "Department One", "Head1", "Org1", {"from": accounts[0]})
    department_contract.deleteInstance("dept1", {"from": accounts[0]})
    department = department_contract.getById("dept1")

    assert department[4] is False  # is_active
