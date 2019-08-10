pragma solidity ^0.5.1;

import "github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol";

//*** Exercice 1 ***//
// Simple token you can buy and send.
contract SimpleToken {
    mapping(address => uint) public balances;
    address public owner = msg.sender;
 
    function withdraw() public onlyOwner() {
    uint amount = balances[msg.sender];
    require(amount <= balances[msg.sender]);
    balances[msg.sender] = 0;
    msg.sender.transfer(amount);
    }

    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
    }

    /// @dev Buy token at the price of 1ETH/token.
    function buyToken() public payable {
        balances[msg.sender]+=msg.value / 1 ether;
    }

    /** @dev Send token.
     *  @param _recipient The recipient.
     *  @param _amount The amount to send.
     */
    function sendToken(address _recipient, uint _amount) public onlyOwner() {
        require(balances[msg.sender]!=0); // You must have some tokens.
        require(balances[msg.sender] >= _amount);
        require(owner != _recipient);
        balances[msg.sender]-=_amount;
        balances[_recipient]+=_amount;
    }
    
}

//*** Exercice 2 ***//
// You can buy voting rights by sending ether to the contract.
// You can vote for the value of your choice.
contract VoteTwoChoices { 
    mapping(address => uint) public votingRights;
    mapping(address => uint) public votesCast;
    mapping(bytes32 => uint) public votesReceived;
    address public owner = msg.sender;

    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
    }
    
    /// @dev Get 1 voting right per ETH sent.
    function buyVotingRights() public payable {
        votingRights[msg.sender]+=msg.value/(1 ether);
    }
    
    /** @dev Vote with nbVotes for a proposition.
     *  @param _nbVotes The number of votes to cast.
     *  @param _proposition The proposition to vote for.
     */
    function vote(uint _nbVotes, bytes32 _proposition) public onlyOwner() {
        require(_nbVotes + votesCast[msg.sender]<=votingRights[msg.sender]); // Check you have enough voting rights.
        require(_proposition[0] != 0);

        votesCast[msg.sender]+=_nbVotes;
        votesReceived[_proposition]+=_nbVotes;
    }

    function sellVotingRights() public onlyOwner() {
        uint amount = votingRights[msg.sender];
        require(amount <= votingRights[msg.sender]);
        votingRights[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

}

//*** Exercice 3 ***//
// You can buy tokens.
// The owner can set the price.
contract BuyToken {
    using SafeMath for uint256;
    mapping(address => uint) public balances;
    uint256 public price=1;
    address private owner=msg.sender;
    
    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
    }

    /** @dev Buy tokens.
     *  @param _amount The amount to buy.
     *  @param _price  The price to buy those in ETH.
     */

    function buyToken(uint _amount, uint _price) public payable {
        uint256 safeAmount = uint(_amount).mul(_price);
        require(_price>=price); // The price is at least the current price.
        require(safeAmount.mul(1 ether) <= msg.value); // You have paid at least the total price.
        balances[msg.sender]+=_amount;
    }

    function withdraw() public {
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
    
    /** @dev Set the price, only the owner can do it.
     *  @param _price The new price.
     */
    function setPrice(uint _price) public onlyOwner() {
        require(msg.sender==owner);
        
        price=_price;
    }
}

//*** Exercice 4 ***//
// Contract to store and redeem money.
contract Store {
    struct Safe {
        address owner;
        uint amount;
    }
    
    Safe[] public safes;
    
    /// @dev Store some ETH.
    function store() payable public {
        safes.push(Safe({owner: msg.sender, amount: msg.value}));
    }
    
    /// @dev Take back all the amount stored.
    function take() public {
        for (uint i; i<safes.length; ++i) {
            Safe storage safe = safes[i];
            if (safe.owner==msg.sender && safe.amount!=0) {
                safe.amount=0;
                msg.sender.transfer(safe.amount);
            }
        }
        
    }
}


//*** Exercice 5 ***//
// Count the total contribution of each user.
// Assume that the one creating the contract contributed 1ETH.
contract CountContribution {
    using SafeMath for uint;
    mapping(address => uint) public contribution;
    uint public totalContributions;
    address private owner=msg.sender;
    
    /// @dev Constructor, count a contribution of 1 ETH to the creator.
    function countContribution() public view{
        recordContribution(owner, 1 ether);
    }
    
    /// @dev Contribute and record the contribution.
    function contribute() public payable {
        recordContribution(msg.sender, msg.value);
    }
    
    /** @dev Record a contribution. To be called by CountContribution and contribute.
     *  @param _user The user who contributed.
     *  @param _amount The amount of the contribution.
     */
    function recordContribution(address _user, uint _amount) public view {
        contribution[_user].add(_amount);
        totalContributions.add(_amount);
    }
    
}

//*** Exercice 6 ***//
contract Token {
    mapping(address => uint) public balances;
    
    /// @dev Buy token at the price of 1ETH/token.
    function buyToken() public payable {
        balances[msg.sender]+=msg.value / 1 ether;
    }
    
    /** @dev Send token.
     *  @param _recipient The recipient.
     *  @param _amount The amount to send.
     */
    function sendToken(address _recipient, uint _amount) public {
        require(balances[msg.sender]>=_amount); // You must have some tokens.
        
        balances[msg.sender]-=_amount;
        balances[_recipient]+=_amount;
    }
    
    /** @dev Send all tokens.
     *  @param _recipient The recipient.
     */
    function sendAllTokens(address _recipient) public {
        balances[_recipient]+=balances[msg.sender];
        balances[msg.sender]=0;
    }
    
}

//*** Exercice 7 ***//
// You can buy some object.
// Further purchases are discounted.
// You need to pay basePrice / (1 + objectBought), where objectBought is the number of object you previously bought.
contract DiscountedBuy {
    using SafeMath for uint;
    uint public basePrice = 1 ether;
    mapping (address => uint) public objectBought;

    /// @dev Buy an object.
    function buy() public payable {
        require(msg.value.mul(objectBought[msg.sender].add(1)) == basePrice);
        objectBought[msg.sender]+=1;
    }
    
    /** @dev Return the price you'll need to pay.
     *  @return price The amount you need to pay in wei.
     */
    function price() public view returns(uint _price) {
        return basePrice/(1 + objectBought[msg.sender]);
    }
    
}

//*** Exercice 8 ***//
// You choose Head or Tail and send 1 ETH.
// The next party send 1 ETH and try to guess what you chose.
// If it succeed it gets 2 ETH, else you get 2 ETH.
contract HeadOrTail {
    bool public chosen; // True if head/tail has been chosen.
    bool public lastChoiceHead; // True if the choice is head.
    address payable public lastParty; // The last party who chose.
    address private owner;
    
    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
    }
    /** @dev Must be sent 1 ETH.
     *  Choose head or tail to be guessed by the other player.
     *  @param _chooseHead True if head was chosen, false if tail was chosen.
     */
    function choose(bool _chooseHead) payable public {
        require(!chosen);
        require(msg.value == 1 ether);
        
        chosen=true;
        lastChoiceHead=_chooseHead;
        lastParty=msg.sender;
    }
    
    
    function guess(bool _guessHead) payable public onlyOwner() {
        require(chosen);
        require(msg.value == 1 ether);
        chosen=false;
        if (_guessHead == lastChoiceHead)
            msg.sender.transfer(2 ether);
        else
            lastParty.transfer(2 ether);
            
    }
}

