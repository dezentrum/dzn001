var HDWalletProvider = require("truffle-hdwallet-provider");

var infura_apikey = "qaveCKWstr1JyARcFKaY";
var mnemonic = "actress drastic dust cabbage dolphin level mixed column casual total whisper roof";




module.exports = {
    networks: {
        development: {
            host: "localhost",
            port: 7545,
            gas: 6500000,
            network_id: "5777"
        },
        ropsten: {
            provider: new HDWalletProvider(mnemonic, "https://ropsten.infura.io/" + infura_apikey),
            network_id: 3,
            gas: 4612388
        }
    },
    solc: {
        optimizer: {
            enabled: true,
            runs: 200
        }
    }
};