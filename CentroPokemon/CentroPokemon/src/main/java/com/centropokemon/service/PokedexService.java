/*
 * Centro Pokémon - Serviço da Pokédex
 * ---------------------------------------
 * @file        PokedexService.java
 * @author      Gustavo Pigatto, Matheus Schvann, Alexandre Lampert, Mateus Stock, Felipe Winter
 * @version     1.0
 * @date        2025-11-16
 * @description Serviço de aplicação para operações da Pokédex.
 */

package com.centropokemon.service;

import org.springframework.stereotype.Service;
import com.centropokemon.model.Pokemon;
import com.centropokemon.repository.PokemonRepository;
import java.util.Optional;

/**
 * Serviço responsável por orquestrar a busca de Pokémons.
 * No estágio atual, consulta a PokeAPI via `DataInicializacao`.
 */
@Service
public class PokedexService {

    private final DataInicializacao dataInicializacao;
    private final PokemonRepository pokemonRepository;

    /**
     * Construtor com injeção do serviço de dados da PokeAPI.
     * @param dataInicializacao serviço de carregamento da PokeAPI
     */
    public PokedexService(DataInicializacao dataInicializacao, PokemonRepository pokemonRepository) {
        this.dataInicializacao = dataInicializacao;
        this.pokemonRepository = pokemonRepository;
    }

    /**
     * Busca um Pokémon pelo nome (inglês) usando a PokeAPI.
     * @param nome nome do Pokémon
     * @return entidade `Pokemon` ou null se não encontrado
     */
    public Pokemon buscarPokemonPorNome(String nome) {
        try {
            Optional<Pokemon> porEn = pokemonRepository.findByNomeEnIgnoreCase(nome);
            if (porEn.isPresent()) {
                return porEn.get();
            }
            Optional<Pokemon> porPt = pokemonRepository.findByNomePtIgnoreCase(nome);
            if (porPt.isPresent()) {
                return porPt.get();
            }
        } catch (Exception ignored) {}
        return dataInicializacao.montarPokemon(nome);
    }

    public Pokemon buscarPokemonAleatorio() {
        return dataInicializacao.montarPokemonAleatorio();
    }

    public Pokemon buscarPokemonAleatorioPorTipo(String type) {
        return dataInicializacao.montarPokemonAleatorioPorTipo(type);
    }

    public Pokemon buscarPokemonPorId(Integer id) {
        try {
            Optional<Pokemon> porRepo = pokemonRepository.findByPokeApiId(id);
            if (porRepo.isPresent()) {
                return porRepo.get();
            }
        } catch (Exception ignored) {}
        return dataInicializacao.montarPokemon(String.valueOf(id));
    }
}