//*** Exercice 9 ***//
// You can store ETH in this contract and redeem them.
contract Vault {
    using SafeMath for uint;
    mapping(address => uint) public balances;

    /// @dev Store ETH in the contract.
    function store() public payable {
        balances[msg.sender].add(msg.value);
    }
    
    /// @dev Redeem your ETH.
    function redeem() public {
        balances[msg.sender]=0;
        msg.sender.call.value(balances[msg.sender])("");
    }
}

//*** Exercice 10 ***//
// You choose Head or Tail and send 1 ETH.
// The next party send 1 ETH and try to guess what you chose.
// If it succeed it gets 2 ETH, else you get 2 ETH.
contract HeadTail {
    using SafeMath for uint;
    address payable public partyA;
    address payable public partyB;
    bytes32 public commitmentA;
    bool public chooseHeadB;
    uint public timeB;
    address private owner;
    
    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
    }

    /** @dev Constructor, commit head or tail.
     *  @param _commitmentA is keccak256(chooseHead,randomNumber);
     */
    function headTail(bytes32 _commitmentA) public payable {
        require(msg.value == 1 ether);
        
        commitmentA=_commitmentA;
        partyA=msg.sender;
    }
    
    /** @dev Guess the choice of party A.
     *  @param _chooseHead True if the guess is head, false otherwize.
     */
    function guess(bool _chooseHead) public payable {
        require(msg.value == 1 ether);
        require(partyB==address(0));
        
        chooseHeadB=_chooseHead;
        timeB=now;
        partyB=msg.sender;
    }
    
    /** @dev Reveal the commited value and send ETH to the winner.
     *  @param _chooseHead True if head was chosen.
     *  @param _randomNumber The random number chosen to obfuscate the commitment.
     */
    function resolve(bool _chooseHead, uint _randomNumber) public {
        require(msg.sender == partyA);
        require(keccak256(abi.encodePacked(_chooseHead, _randomNumber)) == commitmentA);
        require(address(this).balance >= 2 ether);
        
        if (_chooseHead == chooseHeadB)
            partyB.transfer(2 ether);
        else
            partyA.transfer(2 ether);
    }
    
    /** @dev Time out party A if it takes more than 1 day to reveal.
     *  Send ETH to party B.
     * */
    function timeOut() public onlyOwner() {
        require(now > timeB.add(1 days));
        require(address(this).balance>=2 ether);
        partyB.transfer(2 ether);
    }
}

//*** Exercice 11 ***//
// You can create coffers put money into it and withdraw it.
contract Coffers {
    struct Coffer {uint[] slots;}
    mapping (address => Coffer) public coffers;
    
    /** @dev Create coffers.
     *  @param _extraSlots The amount of slots to add to one's coffer.
     * */
    function createCoffers(uint _extraSlots) public {
        Coffer storage coffer = coffers[msg.sender];
        require(coffer.slots.length+_extraSlots >= _extraSlots);
        coffer.slots.length += _extraSlots;
    }
    
    /** @dev Deposit money in one's coffer slot.
     *  @param _slot The slot to deposit money.
     * */
    function deposit(uint _slot) public payable {
        Coffer storage coffer = coffers[msg.sender];
        coffer.slots[_slot] += msg.value;
    }
    
    /** @dev withdraw all of the money of  one's coffer slot.
     *  @param _slot The slot to withdraw money from.
     * */
    function withdraw(uint _slot) public {
        Coffer storage coffer = coffers[msg.sender];
        coffer.slots[_slot] = 0;
        msg.sender.transfer(coffer.slots[_slot]);
        
    }
}
//*** Exercice Bonus ***//
// One of the previous contracts has 2 vulnerabilities.
// Find which one and describe the second vulnerability.
