
const HDWalletProvider = require('truffle-hdwallet-provider');
require('dotenv').config();

function getProvider() {
  return () => new HDWalletProvider(process.env.MNEMONIC, 'https://rpc.gnosischain.com/');
}

module.exports = {
  networks: {
    development: {
      protocol: 'http',
      host: 'localhost',
      port: 8545,
      gas: 5000000,
      gasPrice: 5e9,
      networkId: '*',
    },
    xdai: {
      provider: getProvider(),
      gasPrice: 1e9,
      networkId: 100,
    },
  },
};
