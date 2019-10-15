//pragma solidity ^0.4.18;
pragma solidity ^0.5.0;
import "./UniswapExchange.sol";


contract FactoryInterface {
    // index of tokens with registered exchanges
    address[] public tokenList;
    
    // token-exchange lookup tables
    mapping(address => address) tokenToExchange;
    mapping(address => address) exchangeToToken;
    
    // register new exchange
    function launchExchange(address _token) public returns (address exchange);
    
    // get # of registered token
    function getExchangeCount() public view returns (uint exchangeCount);
    
    // get address of the token's exchange
    function tokenToExchangeLookup(address _token) public view returns (address exchange);
    
    // get address of the exchange's token
    function exchangeToTokenLookup(address _exchange) public view returns (address token);
    
    // event: new exchange is registered
    event ExchangeLaunch(address indexed exchange, address indexed token);
}


// register new exchange & access to it with this factory contract
contract UniswapFactory is FactoryInterface {
    event ExchangeLaunch(address indexed exchange, address indexed token);

    // index of tokens with registered exchanges
    address[] public tokenList;
    
    // token-exchange lookup tables
    mapping(address => address) tokenToExchange;
    mapping(address => address) exchangeToToken;

    function launchExchange(address _token) public returns (address exchange) {
        
        // There can only be one exchange per token
        require(tokenToExchange[_token] == address(0));
        
        // do not give bad token address
        require(_token != address(0) && _token != address(this));
        
        // create new exchange contract
        UniswapExchange newExchange = new UniswapExchange(_token);
        
        // update token list
        tokenList.push(_token);
        
        // update lookup tables
        address newExchangeAddress = address(newExchange);
        tokenToExchange[_token] = newExchangeAddress;
        exchangeToToken[newExchangeAddress] = _token;
        
        // event occur
        emit ExchangeLaunch(newExchangeAddress, _token);
        
        // return exchange contract address
        return newExchangeAddress;
    }

    // get # of registered token
    function getExchangeCount() public view returns (uint exchangeCount) {
        return tokenList.length;
    }

    // get address of the token's exchange
    function tokenToExchangeLookup(address _token) public view returns (address exchange) {
        return tokenToExchange[_token];
    }

    // get address of the exchange's token
    function exchangeToTokenLookup(address _exchange) public view returns (address token) {
        return exchangeToToken[_exchange];
    }
}

