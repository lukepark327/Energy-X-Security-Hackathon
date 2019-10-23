pragma solidity ^0.5.0;

contract ERC20 {
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address _from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed _from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// electric power predict
contract PowerPredict{
    
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
        
        // inference data (16)
        int[] infos; // temperature, rain, windSpeed, windDirection, humidity, snow, year, month, day, mon, tues, wed, thurs, fri, sat, sun
    }
    infRequest[] infReqs;   // inference queue
    
    // inference response
    struct infResponse{
        int power;  // predicted electric power consumption
    }
    mapping(string=>infResponse) infResponses;  // response mapping (inf id -> inf response)
    
    // insert inference request to list
    function requestInference(int _reqTime, int[] memory _infos) public {
        infRequest memory req = infRequest(msg.sender, _reqTime, _infos);
        infReqs.push(req);
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
    }
    
    // read inference result (requestID = fromAddr + requestTime)
    function getResponse(string memory requestID) public view returns (int){
        
        // inf response should be exist
        require(infResponses[requestID].power > 0);
        
        return (infResponses[requestID].power);
    }
    
    
    
    
    
    //
    // token funcitons
    //
    
    function balanceOf() public view returns (uint) {
        ERC20 token = ERC20(tokenAddr);
        return token.balanceOf(msg.sender);
    }
    
    
    
    
    
    //
    // users' pay/paid record
    //
    
    struct payRecord{
        int payType; // 0: default rent fee, 1: additional rent fee, 2: return incentive
        uint amount;
        uint timestamp;
    }
    
    mapping(address=>payRecord[]) payRecords;
    
    function insertRecord(address addr, int _payType, uint _amount, uint _timestamp)public{
        payRecord memory pr = payRecord(_payType, _amount, _timestamp);
        payRecords[addr].push(pr);
    }
    
    function getRecord(address addr) public view returns (int[] memory, uint[] memory, uint[] memory){
        
        uint recordLength = payRecords[addr].length;
        int[] memory payTypes = new int[](recordLength);
        uint[] memory amounts = new uint[](recordLength);
        uint[] memory timestamps = new uint[](recordLength);
        
        for(uint i=0; i<recordLength; i++){
            payRecord memory pr = payRecords[addr][i];
            payTypes[i] = pr.payType;
            amounts[i] = pr.amount;
            timestamps[i] = pr.timestamp;
        }
        
       return (payTypes, amounts, timestamps);
    }
    
    
    
    
    
    //
    // reset everything
    //
    
    /*function resetAll() public {
        
        // solidity has no reset functions...
        
    }*/
    
    
    
    
    
}






