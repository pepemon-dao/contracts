// var PepemonToken = artifacts.require("PepemonToken");
// var PepedexToken = artifacts.require("PepedexToken");
// var PepemonFactory = artifacts.require("PepemonFactory");
var PepemonStore = artifacts.require("PepemonStore");

// const thousandEthInWei = web3.utils.toWei('1000', 'ether')
// RINKEBY
// PepemonToken: 0xA446F19DdfB9F4bdc1AbD36a4bb322D422c1bB4A
// PepedexToken: 0x866510264B9e950A7Fd2C0F12f6cd63891AAB436
// UniV2: 0x485b5e17f89d55606c1a9714a8eca671251b50e6
// PepemonFactory: 0xDbbE98e0286DE6EB5a559c75392742B114642229
// PepemonStore: 0xDc9bB51e9b5E1e07dCC299DF78ea6b56A7923eeB


module.exports = async function(deployer, network, addresses) {
  console.log({network, addresses});
  // Pragma 0.6.6
  // PPBLZ already deployed with generator contract
  // await deployer.deploy(PepemonToken);
  // await deployer.deploy(PepedexToken);

  // OpenSea proxy -> rinkeby or main
  // let proxyRegistryAddress = "";
  // if (network === 'rinkeby') {
  //   proxyRegistryAddress = "0xf57b2c51ded3a29e6891aba85459d600256cf317";
  // } else {
  //   proxyRegistryAddress = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
  // }

  // Pragma 0.5.17
  // deployer.deploy(PepemonFactory, proxyRegistryAddress);
  deployer.deploy(PepemonStore, "0xDbbE98e0286DE6EB5a559c75392742B114642229", "0x866510264B9e950A7Fd2C0F12f6cd63891AAB436");
};
