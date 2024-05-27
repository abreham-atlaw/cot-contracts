import os


BASE_DIR = os.path.abspath(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__)))))

BUILD_DIR = os.path.join(BASE_DIR, "build/")
DEPLOY_DIR = os.path.join(BUILD_DIR, "deploy/")
SOLIDITY_DIR = os.path.join(BUILD_DIR, "solidity/")


KEYSTORE_PATH = os.path.join(BASE_DIR, "data/node.remote/keystore/UTC--2024-05-24T06-59-28.035560526Z--95bb2e1af9f91713d6788bea51186dd4c5de882e")
KEYSTORE_PASSWORD = "temppasswd" # TODO:MOVE THIS TO ENVIRNONMENT

GAS_PRICE = 0

# NODE_URL = "http://127.0.0.1:8545"
NODE_URL = "http://cot.alwaysdata.net"