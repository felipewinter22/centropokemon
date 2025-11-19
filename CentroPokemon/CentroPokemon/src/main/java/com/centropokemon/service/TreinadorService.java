/*
 * Centro Pokémon - Serviço de Treinadores
 * ---------------------------------------
 * @file        TreinadorService.java
 * @author      Gustavo Pigatto, Matheus Schvann, Alexandre Lampert, Mateus Stock, Felipe Winter
 * @version     1.1
 * @date        2025-11-19
 * @description Serviço de domínio para cadastro e autenticação de Treinadores.
 *              Fornece validações e consultas utilitárias.
 */

package com.centropokemon.service;

import com.centropokemon.model.Treinador;
import com.centropokemon.repository.TreinadorRepository;
import org.springframework.stereotype.Service;

import java.util.Optional;

/**
 * Serviço responsável pelo ciclo de vida do {@link Treinador}:
 * cadastro, autenticação e consultas utilitárias.
 */
@Service
public class TreinadorService {

    private final TreinadorRepository treinadores;

    /**
     * Construtor com injeção do repositório de treinadores.
     * @param treinadores repositório JPA
     */
    public TreinadorService(TreinadorRepository treinadores) {
        this.treinadores = treinadores;
    }

    /**
     * Cadastra um novo treinador com validações e senha simples.
     * @param nome nome completo
     * @param usuario nome de usuário (único)
     * @param email e-mail (único)
     * @param senhaEmClaro senha em texto claro
     * @param telefone telefone (opcional)
     * @return treinador persistido
     * @throws IllegalArgumentException quando já existe usuário/e-mail cadastrados
     */
    public Treinador cadastrar(String nome, String usuario, String email, String senhaEmClaro, String telefone) {
        String n = nome != null ? nome.trim() : null;
        String u = usuario != null ? usuario.trim() : null;
        String e = email != null ? email.trim() : null;
        String s = senhaEmClaro != null ? senhaEmClaro.trim() : null;
        if (u == null || u.isBlank() || e == null || e.isBlank() || n == null || n.isBlank() || s == null || s.isBlank()) {
            throw new IllegalArgumentException("Campos obrigatórios inválidos");
        }
        if (treinadores.existePorUsuario(u)) {
            throw new IllegalArgumentException("Usuário já cadastrado: " + usuario);
        }
        if (treinadores.existePorEmail(e)) {
            throw new IllegalArgumentException("E-mail já cadastrado: " + email);
        }

        Treinador t = new Treinador();
        t.setNome(n);
        t.setUsuario(u);
        t.setEmail(e);
        t.setSenha(s);
        t.setTelefone(telefone != null ? telefone.trim() : null);
        t.setAtivo(true);
        return treinadores.save(t);
    }

    /**
     * Autentica um treinador por usuário OU e-mail e senha.
     * @param usuarioOuEmail usuário ou e-mail
     * @param senhaEmClaro senha em texto claro
     * @return Optional com o treinador autenticado, se credenciais válidas
     */
    public Optional<Treinador> autenticar(String usuarioOuEmail, String senhaEmClaro) {
        String senha = senhaEmClaro != null ? senhaEmClaro.trim() : null;
        Optional<Treinador> byUsuario = treinadores.buscarPorUsuario(usuarioOuEmail);
        Optional<Treinador> byEmail = byUsuario.isPresent() ? Optional.empty() : treinadores.buscarPorEmail(usuarioOuEmail);
        Optional<Treinador> candidato = byUsuario.isPresent() ? byUsuario : byEmail;
        return candidato.filter(t -> senha != null && senha.equals(t.getSenha()) && Boolean.TRUE.equals(t.getAtivo()));
    }

    /**
     * Busca um treinador por e-mail.
     * @param email e-mail
     * @return Optional com treinador
     */
    public Optional<Treinador> buscarPorEmail(String email) {
        return treinadores.buscarPorEmail(email);
    }

    /**
     * Busca um treinador por usuário.
     * @param usuario nome de usuário
     * @return Optional com treinador
     */
    public Optional<Treinador> buscarPorUsuario(String usuario) {
        return treinadores.buscarPorUsuario(usuario);
    }

    
}