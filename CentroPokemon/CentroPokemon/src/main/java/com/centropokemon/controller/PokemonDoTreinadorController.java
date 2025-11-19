/*
 * Centro Pokémon - Controlador de Pokémon do Treinador
 * ---------------------------------------
 * @file        PokemonDoTreinadorController.java
 * @author      Gustavo Pigatto, Matheus Schvann, Alexandre Lampert, Mateus Stock, Felipe Winter
 * @version     1.1
 * @date        2025-11-19
 * @description Endpoints REST para cadastro e listagem de Pokémon de um treinador.
 */

package com.centropokemon.controller;

import com.centropokemon.model.Pokemon;
import com.centropokemon.model.Treinador;
import com.centropokemon.service.CadastroPokemonService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Controlador REST para gerenciar os Pokémon cadastrados por um treinador.
 */
@RestController
@CrossOrigin(origins = "http://localhost:8080")
@RequestMapping("/CentroPokemon/api/treinadores/{treinadorId}/pokemons")
public class PokemonDoTreinadorController {

    private final CadastroPokemonService cadastro;

    public PokemonDoTreinadorController(CadastroPokemonService cadastro) {
        this.cadastro = cadastro;
    }

    /**
     * Payload de cadastro de Pokémon do treinador.
     */
    public static class CadastroPokemonRequest {
        public Integer pokeApiId;
        public String nomePt;
        public String nomeEn;
        public String spriteUrl;
        public Integer vidaAtual;
        public Integer vidaMaxima;
    }

    /**
     * Resposta segura do Pokémon com vínculo ao treinador.
     */
    public static class PokemonResponse {
        public Integer id;
        public Integer pokeApiId;
        public String nomePt;
        public String nomeEn;
        public String spriteUrl;
        public Integer vidaAtual;
        public Integer vidaMaxima;

        public static PokemonResponse of(Pokemon p) {
            PokemonResponse r = new PokemonResponse();
            r.id = p.getId();
            r.pokeApiId = p.getPokeApiId();
            r.nomePt = p.getNomePt();
            r.nomeEn = p.getNomeEn();
            r.spriteUrl = p.getSpriteUrl();
            r.vidaAtual = p.getVidaAtual();
            r.vidaMaxima = p.getVidaMaxima();
            return r;
        }
    }

    /**
     * Endpoint: POST /CentroPokemon/api/treinadores/{treinadorId}/pokemons
     * Cadastra um Pokémon para o treinador.
     */
    @PostMapping
    public ResponseEntity<PokemonResponse> cadastrar(@PathVariable Integer treinadorId,
                                                     @RequestBody CadastroPokemonRequest req) {
        // Validação de campos obrigatórios
        if (req == null || req.nomePt == null || req.nomeEn == null || req.spriteUrl == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
        Pokemon saved;
        try {
            saved = cadastro.cadastrar(treinadorId, req.pokeApiId, req.nomePt, req.nomeEn, req.spriteUrl, req.vidaAtual, req.vidaMaxima);
        } catch (IllegalArgumentException e) {
            if (e.getMessage().contains("Treinador não encontrado")) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
            }
            return ResponseEntity.status(HttpStatus.CONFLICT).build();
        }
        return ResponseEntity.status(HttpStatus.CREATED).body(PokemonResponse.of(saved));
    }

    /**
     * Endpoint: GET /CentroPokemon/api/treinadores/{treinadorId}/pokemons
     * Lista todos os Pokémon cadastrados pelo treinador.
     */
    @GetMapping
    public ResponseEntity<List<PokemonResponse>> listar(@PathVariable Integer treinadorId) {
        List<PokemonResponse> lista = cadastro.listar(treinadorId)
                .stream().map(PokemonResponse::of).toList();
        return ResponseEntity.ok(lista);
    }

    /**
     * Endpoint: DELETE /CentroPokemon/api/treinadores/{treinadorId}/pokemons/{pokemonId}
     * Remove um Pokémon do treinador.
     */
    @DeleteMapping("/{pokemonId}")
    public ResponseEntity<Void> remover(@PathVariable Integer treinadorId, @PathVariable Integer pokemonId) {
        boolean ok = cadastro.remover(treinadorId, pokemonId);
        return ok ? ResponseEntity.noContent().build() : ResponseEntity.status(HttpStatus.NOT_FOUND).build();
    }
}