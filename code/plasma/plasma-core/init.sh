# rm -rf keystore
# go-ethereum-1.9.6/build/bin/geth --datadir . account new
rm -rf geth
touch genesis.json
go-ethereum-1.9.6/build/bin/geth --datadir . init genesis.json 
