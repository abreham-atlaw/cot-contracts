import os


BASE_DIR = os.path.abspath(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__)))))

BUILD_DIR = os.path.join(BASE_DIR, "build/")
DEPLOY_DIR = os.path.join(BUILD_DIR, "deploy/")
SOLIDITY_DIR = os.path.join(BUILD_DIR, "solidity/")


KEYSTORE_PATH = os.path.join(BASE_DIR, "data/node1/keystore/UTC--2024-05-18T10-36-01.139133873Z--750a6c1a06ef0397c7585f5e64550d7778465453")
KEYSTORE_PASSWORD = "temppasswd" # TODO:MOVE THIS TO ENVIRNONMENT

GAS_PRICE = 0

NODE_URL = "http://127.0.0.1:8545"
