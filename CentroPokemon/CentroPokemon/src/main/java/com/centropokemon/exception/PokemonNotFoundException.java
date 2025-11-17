/*
 * Centro Pokémon - Exceção Pokémon não encontrado
 * ---------------------------------------
 * @file        PokemonNotFoundException.java
 * @author      Gustavo Pigatto, Matheus Schvann, Alexandre Lampert, Mateus Stock, Felipe Winter
 * @version     1.0
 * @date        2025-11-16
 * @description Exceção para casos em que um Pokémon não é encontrado na Pokédex.
 */

package com.centropokemon.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;
/**
 * Exceção de domínio lançada quando um Pokémon não é encontrado.
 */
@ResponseStatus(HttpStatus.NOT_FOUND)
public class PokemonNotFoundException extends RuntimeException {
    public PokemonNotFoundException(String message) {
        super(message);
    }
}