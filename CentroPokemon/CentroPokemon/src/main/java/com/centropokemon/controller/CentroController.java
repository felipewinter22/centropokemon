package com.centropokemon.controller;

import com.centropokemon.model.Pokemon;
import com.centropokemon.service.CentroService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@CrossOrigin(origins = "http://localhost:8080")
@RequestMapping("/CentroPokemon/api/centro")
public class CentroController {

    private final CentroService centro;

    public CentroController(CentroService centro) {
        this.centro = centro;
    }

    @PostMapping("/treinadores/{treinadorId}/pokemons/{pokemonId}/curar")
    public ResponseEntity<Pokemon> curar(@PathVariable Integer treinadorId, @PathVariable Integer pokemonId) {
        try {
            Pokemon p = centro.curar(treinadorId, pokemonId);
            return ResponseEntity.ok(p);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @PostMapping("/treinadores/{treinadorId}/pokemons/curar-todos")
    public ResponseEntity<List<Pokemon>> curarTodos(@PathVariable Integer treinadorId) {
        List<Pokemon> lista = centro.curarTodos(treinadorId);
        return ResponseEntity.ok(lista);
    }

    @GetMapping("/treinadores/{treinadorId}/pokemons/{pokemonId}/precisa-curar")
    public ResponseEntity<Map<String, Boolean>> precisaCurar(@PathVariable Integer treinadorId, @PathVariable Integer pokemonId) {
        try {
            boolean precisa = centro.precisaCurar(treinadorId, pokemonId);
            Map<String, Boolean> out = new HashMap<>();
            out.put("precisaCurar", precisa);
            return ResponseEntity.ok(out);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @GetMapping("/treinadores/{treinadorId}/status")
    public ResponseEntity<Map<String, Long>> status(@PathVariable Integer treinadorId) {
        long total = centro.contarPokemonsTreinador(treinadorId);
        long precisam = centro.contarPokemonsQuePrecisamCura(treinadorId);
        Map<String, Long> out = new HashMap<>();
        out.put("totalPokemons", total);
        out.put("precisamCura", precisam);
        return ResponseEntity.ok(out);
    }
}