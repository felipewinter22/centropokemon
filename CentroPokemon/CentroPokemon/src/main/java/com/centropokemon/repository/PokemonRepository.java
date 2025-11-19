/*
 * Centro Pokémon - Repositório de Pokémon
 * ---------------------------------------
 * @file        PokemonRepository.java
 * @author      Gustavo Pigatto, Matheus Schvann, Alexandre Lampert, Mateus Stock, Felipe Winter
 * @version     1.1
 * @date        2025-11-18
 * @description Interface de repositório JPA para operações de persistência de Pokémon.
 */

package com.centropokemon.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.centropokemon.model.Pokemon;

@Repository
public interface PokemonRepository extends JpaRepository<Pokemon, Integer> {

    /**
     * Busca um Pokémon pelo nome em inglês, ignorando maiúsculas/minúsculas.
     *
     * @param nomeEn nome em inglês
     * @return Optional com o Pokémon, se encontrado
     */
    Optional<Pokemon> findByNomeEnIgnoreCase(String nomeEn);

    /**
     * Busca um Pokémon pelo nome em português, ignorando maiúsculas/minúsculas.
     *
     * @param nomePt nome em português
     * @return Optional com o Pokémon, se encontrado
     */
    Optional<Pokemon> findByNomePtIgnoreCase(String nomePt);

    /**
     * Busca um Pokémon pelo identificador externo da PokeAPI.
     *
     * @param pokeApiId identificador da PokeAPI
     * @return Optional com o Pokémon, se encontrado
     */
    Optional<Pokemon> findByPokeApiId(Integer pokeApiId);

    /**
     * Lista todos os Pokémon cadastrados por um treinador.
     * @param treinadorId identificador do treinador
     * @return lista de Pokémon pertencentes ao treinador
     */
    List<Pokemon> findByTreinadorId(Integer treinadorId);

    /**
     * Busca um Pokémon específico de um treinador pelo ID da PokeAPI.
     * @param treinadorId identificador do treinador
     * @param pokeApiId identificador externo da PokeAPI
     * @return Optional com o Pokémon, se encontrado
     */
    Optional<Pokemon> findByTreinadorIdAndPokeApiId(Integer treinadorId, Integer pokeApiId);

    /**
     * Conta quantos Pokémon um treinador possui cadastrados.
     * @param treinadorId identificador do treinador
     * @return quantidade de Pokémon
     */
    long countByTreinadorId(Integer treinadorId);

    /**
     * Alias em português para findByNomeEnIgnoreCase.
     * @param nomeEn nome do Pokémon em inglês
     * @return Optional com o Pokémon, se encontrado
     */
    default Optional<Pokemon> buscarPorNomeEnIgnoreCase(String nomeEn) {
        return findByNomeEnIgnoreCase(nomeEn);
    }

    /**
     * Alias em português para findByNomePtIgnoreCase.
     * @param nomePt nome do Pokémon em português
     * @return Optional com o Pokémon, se encontrado
     */
    default Optional<Pokemon> buscarPorNomePtIgnoreCase(String nomePt) {
        return findByNomePtIgnoreCase(nomePt);
    }

    /**
     * Alias em português para findByPokeApiId.
     * @param pokeApiId identificador na PokeAPI
     * @return Optional com o Pokémon, se encontrado
     */
    default Optional<Pokemon> buscarPorPokeApiId(Integer pokeApiId) {
        return findByPokeApiId(pokeApiId);
    }

    /**
     * Alias em português para {@code findByTreinadorId}.
     * @param treinadorId identificador do treinador
     * @return lista de Pokémon
     */
    default List<Pokemon> buscarPorTreinadorId(Integer treinadorId) {
        return findByTreinadorId(treinadorId);
    }

    /**
     * Alias em português para {@code findByTreinadorIdAndPokeApiId}.
     * @param treinadorId identificador do treinador
     * @param pokeApiId identificador externo da PokeAPI
     * @return Optional com o Pokémon
     */
    default Optional<Pokemon> buscarPorTreinadorIdEPokeApiId(Integer treinadorId, Integer pokeApiId) {
        return findByTreinadorIdAndPokeApiId(treinadorId, pokeApiId);
    }

    /**
     * Alias em português para {@code countByTreinadorId}.
     * @param treinadorId identificador do treinador
     * @return quantidade de Pokémon
     */
    default long contarPorTreinadorId(Integer treinadorId) {
        return countByTreinadorId(treinadorId);
    }
}