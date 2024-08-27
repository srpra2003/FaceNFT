//SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {FaceNFT} from "../src/FaceNFT.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract DeployFaceNFT is Script {
    function deployNFT() public returns (FaceNFT) {
        string memory happyImgURI = getImageURIFromSVGFile(vm.readFile("./img/happy.svg"));
        string memory sadImgURI = getImageURIFromSVGFile(vm.readFile("./img/sad.svg"));
        vm.startBroadcast();
        FaceNFT faceNFT = new FaceNFT(happyImgURI, sadImgURI);
        vm.stopBroadcast();

        return faceNFT;
    }

    function getImageURIFromSVGFile(string memory svgImage) public pure returns (string memory) {
        string memory baseImageURI = "data:image/svg+xml;base64,";

        return string(abi.encodePacked(baseImageURI, Base64.encode(abi.encodePacked(svgImage))));
    }

    function run() external returns (FaceNFT) {
        return deployNFT();
    }
}
