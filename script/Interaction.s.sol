//SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FaceNFT} from "../src/FaceNFT.sol";

contract MintNFT is Script {

    function mintNft(address faceNftAdd) public returns(uint256 tokenId){
        vm.startBroadcast();
        tokenId = FaceNFT(faceNftAdd).mintNFT();
        vm.stopBroadcast();
        return tokenId;
    }
    
    function run() external returns(uint256){
        address mostRecentDeploy = DevOpsTools.get_most_recent_deployment("FaceNFT",block.chainid);
        return mintNft(mostRecentDeploy);
    }
}