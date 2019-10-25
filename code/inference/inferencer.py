import arguments
import json
from keras.models import Sequential
from keras.layers import Activation, Dense, Dropout
import tensorflow as tf
import numpy as np
from sklearn.preprocessing import MinMaxScaler
import time
import os
import sys
from web3 import Web3

sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))) + "/PPDL")

from block import readBlock, printBlock
from model import FLModel
import preprocess


# Web3
w3 = Web3(Web3.HTTPProvider(
    "https://ropsten.infura.io/v3/33984e2b04db41fc956d74f97be64385"))

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


# hardcoding factors
# REOA = "0x128a8b8c9507aec53d949c53d5be57c4d98f9256"
# contractAddr = "0xaa7De5581188449339058e5908fC0B06e61db3f9"
waitingInterval = 1.0


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


def create_model(features):
    model = Sequential()
    model.add(Dense(input_dim=x_train.shape[1], units=512))
    model.add(Activation("relu"))
    model.add(Dropout(0.2))
    model.add(Dense(units=256))
    model.add(Activation("relu"))
    model.add(Dropout(0.2))
    model.add(Dense(units=128))
    model.add(Activation("relu"))
    model.add(Dropout(0.2))
    model.add(Dense(units=1))
    model.compile("nadam", "mse", ["mse"])

    return FLModel(model)


allowanceTimes = []
incenTimes = []
popTimes = []


def insertResponse_(reqID_, pw_):
    nonce = w3.eth.getTransactionCount(addr)
    # print(nonce)

    tx = contract_.functions.insertResponse(
        reqID_, pw_
    ).buildTransaction({
        'gas': 700000,
        'gasPrice': w3.toWei('1', 'gwei'),
        'from': addr,
        'nonce': nonce
    })

    signed_txn = w3.eth.account.signTransaction(tx, private_key=private_key)
    tx_hash = w3.eth.sendRawTransaction(signed_txn.rawTransaction)

    return tx_hash


def popRequest_():
    nonce = w3.eth.getTransactionCount(addr)
    # print(nonce)

    tx = contract_.functions.popRequest().buildTransaction({
        'gas': 700000,
        'gasPrice': w3.toWei('1', 'gwei'),
        'from': addr,
        'nonce': nonce
    })

    signed_txn = w3.eth.account.signTransaction(tx, private_key=private_key)
    tx_hash = w3.eth.sendRawTransaction(signed_txn.rawTransaction)

    return tx_hash


def sendTransaction(flmodel, flblock):
    def avgTime(times):
        if len(times) == 0:
            return 0.0
        else:
            return sum(times) / len(times)

    r = contract_.functions.getRequestLength().call()
    beforeRequestLength = int(r)

    # if no request
    if beforeRequestLength == 0:
        print("> no requests")
        time.sleep(waitingInterval)
        return

    r = contract_.functions.getRequest().call()
    res = r

    # get inputs
    userAddr = res[0]
    responseId = userAddr + str(res[1])
    infos = res[2]
    temperature, rain, windSpeed, windDirection, humidity, snow, year, month, day, hour, mon, tues, wed, thurs, fri, sat, sun = infos

    """inference"""
    inputs = np.expand_dims(infos, 0)

    flmodel.set_weights(flblock.weights)  # set weights

    X = inputs  # ToDo: normalization
    Y = flmodel.predict(X)

    power = round(Y.tolist()[0][0])

    """insertResponse"""
    res = insertResponse_(responseId, power)
    w3.eth.waitForTransactionReceipt(res)

    """pop request"""
    res = popRequest_()
    w3.eth.waitForTransactionReceipt(res)

    r = contract_.functions.getRequestLength().call()
    afterRequestLength = int(r)

    # waiting
    startTime = time.time()
    t = 0
    while afterRequestLength != beforeRequestLength - 1:
        pinwheel(t, keyword="> waiting for popping a request... (ETA: %f)" %
                 avgTime(popTimes))
        r = contract_.functions.getRequestLength().call()
        afterRequestLength = int(r)
        t += 1
    endTime = time.time()
    elapsedTime = endTime - startTime
    popTimes.append(elapsedTime)
    print(" " * 64, end="\r")
    print("> [pop] Done... (elapsed time: %f)" % elapsedTime)


if __name__ == "__main__":
    args = arguments.parser()
    print("> Setting:", args)

    # # set REOA
    # from_ = REOA

    # # get min_max_scaler
    # features, min_max_scaler = preprocessing.get_train_test(
    #     "./data/realworld", getScalar=True)

    features, x_train, y_train, x_test, y_test = preprocess.get_train_test()

    # set FL model
    # TODO: modified model with concatenate layer
    flmodel = create_model(features)

    while True:
        print()
        print("> Start new round")

        # get latest relayed block
        res = contract_.functions.getBlocksLength().call()
        latestBlock = int(res) - 1
        print("> latest relayed block: %d" % latestBlock)

        # read block
        flblock = readBlock("../data/blocks", latestBlock)
        # printBlock(flblock)

        """get request"""
        sendTransaction(flmodel, flblock)
