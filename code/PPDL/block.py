import hashlib
import numpy as np
import tensorflow as tf
import os
import pickle
import time
from keras.models import Sequential
from keras.layers import Activation, Dense, Dropout

class Header:
    def __init__(self, n: int, prev, w, t, p, timestamp: int):
        self.blockNumber = n
        self.prevBlockHash = prev
        self.weightHash = w
        self.testsetHash = t
        self.participantHash = p
        self.timestamp = timestamp


class Block:
    def __init__(self, blockNumber: int, prevBlockHash, weights: list, testset: tuple, participants: list, timestamp: int):
        self.header = Header(
            blockNumber,
            prevBlockHash,
            self.calWeightHash(weights),
            self.calTestsetHash(testset),
            self.calParticipantHash(participants),
            timestamp
        )
        self.weights = weights
        self.testset = testset
        self.participants = participants

    def calBlockHash(self):
        header_list = list()
        header_list.append(bytes(self.header.blockNumber))
        header_list.append(self.header.prevBlockHash.encode('utf-8'))
        header_list.append(self.header.weightHash.encode('utf-8'))
        header_list.append(self.header.testsetHash.encode('utf-8'))

        return self.__getHash(header_list)

    def calWeightHash(self, weights: list):
        weights_list = list()
        for weight in weights:
            # print("original:", weight, weight.shape, weight.dtype.name)
            # t = weight.dtype.name
            # s = weight.shape
            b = weight.tobytes()
            # f = np.frombuffer(b, dtype=t).reshape(s)
            # print("encoded :", f, f.shape, f.dtype.name)
            weights_list.append(b)
            # if type(weight) == np.ndarray:
            #     weight = weight.tolist()
            # weights_list.append(weight)

        return self.__getHash(weights_list)

    def calTestsetHash(self, testset: tuple):
        testset_list = list()
        for i in testset:
            # (x, y)
            if type(i) != np.ndarray:
                i = np.array(i)

            b = i.tobytes()
            testset_list.append(b)

        return self.__getHash(testset_list)

    def calParticipantHash(self, participants: list):
        participants = np.array(participants)
        participants.tobytes()
        return self.__getHash(participants)

    def __getHash(self, inputs=[]):
        SHA3 = hashlib.sha3_256()
        for i in inputs:
            SHA3.update(i)
        return SHA3.hexdigest()


def delegate(method, prop):
    def decorate(cls):
        setattr(cls, method,
                lambda self, *args, **kwargs:
                getattr(getattr(self, prop), method)(*args, **kwargs))
        return cls
    return decorate


@delegate("__len__", "blocks")
class Blockchain:
    def __init__(self, genesisBlock):
        self.blocks = [genesisBlock]

    def append(self, block):
        self.blocks.append(block)

    def getBlock(self, blockNumber):
        return self.blocks[blockNumber]

    # def len(self):
    #     pass


def printBlock(block: Block):
    print("{")
    print("    \"blockNumber\"    :", block.header.blockNumber, end=",\n")
    print("    \"prevBlockHash\"  :", block.header.prevBlockHash, end=",\n")
    print("    \"timestamp\"      :", block.header.timestamp, end=",\n")
    print("    \"weightHash\"     :", block.header.weightHash, end=",\n")
    print("    \"testsetHash\"    :", block.header.testsetHash, end=",\n")
    print("    \"participantHash\":", block.header.participantHash, end=",\n")
    print("    \"(+)testsetSize\" :", len(block.testset[0]), end=",\n")
    print("    \"(+)participants\":", len(block.participants), end=",\n")
    print("    \"(+)blockHash\"   :", block.calBlockHash())
    print("}")


def writeBlock(PATH, block: Block):
    # Create directory
    try:
        os.mkdir(PATH)  # Create target Directory
    except FileExistsError:
        pass

    # Write
    with open(PATH + "/block_" + str(block.header.blockNumber) + ".bin", "wb") as f:
        pickle.dump(block, f)


def readBlock(PATH, blockNumber: int):
    with open(PATH + "/block_" + str(blockNumber) + ".bin", "rb") as f:
        return pickle.load(f)


def writeBlockchain(PATH, blockchain: Blockchain):
    # Create directory
    try:
        os.mkdir(PATH)  # Create target Directory
    except FileExistsError:
        pass

    # Write
    with open(PATH + "/chain.bin", "wb") as f:
        pickle.dump(blockchain, f)


def readBlockchain(PATH):
    with open(PATH + "/chain.bin", "rb") as f:
        return pickle.load(f)


# if __name__ == "__main__":
#     from model import FLModel
#     import tensorflow as tf
#     from time import time

#     # load data
#     mnist = tf.keras.datasets.mnist
#     (x_train, y_train), (x_test, y_test) = mnist.load_data()
#     x_train, x_test = x_train / 255.0, x_test / 255.0
#     testset = (x_test, y_test)

#     # set FL model
#     model = Sequential()
#     model.add(Dense(input_dim=x_train.shape[1], units=512))
#     model.add(Activation("relu"))
#     model.add(Dropout(0.2))
#     model.add(Dense(units=256))
#     model.add(Activation("relu"))
#     model.add(Dropout(0.2))
#     model.add(Dense(units=128))
#     model.add(Activation("relu"))
#     model.add(Dropout(0.2))
#     model.add(Dense(units=1))
#     model.compile("nadam", "mse", ["mse"])
#     flmodel = FLModel(model)

#     # set Blockchain
#     init_weights = flmodel.get_weights()
#     genesis = Block(
#         0,
#         "0" * 64,
#         init_weights,
#         testset,
#         [],
#         int(time())
#     )
#     flchain = Blockchain(genesis)  # set blockchain with genesis block

#     flmodel.fit(x_train, y_train, epochs=1)  # training

#     nextBlockNumber = 1
#     modified_weight = flmodel.get_weights()
#     new_block = Block(
#         nextBlockNumber,
#         flchain.getBlock(nextBlockNumber - 1).calBlockHash(),
#         modified_weight,
#         testset,
#         [],
#         int(time())
#     )
#     flchain.append(new_block)

#     flmodel.evaluate(x_test, y_test)
#     print(flmodel.loss, flmodel.metrics)

#     # write blockchain
#     writeBlockchain("../data", flchain)

#     # read blockchain
#     flchain = readBlockchain("../data")
#     print(flchain.blocks[0].calBlockHash())
#     print(flchain.blocks[1].header.prevBlockHash)