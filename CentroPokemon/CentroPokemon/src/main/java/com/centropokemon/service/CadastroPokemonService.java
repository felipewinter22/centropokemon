/*
 * Centro Pokémon - Serviço de Cadastro de Pokémon do Treinador
 * ---------------------------------------
 * @file        CadastroPokemonService.java
 * @author      Gustavo Pigatto, Matheus Schvann, Alexandre Lampert, Mateus Stock, Felipe Winter
 * @version     1.1
 * @date        2025-11-19
 * @description Regras de domínio para cadastrar, listar e remover Pokémon
 *              associados a um treinador.
 */

package com.centropokemon.service;

import com.centropokemon.model.Pokemon;
import com.centropokemon.model.Treinador;
import com.centropokemon.repository.PokemonRepository;
import com.centropokemon.repository.TreinadorRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

/**
 * Serviço de regras para cadastro de Pokémon do treinador.
 */
@Service
public class CadastroPokemonService {

    private final PokemonRepository pokemons;
    private final TreinadorRepository treinadores;

    /**
     * Construtor com repositórios necessários.
     */
    public CadastroPokemonService(PokemonRepository pokemons, TreinadorRepository treinadores) {
        this.pokemons = pokemons;
        this.treinadores = treinadores;
    }

    /**
     * Cadastra um Pokémon para o treinador com validações básicas.
     * @param treinadorId id do treinador
     * @param pokeApiId id externo (opcional)
     * @param nomePt nome em português
     * @param nomeEn nome em inglês
     * @param spriteUrl url do sprite
     * @param vidaAtual vida atual (default 100)
     * @param vidaMaxima vida máxima (default 100)
     * @return Pokémon persistido
     * @throws IllegalArgumentException quando treinador não existe ou duplicado por pokeApiId
     */
    public Pokemon cadastrar(Integer treinadorId, Integer pokeApiId, String nomePt, String nomeEn, String spriteUrl,
                             Integer vidaAtual, Integer vidaMaxima) {
        Optional<Treinador> tOpt = treinadores.findById(treinadorId);
        if (tOpt.isEmpty()) throw new IllegalArgumentException("Treinador não encontrado: " + treinadorId);
        if (pokeApiId != null && pokemons.buscarPorTreinadorIdEPokeApiId(treinadorId, pokeApiId).isPresent()) {
            throw new IllegalArgumentException("Pokémon já cadastrado para este treinador com pokeApiId: " + pokeApiId);
        }
        Treinador treinador = tOpt.get();
        Pokemon p = new Pokemon();
        p.setTreinador(treinador);
        p.setPokeApiId(pokeApiId);
        p.setNomePt(nomePt);
        p.setNomeEn(nomeEn);
        p.setSpriteUrl(spriteUrl);
        p.setVidaAtual(vidaAtual != null ? vidaAtual : 100);
        p.setVidaMaxima(vidaMaxima != null ? vidaMaxima : 100);
        return pokemons.save(p);
    }

    /**
     * Lista todos os Pokémon de um treinador.
     * @param treinadorId id do treinador
     * @return lista de Pokémon
     */
    public List<Pokemon> listar(Integer treinadorId) {
        return pokemons.buscarPorTreinadorId(treinadorId);
    }

    /**
     * Remove um Pokémon do treinador se pertencer a ele.
     * @param treinadorId id do treinador
     * @param pokemonId id do Pokémon
     * @return true se removido, false caso contrário
     */
    public boolean remover(Integer treinadorId, Integer pokemonId) {
        Optional<Pokemon> pOpt = pokemons.findByIdAndTreinadorId(pokemonId, treinadorId);
        if (pOpt.isEmpty()) return false;
        pokemons.delete(pOpt.get());
        return true;
    }
}