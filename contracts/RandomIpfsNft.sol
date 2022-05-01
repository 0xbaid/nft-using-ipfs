// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract RandomIpfsNft is ERC721URIStorage, VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface immutable i_vrfCoordinator; //immutable because we set it one time then never again, and are gas inexpensive, i for immutable var
    bytes32 public immutable i_gasLane; //how fast to get random, price per gas
    uint64 public immutable i_subscriptionId;
    uint32 public immutable i_callbackGasLimit; //uuper limit of gas for callback; max gas amount

    uint16 public constant REQUEST_CONFIRMATION = 3; //how blocks to be added in order to complete
    uint32 public constant NUM_WORDS = 1; //no, of random per function call
    uint256 public constant MAX_CHANCE_VALUE = 100;

    mapping(uint256 => address) public s_requestIdToSender;

    uint256 public s_tokenCounter;

    string[3] public s_dogTokenUris;

    constructor(
        address vrfCoordinatorV2,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        string[3] memory dogTokenUris
    ) ERC721("IPFS NFT", "IN") VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2); // interface + address = contract, i_vrfCoordinator is contract
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_tokenCounter = 0;
        s_dogTokenUris = dogTokenUris;
    }

    function requestDoggie() public returns (uint256 requestId) {
        requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATION,
            i_callbackGasLimit,
            NUM_WORDS
        );
        s_requestIdToSender[requestId] = msg.sender;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        address dogOwner = s_requestIdToSender[requestId];
        uint256 newTokenId = s_tokenCounter;
        s_tokenCounter = s_tokenCounter + 1;
        uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE;
        uint256 breed = getBreedFromModdedRng(moddedRng);
        _safeMint(dogOwner, newTokenId);
        //set tokenURI
        _setTokenURI(newTokenId, s_dogTokenUris[breed]);
    }

    function getChanceArray() public pure returns (uint256[3] memory) {
        //0-9 BERNARD
        //10-29 PUG
        //30-99 SHIBA
        return [10, 30, MAX_CHANCE_VALUE];
    }

    function getBreedFromModdedRng(uint256 moddedRng)
        public
        pure
        returns (uint256)
    {
        uint256 cummulativeSum = 0;
        uint256[3] memory chanceArray = getChanceArray();
        for (uint256 i = 0; i < chanceArray.length; i++) {
            if (
                moddedRng >= cummulativeSum &&
                moddedRng < cummulativeSum + chanceArray[i]
            ) {
                return i;
            }
            cummulativeSum = cummulativeSum + chanceArray[i];
        }
    }
}
