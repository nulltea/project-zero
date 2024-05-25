// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./SP1Verifier.sol";

/**
 * @title ProofOfExploitMarketplace
 * @dev A marketplace for white-hat hackers to sell proofs of exploits to 
 * smart contract stakeholders. 
 */
contract ProofOfExploitMarketplace is ERC721 {

    struct Exploit {
        address creator;
        string description;
        uint256 keyHash;
        uint256 price;
        bool redeemed;
        Buyer buyer;
    }

    struct Buyer {
        uint256[2] publicKey;
        bool hasPurchased;
    }

    /// map of all exploits
    mapping(uint256 => Exploit) public exploits;
    /// map of token holders (buyers)
    mapping(uint256 => address) public tokenOwners;
    /// map of buyer information 
    mapping(address => Buyer) public buyers;

    /// keep track of our exploits to map them to tokens
    uint256 public exploitCount;
    
    event ExploitPosted(uint256 indexed id, address indexed creator, uint256 price);
    event TokenPurchased(uint256 indexed id, address indexed buyer);
    event ExploitRedeemed(uint256 indexed id, address indexed buyer);

    constructor()
        ERC721("ProofOfExploitToken", "PET")
    {}

    /**
     * @notice Posts a new exploit to the marketplace.
     * @param description A description of the exploit.
     * @param price The price for the exploit.
     * @param keyHash The hash of the key of the encryption of the proof of the exploit.
     * @return The ID of the newly created exploit.
     */
    function postExploit(
        string calldata description,
        uint256 price,
        uint256 keyHash
    ) external returns (uint256) {
        exploitCount++;
        uint256 id = exploitCount;

        exploits[id] = Exploit
        ({
            creator: msg.sender,
            description: description,
            price: price,
            redeemed: false,
            keyHash: keyHash,
            buyer: Buyer([uint256(0), uint256(0)], false)
        });

        emit ExploitPosted(id, msg.sender, price);
        return id;
    }

    /**
     * @notice Purchases a token for a specific exploit.
     * @param exploitId The ID of the exploit to purchase.
     * @param publicKey The public key of the buyer.
     */
    function purchaseToken(uint256 exploitId, uint256[2] calldata publicKey) external payable {
        Exploit storage exploit = exploits[exploitId];
        require(msg.value >= exploit.price, "Insufficient funds");

        buyers[msg.sender] = Buyer({
            publicKey: publicKey,
            hasPurchased: true
        });

        tokenOwners[exploitId] = msg.sender;
        _mint(msg.sender, exploitId);

        emit TokenPurchased(exploitId, msg.sender);
    }

    /**
     * @notice Redeems a exploit by providing the encrypted key and preimage.
     * @param tokenId The ID of the token.
     * @param encryptedKey The encrypted key.
     * @param preimage The preimage of the key hash.
     */
    function redeemexploit(uint256 tokenId, uint256 encryptedKey, uint256 preimage) external {
        // make sure the exploit exists:
        require(tokenId > 0 && tokenId <= exploitCount, "Exploit does not exist");
        Exploit storage exploit = exploits[tokenId];
        require(exploit.creator == msg.sender, "Only the creator can redeem");
        require(!exploit.redeemed, "Exploit already redeemed");

        //require(
        //    Verifier.verifyEncryptionProof(a, b, c, input),
        //    'DataMarketplaceCore/proof-invalid'
        //);

        exploit.redeemed = true;
        exploit.keyHash = encryptedKey;

        address buyer = tokenOwners[tokenId];
        require(buyers[buyer].hasPurchased, "No buyer for this token");

        payable(exploit.creator).transfer(exploit.price);

        emit ExploitRedeemed(tokenId, buyer);
    }

    /**
     * @notice Allows a token holder to retrieve the encrypted key for the exploit.
     * @param tokenId The ID of the token.
     * @return The encrypted key.
     */
    function getexploitKey(uint256 tokenId) external view returns (uint256) {
        require(ownerOf(tokenId) == msg.sender, "Only the owner can get the key");

        Exploit storage exploit = exploits[tokenId];
        require(exploit.redeemed, "Exploit not redeemed yet");

        return exploit.keyHash;
    }
}