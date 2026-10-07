// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Pase VIP Café Lima (PVIP)
/// @notice Token ERC721: cada pase es único, numerado y tiene un solo titular.
///         La cafetería emite los pases y los valida una sola vez en la puerta.
/// @dev Basado en OpenZeppelin v5. Solo el dueño (la cafetería) emite y valida.
contract PaseVIP is ERC721, ERC721URIStorage, Ownable {
    /// @dev Siguiente número de pase a emitir (empieza en 0).
    uint256 private _nextTokenId;

    /// @notice Cantidad máxima de pases que existirán.
    uint256 public constant MAX_PASES = 100;

    /// @notice Indica si un pase ya fue utilizado en la puerta.
    mapping(uint256 => bool) public usado;

    event PaseEmitido(address indexed cliente, uint256 indexed tokenId, string uri);
    event PaseValidado(uint256 indexed tokenId, address indexed titular);

    constructor(address initialOwner)
        ERC721("Pase VIP Cafe Lima", "PVIP")
        Ownable(initialOwner)
    {}

    /// @notice La cafetería emite un pase VIP nuevo para un cliente.
    /// @param cliente Wallet que recibirá el pase.
    /// @param uri Enlace a los metadatos del pase (nombre, imagen, descripción).
    /// @return tokenId Número del pase emitido.
    function emitirPase(address cliente, string calldata uri)
        external
        onlyOwner
        returns (uint256 tokenId)
    {
        require(_nextTokenId < MAX_PASES, "No quedan pases");

        tokenId = _nextTokenId++;
        _safeMint(cliente, tokenId);
        _setTokenURI(tokenId, uri);

        emit PaseEmitido(cliente, tokenId, uri);
    }

    /// @notice La cafetería valida un pase en la puerta. Solo funciona una vez por pase.
    /// @param tokenId Número del pase a validar.
    function validarPase(uint256 tokenId) external onlyOwner {
        address titular = ownerOf(tokenId); // revierte si el pase no existe
        require(!usado[tokenId], "Pase ya utilizado");

        usado[tokenId] = true;
        emit PaseValidado(tokenId, titular);
    }

    /// @notice Cuántos pases se han emitido hasta ahora.
    function totalEmitidos() external view returns (uint256) {
        return _nextTokenId;
    }

    // --- Obligatorio en OpenZeppelin v5 cuando se combinan ERC721 y ERC721URIStorage ---

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
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
