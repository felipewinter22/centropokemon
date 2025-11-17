/*
 * Centro Pokémon - Controlador da Pokédex
 * ---------------------------------------
 * @file        PokedexController.java
 * @author      Gustavo Pigatto, Matheus Schvann, Alexandre Lampert, Mateus Stock, Felipe Winter
 * @version     1.1
 * @date        2025-11-17
 * @description Controlador responsável pelos endpoints da Pokédex via API (Não implementado ainda).
 */

package com.centropokemon.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import com.centropokemon.service.PokedexService;
import com.centropokemon.exception.PokemonNotFoundException;
import com.centropokemon.model.Pokemon;

/**
 * Controlador REST da Pokédex.
 * Exponde endpoints para consulta de Pokémon via API.
 */
@RestController
@CrossOrigin(origins = "http://localhost:8080")
@RequestMapping("/api/pokemons")
public class PokedexController {

    private final PokedexService service;

    public PokedexController(PokedexService service) {
        this.service = service;
    }

    /**
     * Busca um Pokémon pelo nome (inglês) e retorna a entidade.
     *
     * @param nome nome do Pokémon (inglês)
     * @return resposta HTTP com o Pokémon encontrado
     * @throws PokemonNotFoundException quando não é encontrado
     */
    @GetMapping("/{nome}")
    public ResponseEntity<Pokemon> buscarPokemon(@PathVariable String nome) {
        Pokemon pokemon = service.buscarPokemonPorNome(nome);
        if (pokemon == null) {
            throw new PokemonNotFoundException("Pokémon não encontrado: " + nome);
        }
        return ResponseEntity.ok(pokemon);
    }
}