// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21 <0.9.0;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract PiggyBox is ERC721, ERC721URIStorage, Ownable {
    /// @notice Constants
    // Magic Wallet Address - Polygon Mumbai Testnet
    address public constant MAGIC_WALLET_ADDRESS = 0x9f7C3c3721B5B082924D260C3DB4e8885a874471;
    // Magic Wallet Address - Polygon Mainnet
    // address public constant MAGIC_WALLET_ADDRESS = 0x17C5e0af7D75F8d6e3dEf32E89dBE572788F4D77;

    /// @notice Private variables
    uint256 private _nextTokenId;

    /// @notice Public variables
    string public _baseTokenURI; // Opensea Token-level metadata
    string public _contractURI; // OpenSea Contract-level metadata
    mapping(address user => uint256 balance) public mintBalance;

    /// @notice Errors
    error ZeroAddress();
    error InvalidIncreaseMintBalanceAmount();
    error NoAvailableBalanceToMint();
    error UnauthorizedMint();

    /// @notice Events
    event MintBalanceIncreased(address indexed to, uint256 amount);
    event MintedPiggyBox(address indexed to, uint256 tokenId);

    constructor(address owner)
        ERC721("PiggyBox", "MTK")
        Ownable(owner)
    {
        _nextTokenId = 1;
        _baseTokenURI = "https://bafybeifu2y57fve3qa5bivrexdm6vap4rordilhnes7ytsom5w2aehejfa.ipfs.dweb.link/";
        _contractURI = "https://bafybeifu2y57fve3qa5bivrexdm6vap4rordilhnes7ytsom5w2aehejfa.ipfs.dweb.link/";
    }

    /// @notice OpenSea URL for the storefront-level metadata for the contract.
    function contractURI() public view returns (string memory) {
        return string(abi.encodePacked(bytes(_contractURI)));
    }

    /// @notice Increase mint balance to a specific address
    /// @param to The address to increase mint balance
    /// @param amount The amount to increase mint balance
    function increaseMintBalance(address to, uint256 amount) public onlyOwner {
        // Verify that the address is not the zero address.
        if (to == address(0)) revert ZeroAddress();
        if (!(amount > 0) || amount > 100) revert InvalidIncreaseMintBalanceAmount();

        mintBalance[to] += amount;

        emit MintBalanceIncreased(to, amount);
    }

    /// @notice Increase mint balance to a batch of addresses
    /// @param to The address array to increase mint balance
    /// @param amount The amount to increase mint balance
    function batchIncreaseMintBalance(address[] memory to, uint256 amount) public onlyOwner {
        for (uint256 i = 0; i < to.length; i++) {
            address _cachedTo = to[i];
            if (_cachedTo == address(0)) revert ZeroAddress();
            if (!(amount > 0) || amount > 100) revert InvalidIncreaseMintBalanceAmount();

            mintBalance[_cachedTo] += amount;

            emit MintBalanceIncreased(_cachedTo, amount);
        }
    }

    /// @notice Magic provider mint function. Magic NFT Minting + Delivery or NFT Checkout.
    function mint(address _userWallet, uint256 _quantity) external payable {
        // Only Magic Wallet Address can use this function
        if (msg.sender != MAGIC_WALLET_ADDRESS) revert UnauthorizedMint();

        if (mintBalance[_userWallet] < _quantity) revert NoAvailableBalanceToMint();

        for (uint256 i = 0; i < _quantity; i++) {
            uint256 tokenId = _nextTokenId++;
            _safeMint(_userWallet, tokenId);
            emit MintedPiggyBox(_userWallet, tokenId);
        }

        mintBalance[_userWallet] -= _quantity;
    }

    /// @notice Mint a PiggyBox
    function safeMint() public {
        if (mintBalance[msg.sender] > 0) mintBalance[msg.sender]--;
        else revert NoAvailableBalanceToMint();

        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);

        emit MintedPiggyBox(msg.sender, tokenId);
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
