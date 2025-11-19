/*
 * Centro Pokémon - Controlador de Treinadores
 * ---------------------------------------
 * @file        TreinadorController.java
 * @author      Gustavo Pigatto, Matheus Schvann, Alexandre Lampert, Mateus Stock, Felipe Winter
 * @version     1.0
 * @date        2025-11-18
 * @description Endpoints REST para cadastro e autenticação de Treinadores.
 */

package com.centropokemon.controller;

import com.centropokemon.model.Treinador;
import com.centropokemon.service.TreinadorService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controlador REST para o ciclo de vida do {@link Treinador}.
 * Exponde endpoints para cadastro e login.
 */
@RestController
@CrossOrigin(origins = "http://localhost:8080")
@RequestMapping("/CentroPokemon/api/treinadores")
public class TreinadorController {

    private final TreinadorService service;

    /**
     * Construtor com injeção do serviço de treinadores.
     * @param service serviço de domínio
     */
    public TreinadorController(TreinadorService service) {
        this.service = service;
    }

    /**
     * Requisição de cadastro de treinador.
     * Campos obrigatórios: nome, usuario, email, senha.
     */
    public static class CadastroRequest {
        public String nome;
        public String usuario;
        public String email;
        public String senha;
        public String telefone;
    }

    /**
     * Requisição de login de treinador.
     * Aceita usuário OU e-mail, mais senha.
     */
    public static class LoginRequest {
        public String usuarioOuEmail;
        public String senha;
    }

    /**
     * Resposta segura do treinador (sem expor hash de senha).
     */
    public static class TreinadorResponse {
        public Integer id;
        public String nome;
        public String usuario;
        public String email;
        public String telefone;
        public Boolean ativo;

        public static TreinadorResponse of(Treinador t) {
            TreinadorResponse r = new TreinadorResponse();
            r.id = t.getId();
            r.nome = t.getNome();
            r.usuario = t.getUsuario();
            r.email = t.getEmail();
            r.telefone = t.getTelefone();
            r.ativo = t.getAtivo();
            return r;
        }
    }

    /**
     * Endpoint: POST /api/treinadores/cadastrar
     * Cadastra um novo treinador.
     * @param req dados de cadastro
     * @return entidade persistida (safe response) e HTTP 201
     */
    @PostMapping("/cadastrar")
    public ResponseEntity<TreinadorResponse> cadastrar(@RequestBody CadastroRequest req) {
        if (req == null || req.nome == null || req.usuario == null || req.email == null || req.senha == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
        Treinador t = service.cadastrar(req.nome, req.usuario, req.email, req.senha, req.telefone);
        return ResponseEntity.status(HttpStatus.CREATED).body(TreinadorResponse.of(t));
    }

    /**
     * Endpoint: POST /api/treinadores/login
     * Autentica um treinador por usuário ou e-mail.
     * @param req dados de login
     * @return 200 com treinador (safe response) ou 401
     */
    @PostMapping("/login")
    public ResponseEntity<TreinadorResponse> login(@RequestBody LoginRequest req) {
        if (req == null || req.usuarioOuEmail == null || req.senha == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
        return service.autenticar(req.usuarioOuEmail, req.senha)
                .map(t -> ResponseEntity.ok(TreinadorResponse.of(t)))
                .orElseGet(() -> ResponseEntity.status(HttpStatus.UNAUTHORIZED).build());
    }
}