//pragma solidity ^0.4.18;
pragma solidity ^0.5.0;
import "./SafeMath.sol";
import "./ERC20Interface.sol";
import "./UniswapFactory.sol";


// exchange is a pool of token-eth trading
contract UniswapExchange {
    using SafeMath for uint256;

    /// EVENTS
    event EthToTokenPurchase(address indexed buyer, uint256 indexed ethIn, uint256 indexed tokensOut);
    event TokenToEthPurchase(address indexed buyer, uint256 indexed tokensIn, uint256 indexed ethOut);
    event Investment(address indexed liquidityProvider, uint256 indexed sharesPurchased);
    event Divestment(address indexed liquidityProvider, uint256 indexed sharesBurned);

    /// CONSTANTS
    //uint256 public constant FEE_RATE = 500;        // fee = 1/feeRate = 0.2%
    
    uint256 public feeRate = 500;       // fee = 1/feeRate
    uint256 public MIN_FEE_RATE = 100;  // 1%
    uint256 public MAX_FEE_RATE = 1000; // 0.1%

    /// STORAGE
    uint256 public ethPool;             // amount of eth in exchange
    uint256 public tokenPool;           // amount of token in exchange
    uint256 public invariant;           // = ethPool * tokenPool
    uint256 public totalShares;         // 
    address public tokenAddress;        // token address
    address public factoryAddress;      // factory address which register this exchange
    mapping(address => uint256) shares; // 
    ERC20Interface token;
    FactoryInterface factory;

    /// MODIFIERS
    // check if this exchange is initialized
    modifier exchangeInitialized() {
        require(invariant > 0 && totalShares > 0);
        _;
    }

    /// CONSTRUCTOR
    // set token & factory
    constructor(address _tokenAddress) public payable {
        // set token
        tokenAddress = _tokenAddress;
        token = ERC20Interface(tokenAddress);
        
        // set factory
        factoryAddress = msg.sender;
        factory = FactoryInterface(factoryAddress);
    }

    /// FALLBACK FUNCTION
    function() external payable {
        require(msg.value != 0);
        ethToToken(msg.sender, msg.sender, msg.value, 1);
    }

    /// EXTERNAL FUNCTIONS
    // CAUSION: need to execute approve(this_contract_address, amount) before execute this function due to token.transferFrom()
    function initializeExchange(uint256 _tokenAmount) external payable {
        // you can initialize exchange only at first time
        require(invariant == 0 && totalShares == 0);
        
        // Prevents share cost from being too high or too low - potentially needs work
        require(msg.value >= 10000 && _tokenAmount >= 10000 && msg.value <= 5*10**18);
        
        // set exchange values
        ethPool = msg.value;
        tokenPool = _tokenAmount;
        invariant = ethPool.mul(tokenPool);
        
        // set share
        shares[msg.sender] = 1000;
        totalShares = 1000;
        
        // send token to exchange
        require(token.transferFrom(msg.sender, address(this), _tokenAmount));
    }

    // Buyer swaps ETH for Tokens
    // = Payer pays in ETH, payer receives Tokens
    function ethToTokenSwap(
        uint256 _minTokens,
        uint256 _timeout
    )
        external
        payable
    {
        // need to meet some conditions
        require(msg.value > 0 && _minTokens > 0 && now < _timeout);
        
        // get eth from sender & give token to sender
        ethToToken(msg.sender, msg.sender, msg.value,  _minTokens);
    }

    // Payer pays in ETH, recipient receives Tokens
    function ethToTokenPayment(
        uint256 _minTokens,
        uint256 _timeout,
        address _recipient
    )
        external
        payable
    {
        // need to meet some conditions
        require(msg.value > 0 && _minTokens > 0 && now < _timeout);
        
        // do not give bad recipient
        require(_recipient != address(0) && _recipient != address(this));
        
        // get eth from sender & give token to recipient
        ethToToken(msg.sender, _recipient, msg.value,  _minTokens);
    }

    // Buyer swaps Tokens for ETH
    // = Payer pays in Tokens, payer receives ETH
    function tokenToEthSwap(
        uint256 _tokenAmount,
        uint256 _minEth,
        uint256 _timeout
    )
        external
    {
        // need to meet some conditions
        require(_tokenAmount > 0 && _minEth > 0 && now < _timeout);
        
        // get token from sender & give eth to sender
        tokenToEth(msg.sender, msg.sender, _tokenAmount, _minEth);
    }

    // Payer pays in Tokens, recipient receives ETH
    function tokenToEthPayment(
        uint256 _tokenAmount,
        uint256 _minEth,
        uint256 _timeout,
        address payable _recipient
    )
        external
    {
        // need to meet some conditions
        require(_tokenAmount > 0 && _minEth > 0 && now < _timeout);
        
        // do not give bad recipient
        require(_recipient != address(0) && _recipient != address(this));
        
        // get token from sender & give eth to recipient
        tokenToEth(msg.sender, _recipient, _tokenAmount, _minEth);
    }

    // Buyer swaps Tokens in current exchange for Tokens of provided address
    function tokenToTokenSwap(
        address _tokenPurchased,        // Must be a token with an attached Uniswap exchange (Buyer buyes this token)
        uint256 _tokensSold,            // buyer gives this amont of token to this exchange
        uint256 _minTokensReceived,     // buyer wants to get at least this amount of token
        uint256 _timeout
    )
        external
    {
        // need to meet some conditions
        require(_tokensSold > 0 && _minTokensReceived > 0 && now < _timeout);
        
        // get token from sender & give other token to sender
        tokenToTokenOut(_tokenPurchased, msg.sender, msg.sender, _tokensSold, _minTokensReceived);
    }

    // Payer pays in exchange Token, recipient receives Tokens of provided address
    function tokenToTokenPayment(
        address _tokenPurchased,
        address _recipient,
        uint256 _tokensSold,
        uint256 _minTokensReceived,
        uint256 _timeout
    )
        external
    {
        // need to meet some conditions
        require(_tokensSold > 0 && _minTokensReceived > 0 && now < _timeout);
        
        // do not give bad recipient
        require(_recipient != address(0) && _recipient != address(this));
        
        // get token from sender & give other token to recipient
        tokenToTokenOut(_tokenPurchased, msg.sender, _recipient, _tokensSold, _minTokensReceived);
    }

    // Function called by another Uniswap exchange in Token to Token swaps and payments
    function tokenToTokenIn(
        address _recipient,
        uint256 _minTokens
    )
        external
        payable
        returns (bool)
    {
        // should send ether
        require(msg.value > 0);
        
        // this request should be from registered exchange
        address exchangeToken = factory.exchangeToTokenLookup(msg.sender);
        require(exchangeToken != address(0));   // Only a Uniswap exchange can call this function
        
        // same as other exchange change his eth to token, and give it to recipient
        ethToToken(msg.sender, _recipient, msg.value, _minTokens);
        return true;
    }

    // Invest liquidity and receive market shares
    function investLiquidity(
        uint256 _minShares
    )
        external
        payable
        exchangeInitialized
    {
        require(msg.value > 0 && _minShares > 0);
        uint256 ethPerShare = ethPool.div(totalShares);
        require(msg.value >= ethPerShare);
        uint256 sharesPurchased = msg.value.div(ethPerShare);
        require(sharesPurchased >= _minShares);
        uint256 tokensPerShare = tokenPool.div(totalShares);
        uint256 tokensRequired = sharesPurchased.mul(tokensPerShare);
        shares[msg.sender] = shares[msg.sender].add(sharesPurchased);
        totalShares = totalShares.add(sharesPurchased);
        ethPool = ethPool.add(msg.value);
        tokenPool = tokenPool.add(tokensRequired);
        invariant = ethPool.mul(tokenPool);
        emit Investment(msg.sender, sharesPurchased);
        require(token.transferFrom(msg.sender, address(this), tokensRequired));
    }

    // Divest market shares and receive liquidity
    function divestLiquidity(
        uint256 _sharesBurned,
        uint256 _minEth,
        uint256 _minTokens
    )
        external
    {
        require(_sharesBurned > 0);
        shares[msg.sender] = shares[msg.sender].sub(_sharesBurned);
        uint256 ethPerShare = ethPool.div(totalShares);
        uint256 tokensPerShare = tokenPool.div(totalShares);
        uint256 ethDivested = ethPerShare.mul(_sharesBurned);
        uint256 tokensDivested = tokensPerShare.mul(_sharesBurned);
        require(ethDivested >= _minEth && tokensDivested >= _minTokens);
        totalShares = totalShares.sub(_sharesBurned);
        ethPool = ethPool.sub(ethDivested);
        tokenPool = tokenPool.sub(tokensDivested);
        if (totalShares == 0) {
            invariant = 0;
        } else {
            invariant = ethPool.mul(tokenPool);
        }
        emit Divestment(msg.sender, _sharesBurned);
        require(token.transfer(msg.sender, tokensDivested));
        msg.sender.transfer(ethDivested);
    }

    // View share balance of an address
    function getShares(
        address _provider
    )
        external
        view
        returns(uint256 _shares)
    {
        return shares[_provider];
    }

    /// INTERNAL FUNCTIONS
    function ethToToken(
        address buyer,
        address recipient,
        uint256 ethIn,
        uint256 minTokensOut
    )
        internal
        exchangeInitialized
    {
        // get fee
        uint256 fee = ethIn.div(feeRate);
        
        // calc new exchange values
        uint256 newEthPool = ethPool.add(ethIn);
        uint256 tempEthPool = newEthPool.sub(fee);
        uint256 newTokenPool = invariant.div(tempEthPool);
        
        // calc how much token to send
        uint256 tokensOut = tokenPool.sub(newTokenPool);
        require(tokensOut >= minTokensOut && tokensOut <= tokenPool);
        
        // set exchange values
        ethPool = newEthPool;
        tokenPool = newTokenPool;
        invariant = newEthPool.mul(newTokenPool);
        
        // event occur
        emit EthToTokenPurchase(buyer, ethIn, tokensOut);
        
        // send token to recipient
        require(token.transfer(recipient, tokensOut));
    }

    function tokenToEth(
        address buyer,
        address payable recipient,
        uint256 tokensIn,
        uint256 minEthOut
    )
        internal
        exchangeInitialized
    {
        // get fee
        uint256 fee = tokensIn.div(feeRate);
        
        // calc new exchange values
        uint256 newTokenPool = tokenPool.add(tokensIn);
        uint256 tempTokenPool = newTokenPool.sub(fee);
        uint256 newEthPool = invariant.div(tempTokenPool);
        
        // calc how much eth to send 
        uint256 ethOut = ethPool.sub(newEthPool);
        require(ethOut >= minEthOut && ethOut <= ethPool);
        
        // set new exchange values
        tokenPool = newTokenPool;
        ethPool = newEthPool;
        invariant = newEthPool.mul(newTokenPool);
        
        // event occur
        emit TokenToEthPurchase(buyer, tokensIn, ethOut);
        
        // get token from buyer
        require(token.transferFrom(buyer, address(this), tokensIn));
        
        // give eth to repicient
        recipient.transfer(ethOut);
    }

    function tokenToTokenOut(
        address tokenPurchased, // Buyer buyes this token and give it to recipient
        address buyer,
        address recipient,
        uint256 tokensIn,       // Buyer payes this amount of token to buy other token
        uint256 minTokensOut
    )
        internal
        exchangeInitialized
    {
        // need to meet some conditions
        require(tokenPurchased != address(0) && tokenPurchased != address(this));
        
        // token should be registered within other exchange
        address payable exchangeAddress = addrToPayable(factory.tokenToExchangeLookup(tokenPurchased));
        require(exchangeAddress != address(0) && exchangeAddress != address(this));
        
        // set fee
        uint256 fee = tokensIn.div(feeRate);
        
        // calc new exchange values
        uint256 newTokenPool = tokenPool.add(tokensIn);
        uint256 tempTokenPool = newTokenPool.sub(fee);
        uint256 newEthPool = invariant.div(tempTokenPool);
        
        // calc how much eth to send to other exchange
        uint256 ethOut = ethPool.sub(newEthPool);
        require(ethOut <= ethPool);
        
        // get other exchange
        UniswapExchange exchange = UniswapExchange(exchangeAddress);
        emit TokenToEthPurchase(buyer, tokensIn, ethOut);
        
        // set exchange values
        tokenPool = newTokenPool;
        ethPool = newEthPool;
        invariant = newEthPool.mul(newTokenPool);
        
        // get token from buyer
        require(token.transferFrom(buyer, address(this), tokensIn));
        
        // give other token to recipient from other exchange
        require(exchange.tokenToTokenIn.value(ethOut)(recipient, minTokensOut));
    }
    
    // cast address to payable address
    function addrToPayable(address addr) public pure returns (address payable){
        address payable pAddr = address(uint160(addr));
        return pAddr;
    }
    
    
    //
    // fee rate functions
    //
    
    // update fee rate with predicted power values
    function updateFeeRate(uint prevPower, uint curPower) public {
        // only factory can call this function
        require(msg.sender == factoryAddress);
        
        // update fee rate
        // high curPower -> high fee / low curPower -> low fee
        feeRate = feeRate * prevPower / curPower;
        if (feeRate > MAX_FEE_RATE){
            feeRate = MAX_FEE_RATE;
        }
        if (feeRate < MIN_FEE_RATE){
            feeRate = MIN_FEE_RATE;
        }
    }
    
    function setFeeRate(uint newFeeRate) public {
        feeRate = newFeeRate;
    }
    
    function setMaxFeeRate(uint newMaxFeeRate) public{
        MAX_FEE_RATE = newMaxFeeRate;
    }
    
    function setMinFeeRate(uint newMinFeeRate) public{
        MIN_FEE_RATE = newMinFeeRate;
    }
    
}





