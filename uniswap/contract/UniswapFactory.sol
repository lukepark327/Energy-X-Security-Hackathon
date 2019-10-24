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


contract ERC20 {
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address _from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed _from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
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
    
    
    
    
    
    // address of EPToken
    address tokenAddr = 0xaA4060a8BbA893Fa590b3C9CB841B2e877cC5EB1;
    
    // ElectricPower token
    ERC20 EPtoken = ERC20(tokenAddr);
    
    // owner of this contract
    address public owner;
    
    constructor() public{
        // set owner
        owner = msg.sender;
    }
    
    // only owner can execute a function
    modifier onlyOwner(){
        //require(msg.sender == owner);
        _;
    }
    
    
    
    
    
    //
    // functions for relayed blocks
    //
    
    // struct to get blocks from relayer
    struct FLBlockHeader{
        uint blockNumber;
        bytes32 prevBlockHash;
        bytes32 weightHash;
        bytes32 testSetHash;
        bytes32 participantHash;
        int64 timestamp;
    }
    
    FLBlockHeader[] public blocks;
    
    // insert block into blocks array
    function insertBlock(uint _blockNumber, bytes32 _prevBlockHash, bytes32 _weightHash, bytes32 _testSetHash, bytes32 _participantHash, int64 _timestamp) public onlyOwner{
        FLBlockHeader memory FLBlock = FLBlockHeader(_blockNumber, _prevBlockHash, _weightHash, _testSetHash, _participantHash, _timestamp);
        blocks.push(FLBlock);
    }
    
    // delete all block from blocks array
    function resetBlocks() public onlyOwner{
        uint blocksLength = blocks.length;
        for(uint i=0;i<blocksLength;i++){
            blocks.pop();
        }
    }
    
    // get block from blocks array
    function readBlock(uint _blockNumber) public view returns (uint, bytes32, bytes32, bytes32, bytes32, int64) {
        return (blocks[_blockNumber].blockNumber, blocks[_blockNumber].prevBlockHash, blocks[_blockNumber].weightHash, blocks[_blockNumber].testSetHash, blocks[_blockNumber].participantHash, blocks[_blockNumber].timestamp); 
    }
    
    function getBlocksLength()public view returns (uint){
        return blocks.length;
    }
    
    
    
    
    
    //
    // ML model inference
    //
    
    // inference request
    struct infRequest{
        // for request id
        address addr;
        int reqTime;
        
        // inference data (17)
        int[] infos; // temperature, rain, windSpeed, windDirection, humidity, snow, year, month, day, hour, mon, tues, wed, thurs, fri, sat, sun
    }
    infRequest[] infReqs;   // inference queue
    
    // inference response
    struct infResponse{
        int power;  // predicted electric power consumption
    }
    mapping(string=>infResponse) infResponses;  // response mapping (inf id -> inf response)
    int public latestPredictedPower;            // latest response
    
    // insert inference request to list
    function requestInference(int _reqTime, int[] memory _infos) public {
        infRequest memory req = infRequest(msg.sender, _reqTime, _infos);
        infReqs.push(req);
        
        // TODO: test code for front end
        latestPredictedPower = int(block.timestamp);
    }
    
    // for relayer, to get request from list
    function getRequest() public view returns (address, int, int[] memory) {
        // get latest request
        infRequest memory req = infReqs[infReqs.length-1];
        //infReqs.pop(); // due to this, cannot get return values. so move this into deleteRequest() function
        
        return (req.addr, req.reqTime, req.infos);
    }
    
    // pop latest inference request
    function popRequest() public{
        infReqs.pop();
    }
    
    // get # of inference requests
    function getRequestLength() public view returns (uint){
        return infReqs.length;
    }
    
    // for relayer, delete latest request
    function deleteRequest() public{
        infReqs.pop();
    }
    
    // for relayer, to insert inference result to list (requestID = fromAddr + requestTime)
    function insertResponse(string memory requestID, int _power) public {
        infResponse memory res = infResponse(_power);
        infResponses[requestID] = res;
        
        // update fee rate for every exchanges
        uint prevPower = uint(latestPredictedPower);
        if (prevPower == 0){
            prevPower = uint(_power);
        }
        uint curPower = uint(_power);
        for (uint i=0;i<tokenList.length;i++){
            address payable exchangeAddr = address(uint160(tokenToExchange[tokenList[i]]));
            UniswapExchange ex = UniswapExchange(exchangeAddr);
            ex.updateFeeRate(prevPower, curPower);
        }
        
        // update latest predicted power
        latestPredictedPower = _power;
    }
    
    // read inference result (requestID = fromAddr + requestTime)
    function getResponse(string memory requestID) public view returns (int){
        
        // inf response should be exist
        require(infResponses[requestID].power > 0);
        
        return (infResponses[requestID].power);
    }
    
    
    
}


