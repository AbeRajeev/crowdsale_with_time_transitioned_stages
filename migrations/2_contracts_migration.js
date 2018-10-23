var TestToken = artifacts.require("./TestToken.sol");
var TestTokenSale = artifacts.require("./TestTokenSale.sol");

module.exports = function(deployer) {
  deployer.deploy(TestToken, 10000).then(function(){
  	// token price is 0.1 ether, converted in wei
  	var tokenPrice = 1e17;//100000000000000000;
  	return deployer.deploy(TestTokenSale, TestToken.address, tokenPrice, 140); // endTime here is the block number here
  });
};



