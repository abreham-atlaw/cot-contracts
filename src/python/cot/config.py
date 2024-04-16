import os


BASE_DIR = os.path.abspath(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__)))))

BUILD_DIR = os.path.join(BASE_DIR, "build/")
DEPLOY_DIR = os.path.join(BUILD_DIR, "deploy/")
SOLIDITY_DIR = os.path.join(BUILD_DIR, "solidity/")


KEYSTORE_PATH = os.path.join(BASE_DIR, "data/node3/keystore/UTC--2024-04-13T16-53-52.640165587Z--f73d10dd4541e3e27b4ab319349fbcdbd9421f0f")
KEYSTORE_PASSWORD = "temppasswd" # TODO:MOVE THIS TO ENVIRNONMENT

GAS_PRICE = 0

NODE_URL = "http://127.0.0.1:8545"
