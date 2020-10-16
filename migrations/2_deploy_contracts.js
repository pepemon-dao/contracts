// var PepemonToken = artifacts.require("PepemonToken");
var PepedexToken = artifacts.require("PepedexToken");

// const thousandEthInWei = web3.utils.toWei('1000', 'ether')

module.exports = function(deployer) {
  // PPBLZ already deployed with generator contract
  // await deployer.deploy(PepemonToken);
  deployer.deploy(PepedexToken);
};
