import sys
import os

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

    if contract_name == "*":
        for file in os.listdir(config.SOLIDITY_DIR):
            if file.endswith(".abi"):
                print(f"\n[+]Deploying {file}")
                try:
                    deployer.deploy(file.replace(".abi", ""), sys.argv[2:])
                except Exception as ex:
                    print(f"[-]Error has occurred. {ex}")
    else:
        deployer.deploy(contract_name, sys.argv[2:])

if __name__ == "__main__":
    main()
