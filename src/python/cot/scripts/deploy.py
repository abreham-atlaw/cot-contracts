import sys
from cot.lib.deploy import SCDeployer
from cot import config


def main():
    contract_name = sys.argv[1]

    deployer = SCDeployer(
        node=config.NODE_URL,
        export_path=config.DEPLOY_DIR,
        keystore=config.KEYSTORE_PATH,
        keystore_password=config.KEYSTORE_PASSWORD,
        contract_path=config.SOLIDITY_DIR,
        gas_price=config.GAS_PRICE
    )

    deployer.deploy(contract_name, [])

if __name__ == "__main__":
    main()
