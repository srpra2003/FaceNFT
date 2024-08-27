//SPDX-License-Identifier:MIT

pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {DeployFaceNFT} from "../script/DeployFaceNFT.s.sol";
import {FaceNFT} from "../src/FaceNFT.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

contract TestFaceNFT is Test {
    DeployFaceNFT private deployNFT;
    FaceNFT private faceNFT;
    string private happyImgURI =
        "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8IS0tIENpcmNsZSBmb3IgdGhlIGZhY2UgLS0+CiAgPGNpcmNsZSBjeD0iMTAwIiBjeT0iMTAwIiByPSI4MCIgc3Ryb2tlPSJibGFjayIgc3Ryb2tlLXdpZHRoPSI0IiBmaWxsPSJ5ZWxsb3ciIC8+CiAgCiAgPCEtLSBMZWZ0IGV5ZSAtLT4KICA8Y2lyY2xlIGN4PSI3MCIgY3k9IjcwIiByPSIxMCIgc3Ryb2tlPSJibGFjayIgc3Ryb2tlLXdpZHRoPSIyIiBmaWxsPSJ3aGl0ZSIgLz4KICA8Y2lyY2xlIGN4PSI3MCIgY3k9IjcwIiByPSI1IiBmaWxsPSJibGFjayIgLz4KICAKICA8IS0tIFJpZ2h0IGV5ZSAtLT4KICA8Y2lyY2xlIGN4PSIxMzAiIGN5PSI3MCIgcj0iMTAiIHN0cm9rZT0iYmxhY2siIHN0cm9rZS13aWR0aD0iMiIgZmlsbD0id2hpdGUiIC8+CiAgPGNpcmNsZSBjeD0iMTMwIiBjeT0iNzAiIHI9IjUiIGZpbGw9ImJsYWNrIiAvPgogIAogIDwhLS0gTW91dGggLS0+CiAgPHBhdGggZD0iTSA2MCAxMjAgUSAxMDAgMTYwIDE0MCAxMjAiIHN0cm9rZT0iYmxhY2siIHN0cm9rZS13aWR0aD0iNCIgZmlsbD0idHJhbnNwYXJlbnQiIC8+Cjwvc3ZnPgo=";
    string private sadImgURI =
        "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8IS0tIENpcmNsZSBmb3IgdGhlIGZhY2UgLS0+CiAgPGNpcmNsZSBjeD0iMTAwIiBjeT0iMTAwIiByPSI4MCIgc3Ryb2tlPSJibGFjayIgc3Ryb2tlLXdpZHRoPSI0IiBmaWxsPSJ5ZWxsb3ciIC8+CiAgCiAgPCEtLSBMZWZ0IGV5ZSAtLT4KICA8Y2lyY2xlIGN4PSI3MCIgY3k9IjcwIiByPSIxMCIgc3Ryb2tlPSJibGFjayIgc3Ryb2tlLXdpZHRoPSIyIiBmaWxsPSJ3aGl0ZSIgLz4KICA8Y2lyY2xlIGN4PSI3MCIgY3k9IjcwIiByPSI1IiBmaWxsPSJibGFjayIgLz4KICAKICA8IS0tIFJpZ2h0IGV5ZSAtLT4KICA8Y2lyY2xlIGN4PSIxMzAiIGN5PSI3MCIgcj0iMTAiIHN0cm9rZT0iYmxhY2siIHN0cm9rZS13aWR0aD0iMiIgZmlsbD0id2hpdGUiIC8+CiAgPGNpcmNsZSBjeD0iMTMwIiBjeT0iNzAiIHI9IjUiIGZpbGw9ImJsYWNrIiAvPgogIAogIDwhLS0gTW91dGggLS0+CiAgPHBhdGggZD0iTSA2MCAxNDAgUSAxMDAgMTAwIDE0MCAxNDAiIHN0cm9rZT0iYmxhY2siIHN0cm9rZS13aWR0aD0iNCIgZmlsbD0idHJhbnNwYXJlbnQiIC8+Cjwvc3ZnPg==";
    address private USER = makeAddr("user");
    uint256 private constant STARTING_USER_BALANCE = 10 ether;

    function setUp() public {
        deployNFT = new DeployFaceNFT();
        faceNFT = deployNFT.deployNFT();

        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testImageURIS() public view {
        string memory reqHappyImgURI = faceNFT.getHappyImageURI();
        string memory reqSadImgURI = faceNFT.getSadImageURI();

        assertEq(keccak256(abi.encodePacked(reqHappyImgURI)), keccak256(abi.encodePacked(happyImgURI)));
        assertEq(keccak256(abi.encodePacked(reqSadImgURI)), keccak256(abi.encodePacked(sadImgURI)));
    }

    function testTokenCounterInitailizewithValueZero() public view {
        assertEq(0, faceNFT.getTotalTokens());
    }

    function testMintNFTRevertsOnInvalidSender() public {
        vm.prank(address(0));
        vm.expectRevert(abi.encodeWithSelector(FaceNFT.FaceNFT__InvalidSender.selector, address(0)));
        faceNFT.mintNFT();
    }

    function testMintNFTmintsTokenToSender() public {
        vm.prank(USER);
        uint256 tokenId = faceNFT.mintNFT();
        address tokenOwner = faceNFT.ownerOf(tokenId);
        uint256 totalTokens = faceNFT.getTotalTokens();
        FaceNFT.Face face = faceNFT.getFaceOfToken(tokenId);

        assert(tokenId == 0);
        assert(tokenOwner == USER);
        assert(totalTokens == 1);
        assert(face == FaceNFT.Face.HAPPY);
    }

    function testTokenURIRevertsOnInValidToken() public {
        vm.prank(USER);
        vm.expectRevert(abi.encodeWithSelector(FaceNFT.FaceNFT__NonexistentToken.selector, uint256(5)));

        faceNFT.tokenURI(5);
    }

    function testFlipFaceRevertsOnInValidAuthorizationOfToken() public {
        vm.prank(USER);
        uint256 tokenId = faceNFT.mintNFT();
        address fakeUser = makeAddr("fakeUser");

        vm.prank(fakeUser);
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidApprover.selector, fakeUser));
        faceNFT.flipFace(tokenId);
    }

    function testFlipFaceFlipsTheFace() public {
        vm.prank(USER);
        uint256 tokenId = faceNFT.mintNFT();

        vm.prank(USER);
        faceNFT.flipFace(tokenId);

        FaceNFT.Face face = faceNFT.getFaceOfToken(tokenId);

        assert(face == FaceNFT.Face.SAD);
    }

    function testNFTNameAndSymbolIsSet() public view {
        string memory NFTName = "FaceNFT";
        string memory NFTSymbol = "FAC";

        string memory reqiredName = faceNFT.name();
        string memory requiredSym = faceNFT.symbol();

        assertEq(keccak256(abi.encode(NFTName)), keccak256(abi.encode(reqiredName)));
        assertEq(keccak256(abi.encode(NFTSymbol)), keccak256(abi.encode(requiredSym)));
    }
}
