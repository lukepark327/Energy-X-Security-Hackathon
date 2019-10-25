import json
import time
import os
import sys
from web3 import Web3

import arguments

sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
sys.path.append(os.path.dirname(
    os.path.abspath(os.path.dirname(__file__))) + "/PPDL")

from block import readBlock, printBlock


# hardcoding factors
AvgBlockInterval = 3.0

# Web3
w3 = Web3(Web3.HTTPProvider(
    "https://ropsten.infura.io/v3/33984e2b04db41fc956d74f97be64385"))

# contract_ = w3.eth.contract(
#     abi=contract_interface['abi'],
#     bytecode=contract_interface['bin'])

# acct = w3.eth.account.privateKeyToAccount(privateKey)

# construct_txn = contract_.constructor().buildTransaction({
#     'from': acct.address,
#     'nonce': w3.eth.getTransactionCount(acct.address),
#     'gas': 1728712,
#     'gasPrice': w3.toWei('21', 'gwei')})

# signed = acct.signTransaction(construct_txn)

# w3.eth.sendRawTransaction(signed.rawTransaction)

# read contract etc.
# echo `solc --combined-json abi,bin,interface UniswapExchange.sol` > UniswapExchange.json
json_file = open('./uniswap/UniswapFactory.json')
contract_interface = json.load(
    json_file)['contracts']['UniswapFactory.sol:UniswapFactory']
# print(contract_interface.keys())
json_file.close()

contract_ = w3.eth.contract(
    address=Web3.toChecksumAddress(
        "0x91dc3c1781ef83587061597e94c9b57b99991145"),
    abi=contract_interface['abi']
)
addr = w3.toChecksumAddress("0xf0E7570a403515Da23323dbb27515dF5b7ae6077")
private_key = "6D6939C68E783DB0FBA13AD842EB17B1D60764110F08253FCC88D02A81CB495C"


def pinwheel(t, keyword=""):
    t = t % 4
    if t == 0:
        print(keyword, "\\", end='\r')
    elif t == 1:
        print(keyword, "|", end='\r')
    elif t == 2:
        print(keyword, "/", end='\r')
    elif t == 3:
        print(keyword, "-", end='\r')


# TODO
def pinwheel_with_ETA(t, keyword=""):
    pass


fileTimes = []
respTimes = []


def insertBlock_():
    nonce = w3.eth.getTransactionCount(addr)

    tx = contract_.functions.insertBlock(
        1,
        "155de59a1b74e0dc306f4f1fbe6bf4b225c60003c518e9ef85b95143ef1b4429",
        "8ffe1475aef971e68cd73aab7201ac1ffe8c1aeed19b39f8bfff22214f375610",
        "93653b581022cdf42e8610a17c0dcf6711bd76bc6a538b366851c8a77a540e99",
        "4dcf48ab5506404007ba89c485e1203ce07a8344c3da0c7f98b361a4d9408733",
        1571981872
    ).buildTransaction({
        'gas': 700000,
        'gasPrice': w3.toWei('1', 'gwei'),
        'from': addr,
        'nonce': nonce
    })

    signed_txn = w3.eth.account.signTransaction(tx, private_key=private_key)
    tx_hash = w3.eth.sendRawTransaction(signed_txn.rawTransaction)

    # print(tx_hash)


def sendTransaction(currentBlock, i):
    def avgTime(times):
        if len(times) == 0:
            return 0.0
        else:
            return sum(times) / len(times)

    file_list = os.listdir("../data/blocks")
    print()
    print("> Relay block (%d / %d)" % (i, len(file_list) - 1))

    # read block
    startTime = time.time()
    t = 0
    while True:
        try:
            flblock = readBlock("../data/blocks", i)
            break
        except FileNotFoundError:
            pinwheel(
                t, keyword="> waiting for FL chain to expand... (ETA: %f)" % avgTime(fileTimes))
            t += 1
            time.sleep(AvgBlockInterval)
            pass
    endTime = time.time()
    elapsedTime = endTime - startTime
    if t != 0:
        fileTimes.append(elapsedTime)
        print(" " * 64, end="\r")
        print("> [readBlock] Done... (elapsed time: %f)" % elapsedTime)

    printBlock(flblock)

    # insertBlock
    res = insertBlock_()
    # print(res)

    # waiting
    startTime = time.time()
    t = 0
    while currentBlock == i:
        pinwheel(t, keyword="> waiting for Contract to be updated... (ETA: %f)" %
                 avgTime(respTimes))
        # print(currentBlock, i)
        # time.sleep(0.1)
        res = contract_.functions.getBlocksLength().call()
        currentBlock = int(res)
        t += 1
    endTime = time.time()
    elapsedTime = endTime - startTime
    respTimes.append(elapsedTime)
    print(" " * 64, end="\r")
    print("> [relay] Done... (elapsed time: %f)" % elapsedTime)

    return currentBlock


# run on `code` directory.
if __name__ == "__main__":
    args = arguments.parser()
    endBlock = args.block
    print("> Setting:", args)

    # getBlocksLength
    res = contract_.functions.getBlocksLength().call()
    startBlock = currentBlock = int(res)

    # relaying
    # CASE 1: no limit
    if endBlock == 0:
        i = startBlock
        while True:
            currentBlock = sendTransaction(currentBlock, i)
            i += 1

    # CASE 2: limitation
    for i in range(startBlock, endBlock + 1):
        currentBlock = sendTransaction(currentBlock, i)
