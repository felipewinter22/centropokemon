/*
 * Centro Pokémon - Controlador da Pokédex
 * ---------------------------------------
 * @file        PokedexController.java
 * @author      Gustavo Pigatto, Matheus Schvann, Alexandre Lampert, Mateus Stock, Felipe Winter
 * @version     1.2
 * @date        2025-11-18
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
@RequestMapping({"/CentroPokemon/api/pokemons", "/api/pokemons"})
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
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(pokemon);
    }

    @GetMapping("/random")
    public ResponseEntity<Pokemon> aleatorio() {
        Pokemon pokemon = service.buscarPokemonAleatorio();
        if (pokemon == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(pokemon);
    }

    @GetMapping("/type/{type}/random")
    public ResponseEntity<Pokemon> aleatorioPorTipo(@PathVariable String type) {
        Pokemon pokemon = service.buscarPokemonAleatorioPorTipo(type);
        if (pokemon == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(pokemon);
    }

    @GetMapping("/id/{id}")
    public ResponseEntity<Pokemon> buscarPorId(@PathVariable Integer id) {
        Pokemon pokemon = service.buscarPokemonPorId(id);
        if (pokemon == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(pokemon);
    }
}
