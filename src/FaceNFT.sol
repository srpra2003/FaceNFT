// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

//SPDX-License-Identifier:MIT

pragma solidity ^0.8.26;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract FaceNFT is ERC721 {
    error FaceNFT__InvalidTokenId();
    error FaceNFT__InvalidSender(address);
    error FaceNFT__NonexistentToken(uint256);

    enum Face {
        HAPPY,
        SAD
    }

    uint256 private s_tokenCounter;
    string private s_happyImgURI;
    string private s_sadImgURI;
    mapping(uint256 tokenId => Face) s_Faces;

    modifier ValidToken(uint256 tokenId) {
        if (tokenId > s_tokenCounter) {
            revert FaceNFT__NonexistentToken(tokenId);
        }
        _;
    }

    constructor(string memory happyImgURI, string memory sadImgURI) ERC721("FaceNFT", "FAC") {
        s_tokenCounter = 0;
        s_happyImgURI = happyImgURI;
        s_sadImgURI = sadImgURI;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function mintNFT() public returns (uint256 tokenId) {
        if (msg.sender == address(0)) {
            revert FaceNFT__InvalidSender(msg.sender);
        }
        _safeMint(msg.sender, s_tokenCounter);
        tokenId = s_tokenCounter;
        s_Faces[tokenId] = Face.HAPPY;
        s_tokenCounter++;
        return tokenId;
    }

    function tokenURI(uint256 tokenId) public view override ValidToken(tokenId) returns (string memory) {
        string memory imgURI = s_happyImgURI;
        if (s_Faces[tokenId] == Face.SAD) {
            imgURI = s_sadImgURI;
        }

        string memory jsonPart = Base64.encode(
            abi.encodePacked(
                '{"name":"',
                name(),
                '", "description":"This is the FACENFT which can change its face from happy to sad ad vice versa',
                '", "imgage":"',
                imgURI,
                '"}'
            )
        );

        return string(abi.encodePacked(_baseURI(), jsonPart));
    }

    function flipFace(uint256 tokenId) public ValidToken(tokenId) {
        if ((msg.sender != ownerOf(tokenId)) && (msg.sender != getApproved(tokenId))) {
            revert ERC721InvalidApprover(msg.sender);
        }

        if (s_Faces[tokenId] == Face.HAPPY) {
            s_Faces[tokenId] = Face.SAD;
        } else {
            s_Faces[tokenId] = Face.HAPPY;
        }
    }

    function getHappyImageURI() public view returns (string memory) {
        return s_happyImgURI;
    }

    function getSadImageURI() public view returns (string memory) {
        return s_sadImgURI;
    }

    function getTotalTokens() public view returns (uint256) {
        return s_tokenCounter;
    }

    function getFaceOfToken(uint256 tokenId) public view ValidToken(tokenId) returns (Face) {
        return s_Faces[tokenId];
    }
}
