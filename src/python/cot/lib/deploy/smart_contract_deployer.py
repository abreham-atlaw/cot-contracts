from web3 import Web3
import web3

import os
import json
import random

class SCDeployer:


    def __init__(
            self, 
            node: str, 
            export_path: str,
            keystore: str, 
            keystore_password: str,
            contract_path: str,
            gas_price: int = 0
        ):
        self.__client = Web3(Web3.HTTPProvider(node))
        self.__client.middleware_onion.inject(web3.middleware.geth_poa_middleware, layer=0)
        self.__private_key = self.__get_private_key(self.__client, keystore, keystore_password)
        self.__client.eth.default_account = self.__client.eth.accounts[0]
        self.__export_path = export_path
        self.__gas_price = gas_price
        self.__contract_path = contract_path
    
    @staticmethod
    def __get_private_key(w3: Web3, keystore: str, password: str) -> str:
        with open(keystore, "r") as keyfile:
            private_key = w3.eth.account.decrypt(keyfile.read(), password)
        print(f"Private Key: {private_key.hex()}")
        return private_key
    
    def __export(self, abi, tx_receipt, name: str):
        export_path = os.path.join(self.__export_path, f"{name}.json")
        with open(export_path, "w") as file:
            json.dump({
                "abi": abi,
                "address": tx_receipt["contractAddress"] 
            }, file)
        return export_path
        

    def __load_abi(self, name: str) -> list:
        with open(os.path.join(self.__contract_path, f"{name}.abi"), "r") as file:
            return json.load(file)
    
    def __load_bytecode(self, name: str) -> str:
        with open(os.path.join(self.__contract_path, f"{name}.bin"), "r") as file:
            return file.read()

    def __report_balance(self):
        print(f"[+]Current Balance: {self.__client.eth.get_balance(self.__client.eth.default_account)}")

    def __transact(self, contract, args, nonce=None):
        if nonce is None:
            nonce = self.__client.eth.get_transaction_count(self.__client.eth.default_account)
        print("[+]Transacting...")
        try:
            raw_tx = contract.constructor(*args).build_transaction({
                "gasPrice": self.__gas_price,
                "from": self.__client.eth.default_account,
                "nonce": nonce
            })

            signed_tx = self.__client.eth.account.sign_transaction(raw_tx, self.__private_key)

            tx_hash = self.__client.eth.send_raw_transaction(signed_tx.rawTransaction)
            print("[+]Waiting for Transaction...")
            tx_receipt = self.__client.eth.wait_for_transaction_receipt(tx_hash)
            return tx_receipt
        
        except ValueError as ex:
            print(f"[-]Value Error: {ex}")
            print("[+]Retrying...")
            return self.__transact(contract, args, nonce+1)


    def deploy(self, contract_name: str, args):
        print("[+]Starting Deployment...")
        self.__report_balance()

        contract_api = self.__load_abi(contract_name)
        contract_bytecode = self.__load_bytecode(contract_name)

        contract = self.__client.eth.contract(
            abi=contract_api, 
            bytecode=contract_bytecode
        )

        tx_receipt = self.__transact(contract, args)
        
        print("[+]Deployment Complete...")
        self.__report_balance()

        export_path = self.__export(contract_api, tx_receipt, contract_name)
        print(f"[+]Exported to ${export_path}")




    