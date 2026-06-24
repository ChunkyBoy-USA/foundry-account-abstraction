// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import { Script } from "lib/forge-std/src/Script.sol";
import { MinimalAccount } from "src/ethereum/MinimalAccount.sol";
import { PackedUserOperation } from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import { HelperConfig } from "script/HelperConfig.s.sol";
import { IEntryPoint } from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import { MessageHashUtils } from "lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

contract SendPackedUserOps is Script {
    using MessageHashUtils for bytes32;

    function run() public {

    }

    function generateSignedUserOperation(bytes memory callData, HelperConfig.NetworkConfig memory networkConfig) public view returns(PackedUserOperation memory) {
        // 1. Generate the unsigned data
        uint256 nonce = vm.getNonce(networkConfig.account);
        PackedUserOperation memory userOps = _generateSignedUserOperation(callData, networkConfig.account, nonce);

        // 2. Get the userOp Hash
        bytes32 userOpHash = IEntryPoint(networkConfig.entryPoint).getUserOpHash(userOps);
        bytes32 digest = userOpHash.toEthSignedMessageHash();

        // 3. Sign it
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 ANVIL_DEFAULT_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        if(block.chainid == 31337) { // Anvil chain id
            (v, r, s) = vm.sign(ANVIL_DEFAULT_KEY, digest);
        } else {
            (v, r, s) = vm.sign(networkConfig.account, digest);
        }
        userOps.signature = abi.encodePacked(r, s, v); // Note the order
        return userOps;
    }


     function _generateSignedUserOperation(bytes memory callData, address sender, uint256 nonce) internal pure returns(PackedUserOperation memory) {
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
            gasFees: bytes32(uint256(maxPriporityFeePerGas) << 128 | maxPriporityFeePerGas),
            paymasterAndData: hex"",
            signature: hex""
        });
    }

}