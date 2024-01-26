// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21 <0.9.0;

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

    /// @notice Exceptions
    error InvalidAddress();
    error Unauthorized();

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
        if (address(to) == address(0)) revert InvalidAddress();

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

    /// @notice Return the current version of the contract
    function version() external pure returns (uint256) {
        return 2;
    }

    /// @notice [Upgrade] Add the burn function
    function burn(uint256 tokenId) public {
        address nftOwner = ownerOf(tokenId);
        if (msg.sender != nftOwner) revert Unauthorized();
        _burn(tokenId);
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
