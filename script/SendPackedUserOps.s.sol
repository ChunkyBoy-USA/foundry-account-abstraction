// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import { Script } from "lib/forge-std/src/Script.sol";
import { MinimalAccount } from "src/ethereum/MinimalAccount.sol";
import { PackedUserOperation } from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";

contract SendPackedUserOps is Script {

    function run() public {

    }

    function generatedSignedUserOperation(bytes memory callData, address sender) public returns(PackedUserOperation memory) {
        // 1. Generate the unsigned data
        uint256 nonce = vm.getNonce(sender);
        PackedUserOperation memory unsignedUserOps = _generatedSignedUserOperation(callData, sender, nonce);

        // 2. Sign it, and return it
        return unsignedUserOps;
    }


     function _generatedSignedUserOperation(bytes memory callData, address sender, uint256 nonce) internal pure returns(PackedUserOperation memory) {
        uint128 verificationGasLimit = 16777216;
        uint128 callGasLimit = verificationGasLimit;
        uint128 maxPriporityFeePerGas = 256;
        uint128 maxFeePerGas = maxPriporityFeePerGas;
        return PackedUserOperation({
            sender: sender,
            nonce: nonce,
            initCode: hex"",
            callData: callData,
            accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | verificationGasLimit),
            preVerificationGas: verificationGasLimit,
            gasFee: bytes32(uint256(maxPriporityFeePerGas) << 128 | maxPriporityFeePerGas),
            paymasterAndData: hex"",
            signature: hex""
        });
    }

}