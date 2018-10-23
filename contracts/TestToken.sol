pragma solidity ^0.4.20;

/**
 * The TestToken contract represents the TT token, 
 */

contract TestToken {

	address public admin;

	function admined() public{
		admin = msg.sender;
	}

	modifier onlyAdmin{
		require(msg.sender == admin);
		_;
	}

	function transferAuthority(address newAdmin) onlyAdmin public{
		admin = newAdmin;
	}

	event TransferMintPermission(address indexed previousMinter, address indexed newMinter);

	modifier hasMintPermission() {
		require (msg.sender == minter || msg.sender == admin);
		_;
	}
	
	function givePermission(address _newMinter) public onlyAdmin{
		require (_newMinter != address(0));
		emit TransferMintPermission(minter, _newMinter);
		minter = _newMinter;		
	}

	address public minter;

////////////////////////////////////////////

/* token - Actual ERC20 implementatation */

	// token info and the details 
	string public name = "Test Token";
	string public symbol = "TT";
	string public standard = "TT token version 1.0";
	uint256 public decimals = 4;
	uint256 public totalSupply;

	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);

	// event for the burn function, which needs to be deleted later
	event Burn(address indexed from, uint256 value);
	mapping (address => uint256) public balanceOf;
	mapping (address => mapping (address => uint256)) public allowance; 
	
	constructor(uint256 _initialSupply) public{
		balanceOf[msg.sender] = _initialSupply;
		totalSupply = _initialSupply;
	}

	function _transfer(address _from, address _to, uint256 _value) internal{
		require (_to != 0x0);
		require(balanceOf[_from] >= _value);
		require(balanceOf[_to] + _value >= balanceOf[_to]);
		uint previousBalances = balanceOf[_from] + balanceOf[_to];
		
		balanceOf[_from] -= _value;
		balanceOf[_to] += _value;
		
		emit Transfer(_from, _to, _value);	
		assert(balanceOf[_to] + balanceOf[_from] == previousBalances);
	}

	// transfer function as described in the ERC20 standards 
	function transfer(address _to, uint256 _value) public returns(bool success){
		_transfer(msg.sender, _to, _value);
		return true;
	}

	function approve(address _spender, uint256 _value) public returns(bool success){
		allowance[msg.sender][_spender] = _value;	
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns(bool success){
		require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
	} 			

	function mintToken(address target, uint256 mintedAmount) hasMintPermission public{
		balanceOf[target] += mintedAmount;
		totalSupply += mintedAmount;
		emit Transfer(0, this, mintedAmount);
		emit Transfer(this, target, mintedAmount);
	}

	function burn(uint256 _value) public returns (bool success){
		require(balanceOf[msg.sender] >= _value);
		balanceOf[msg.sender] -= _value;
		totalSupply -= _value;
		emit Burn(msg.sender, _value);
		return true;
	}
	// no need to implement in here, no need to kill the token even after the main net deployment
	function kill() onlyAdmin public{
		selfdestruct(admin);
	}


}


