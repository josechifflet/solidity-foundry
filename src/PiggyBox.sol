// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21 <0.9.0;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract PiggyBox is ERC721, ERC721URIStorage {
    /// @notice Private variables
    uint256 private _tokenId;

    /// @notice Public variables
    string public _baseTokenURI; // Opensea Token-level metadata
    string public _contractURI; // OpenSea Contract-level metadata

    /// @notice Events
    event MintedPiggyBox(address indexed to, uint256 tokenId);

    constructor()
        ERC721("PiggyBox", "MTK")
    {
        _baseTokenURI = "https://bafybeifu2y57fve3qa5bivrexdm6vap4rordilhnes7ytsom5w2aehejfa.ipfs.dweb.link/";
        _contractURI = "https://bafybeifu2y57fve3qa5bivrexdm6vap4rordilhnes7ytsom5w2aehejfa.ipfs.dweb.link/";
    }

    /// @notice OpenSea URL for the storefront-level metadata for the contract.
    function contractURI() public view returns (string memory) {
        return string(abi.encodePacked(bytes(_contractURI)));
    }

    /// @notice Mint a PiggyBox
    function mint(address to) public {
        uint256 tokenId = ++_tokenId;

        _mint(to, tokenId);

        emit MintedPiggyBox(to, tokenId);
    }

    /*/////////////////////////////////////////////////////////////////
        The following functions are overrides required by Solidity.
    /////////////////////////////////////////////////////////////////*/
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return string(abi.encodePacked(bytes(_baseTokenURI), Strings.toString(tokenId), ".json"));
    }
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
