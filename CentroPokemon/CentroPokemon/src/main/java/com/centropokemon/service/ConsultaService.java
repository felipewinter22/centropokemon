package com.centropokemon.service;

import com.centropokemon.model.Consulta;
import com.centropokemon.model.Pokemon;
import com.centropokemon.model.Treinador;
import com.centropokemon.repository.ConsultaRepository;
import com.centropokemon.repository.PokemonRepository;
import com.centropokemon.repository.TreinadorRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ConsultaService {
    private final ConsultaRepository consultas;
    private final TreinadorRepository treinadores;
    private final PokemonRepository pokemons;

    public ConsultaService(ConsultaRepository consultas, TreinadorRepository treinadores, PokemonRepository pokemons) {
        this.consultas = consultas;
        this.treinadores = treinadores;
        this.pokemons = pokemons;
    }

    public Consulta agendar(Integer treinadorId, Integer pokemonId, String tipo, LocalDateTime dataHora, String observacoes) {
        Treinador t = treinadores.findById(treinadorId).orElseThrow(() -> new IllegalArgumentException("Treinador não encontrado"));
        Pokemon p = pokemons.findByIdAndTreinadorId(pokemonId, treinadorId).orElseThrow(() -> new IllegalArgumentException("Pokémon não pertence ao treinador"));
        Consulta c = new Consulta();
        c.setTreinador(t);
        c.setPokemon(p);
        c.setTipo(tipo);
        c.setDataHora(dataHora);
        c.setObservacoes(observacoes);
        return consultas.save(c);
    }

    public List<Consulta> listar(Integer treinadorId) {
        return consultas.findByTreinadorIdOrderByDataHoraAsc(treinadorId);
    }
}