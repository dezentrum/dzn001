var Utils = {
    testMint(contract, accounts, amount) {
        return contract.mint(accounts[0], amount)
            .then(function() {
                return contract.finishMinting();
            }).catch((err) => {
                throw new Error(err)
            });
    }
}
module.exports = Utils