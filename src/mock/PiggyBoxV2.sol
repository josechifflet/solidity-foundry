// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21 <0.9.0;

import { console } from "forge-std/Test.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import { ERC721URIStorageUpgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract PiggyBoxV2 is Initializable, ERC721Upgradeable, ERC721URIStorageUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    /// @notice Private variables
    uint256 private _nextTokenId;

    /// @notice Public variables
    string public _baseTokenURI; // Opensea Token-level metadata
    string public _contractURI; // OpenSea Contract-level metadata

    /// @notice Events
    event MintedPiggyBox(address indexed to, uint256 tokenId);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initialize the contract
    function initialize(address initialOwner, string memory baseTokenURI, string memory baseContractURI) public initializer {
        __ERC721_init("PiggyBox", "PBX");
        __ERC721URIStorage_init();
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();

        _baseTokenURI = baseTokenURI;
        _contractURI = baseContractURI;
    }

    /// @notice OpenSea URL for the storefront-level metadata for the contract.
    function contractURI() public view returns (string memory) {
        return string(abi.encodePacked(bytes(_contractURI)));
    }

    /// @notice Mint a PiggyBox
    function mint(address to) public {
        uint256 tokenId = _nextTokenId++;

        _mint(to, tokenId);

        emit MintedPiggyBox(to, tokenId);
    }

    /// @notice Update the baseTokenURI
    function setBaseTokenURI(string memory baseTokenURI) public onlyOwner {
        _baseTokenURI = baseTokenURI;
    }

    /// @notice Update the contractURI
    function setContractURI(string memory baseContractURI) public onlyOwner {
        _contractURI = baseContractURI;
    }

    /// @notice Only allow the owner to update the implementation contract
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner { }

    /// @notice [Test only] override the version function
    function version() external pure returns (uint256) {
        return 2;
    }

    /// @notice [Test only] Add a post-upgrade initialization function for test upgrade purposes
    function postUpgradeInitialization() public onlyOwner {
        console.log("Post-upgrade initialization");
        _nextTokenId = 1000;
    }

    /// @notice [Test only] Add a function to test the nextTokenId for test upgrade purposes
    function getNextTokenId() public view returns (uint256) {
        return _nextTokenId;
    }

    /*/////////////////////////////////////////////////////////////////
      The following functions are overrides required by Solidity.
    /////////////////////////////////////////////////////////////////*/

    function tokenURI(uint256 tokenId) public view override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory) {
        return string(abi.encodePacked(bytes(_baseTokenURI), Strings.toString(tokenId), ".json"));
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
