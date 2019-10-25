how to setting uniswap
----------------------

1. deploy TestToken contract

2. mint token to user (execute mint() in TestToken)

3. deploy UniswapFactory contract

4. deploy UniswapExchange contract via UniswapFactory (execute launchExchange() in UniswapFactory)

5. get UniswapExchange contract's address (execute tokenToExchangeLookup() in UniswapFactory)

6. approve user's token to contract (execute approve() in TestToken)

7. initialize UniswapExchange (execute initializeExchange() in UniswapExchange)  
  (with at least 10,000 wei & 10,000 token)



how to buy eth or token
-----------------------

* if you want to buy eth with token, approve token to contract first
	(execute approve(contract, amount) in TestToken)
  then execute tokenToEthSwap in UniswapExchange

* if you want to buy token with eth, execute ethToTokenSwap in UniswapExchange
