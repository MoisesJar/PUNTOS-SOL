// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Puntos Café Lima (PCL)
/// @notice Token ERC20 de fidelidad para una cafetería: el cliente gana puntos
///         por cada compra y los canjea (se queman) por recompensas.
/// @dev Basado en OpenZeppelin v5. Solo el dueño (la cafetería) puede emitir puntos.
contract PuntosCafe is ERC20, ERC20Burnable, Ownable {
    /// @notice Puntos que se otorgan por cada 1 sol gastado.
    uint256 public puntosPorSol;

    /// @notice Tope máximo de puntos en circulación (decimals = 0).
    uint256 public constant MAX_SUPPLY = 1_000_000;

    event CompraRegistrada(address indexed cliente, uint256 montoSoles, uint256 puntos);
    event PuntosCanjeados(address indexed cliente, uint256 puntos, string recompensa);
    event PuntosPorSolActualizado(uint256 anterior, uint256 nuevo);

    constructor(address initialOwner)
        ERC20("Puntos Cafe Lima", "PCL")
        Ownable(initialOwner)
    {
        puntosPorSol = 1;
    }

    /// @dev Los puntos son enteros (no existen "0.5 puntos").
    function decimals() public pure override returns (uint8) {
        return 0;
    }

    /// @notice La cafetería registra una compra y emite puntos al cliente.
    /// @param cliente Wallet del cliente.
    /// @param montoSoles Monto de la compra en soles (entero).
    function registrarCompra(address cliente, uint256 montoSoles) external onlyOwner {
        require(cliente != address(0), "Cliente invalido");
        require(montoSoles > 0, "Monto debe ser mayor a 0");

        uint256 puntos = montoSoles * puntosPorSol;
        require(totalSupply() + puntos <= MAX_SUPPLY, "Supply maximo alcanzado");

        _mint(cliente, puntos);
        emit CompraRegistrada(cliente, montoSoles, puntos);
    }

    /// @notice El cliente canjea sus puntos: se queman y queda registro del canje.
    /// @param puntos Cantidad de puntos a canjear.
    /// @param recompensa Descripción de la recompensa (ej. "Cafe americano gratis").
    function canjear(uint256 puntos, string calldata recompensa) external {
        require(puntos > 0, "Puntos debe ser mayor a 0");
        _burn(msg.sender, puntos); // revierte solo si no tiene saldo suficiente
        emit PuntosCanjeados(msg.sender, puntos, recompensa);
    }

    /// @notice La cafetería ajusta cuántos puntos da por sol (promociones).
    function setPuntosPorSol(uint256 nuevo) external onlyOwner {
        require(nuevo > 0, "Debe ser mayor a 0");
        emit PuntosPorSolActualizado(puntosPorSol, nuevo);
        puntosPorSol = nuevo;
    }
}
