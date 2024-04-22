import os


BASE_DIR = os.path.abspath(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__)))))

BUILD_DIR = os.path.join(BASE_DIR, "build/")
DEPLOY_DIR = os.path.join(BUILD_DIR, "deploy/")
SOLIDITY_DIR = os.path.join(BUILD_DIR, "solidity/")


KEYSTORE_PATH = os.path.join(BASE_DIR, "data/node0/keystore/UTC--2024-04-19T01-31-47.211949099Z--8760b3adea7a62159829e37e07ae6af9f389e77b")
KEYSTORE_PASSWORD = "temppasswd" # TODO:MOVE THIS TO ENVIRNONMENT

GAS_PRICE = 0

NODE_URL = "http://127.0.0.1:8545"
