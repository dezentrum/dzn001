const evmThrewRevertError = (err) => {
    if (err.toString().includes('Error: VM Exception while processing transaction: revert')) {
        return true
    }
    if (err.toString().includes('invalid opcode')) {
        return true
    }
    return false
}
module.exports = evmThrewRevertError;