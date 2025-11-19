package com.centropokemon.service;

import com.centropokemon.model.Pokemon;
import com.centropokemon.repository.PokemonRepository;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class CentroService {

    private final PokemonRepository pokemons;

    public CentroService(PokemonRepository pokemons) {
        this.pokemons = pokemons;
    }

    public Pokemon curar(Integer treinadorId, Integer pokemonId) {
        Optional<Pokemon> pOpt = pokemons.findByIdAndTreinadorId(pokemonId, treinadorId);
        if (pOpt.isEmpty()) throw new IllegalArgumentException("Pokémon não pertence ao treinador");
        Pokemon p = pOpt.get();
        p.tratar();
        return pokemons.save(p);
    }

    public List<Pokemon> curarTodos(Integer treinadorId) {
        List<Pokemon> lista = pokemons.findByTreinadorId(treinadorId);
        if (lista.isEmpty()) return lista;
        for (Pokemon p : lista) {
            p.tratar();
        }
        return new ArrayList<>(pokemons.saveAll(lista));
    }

    public boolean precisaCurar(Integer treinadorId, Integer pokemonId) {
        Optional<Pokemon> pOpt = pokemons.findByIdAndTreinadorId(pokemonId, treinadorId);
        if (pOpt.isEmpty()) throw new IllegalArgumentException("Pokémon não pertence ao treinador");
        return pOpt.get().precisaCurar();
    }

    public long contarPokemonsTreinador(Integer treinadorId) {
        return pokemons.countByTreinadorId(treinadorId);
    }

    public long contarPokemonsQuePrecisamCura(Integer treinadorId) {
        List<Pokemon> lista = pokemons.findByTreinadorId(treinadorId);
        return lista.stream().filter(p -> p.getVidaAtual() != null && p.getVidaMaxima() != null && p.getVidaAtual() < p.getVidaMaxima()).count();
    }
}