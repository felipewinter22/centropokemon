/*
 * Centro Pokémon - Classe base Pokémon
 * ---------------------------------------
 * @file        Pokemon.java
 * @author      Gustavo Pigatto, Matheus Schvann, Alexandre Lampert, Mateus Stock, Felipe Winter
 * @version     1.1
 * @date        2025-11-18
 * @description Classe base representando um Pokémon para uso com a API.
 */

package com.centropokemon.model;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import com.fasterxml.jackson.annotation.JsonBackReference;
import java.util.ArrayList;
import java.util.List;

/**
 * Representa um Pokémon dentro do sistema do Centro Pokémon.
 * Contém informações básicas como nome, tipos, vida atual,
 * sprite e descrição. Também inclui utilitários de cura ( Poções ).
 */
@Entity
@Table(name = "pokemons")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Pokemon {

    /** Identificador do ID do Pokémon. */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    /** Nome do Pokémon em português. */
    @Column(name = "nome_pt", nullable = false)
    private String nomePt;

    /** Nome do Pokémon em inglês. */
    @Column(name = "nome_en", nullable = false)
    private String nomeEn;

    /** Identificador do Pokémon na PokeAPI. */
    @Column(name = "pokeapi_id")
    private Integer pokeApiId;

    /** URL ou caminho para a imagem do Pokémon. */
    @Column(name = "sprite_url", nullable = false)
    private String spriteUrl;

    /** Vida atual do Pokémon. */
    @Column(name = "vida_atual")
    private Integer vidaAtual;

    /** Vida máxima do Pokémon. */
    @Column(name = "vida_maxima")
    private Integer vidaMaxima;

    /** Relacionamento com descrições do Pokémon. */
    @OneToMany(mappedBy = "pokemon", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonManagedReference("descricao-pokemon")
    private List<PokemonDescricao> descricoes;

    /** Relacionamento com tipos do Pokémon. */
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "pokemon_tipos",
        joinColumns = @JoinColumn(name = "pokemon_id"),
        inverseJoinColumns = @JoinColumn(name = "tipo_id")
    )
    private List<Tipo> tipos;

    /** Relacionamento com stats do Pokémon. */
    @OneToOne(mappedBy = "pokemon", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonManagedReference("stats-pokemon")
    private PokemonStats stats;

    /** Treinador ao qual este Pokémon pertence. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "treinador_id")
    @JsonBackReference("treinador-pokemon")
    private Treinador treinador;

    /** Nível do Pokémon. */
    @Column(name = "nivel", nullable = false)
    private Integer nivel = 1;

    /** Lista de habilidades do Pokémon. */
    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "pokemon_habilidades", joinColumns = @JoinColumn(name = "pokemon_id"))
    @Column(name = "habilidade", nullable = false)
    private List<String> habilidades = new ArrayList<>();

    @Transient
    private Double altura;

    @Transient
    private Double peso;

    /**
     * Construtor padrão. Cria um Pokémon com vida inicial e máxima iguais a 100.
     */
    public Pokemon() {
        this.vidaAtual = 100;
        this.vidaMaxima = 100;
        this.descricoes = new ArrayList<>();
        this.tipos = new ArrayList<>();
    }

    /**
     * Construtor completo para inicialização com valores básicos.
     *
     * @param id       ID do Pokémon
     * @param nomePt   Nome do Pokémon em português
     * @param nomeEn   Nome do Pokémon em inglês
     * @param spriteUrl URL do sprite
     */
    public Pokemon(Integer id, String nomePt, String nomeEn, String spriteUrl) {
        this();
        this.id = id;
        this.nomePt = nomePt;
        this.nomeEn = nomeEn;
        this.spriteUrl = spriteUrl;
    }

    /** @return o ID do Pokémon */
    public Integer getId() {
        return id;
    }

    /**
     * Define o ID do Pokémon.
     *
     * @param id novo ID
     */
    public void setId(Integer id) {
        this.id = id;
    }

    /** @return o nome do Pokémon em português */
    public String getNomePt() {
        return nomePt;
    }

    /**
     * Define o nome do Pokémon em português.
     *
     * @param nomePt nome em português
     */
    public void setNomePt(String nomePt) {
        this.nomePt = nomePt;
    }

    /** @return o nome do Pokémon em inglês */
    public String getNomeEn() {
        return nomeEn;
    }

    /**
     * Define o nome do Pokémon em inglês.
     *
     * @param nomeEn nome em inglês
     */
    public void setNomeEn(String nomeEn) {
        this.nomeEn = nomeEn;
    }

    /** @return o ID do Pokémon na PokeAPI */
    public Integer getPokeApiId() {
        return pokeApiId;
    }

    /**
     * Define o ID do Pokémon na PokeAPI.
     *
     * @param pokeApiId ID externo da PokeAPI
     */
    public void setPokeApiId(Integer pokeApiId) {
        this.pokeApiId = pokeApiId;
    }

    /** @return URL do sprite do Pokémon */
    public String getSpriteUrl() {
        return spriteUrl;
    }

    /**
     * Define a URL do sprite do Pokémon.
     *
     * @param spriteUrl URL da imagem
     */
    public void setSpriteUrl(String spriteUrl) {
        this.spriteUrl = spriteUrl;
    }

    /** @return vida atual do Pokémon */
    public Integer getVidaAtual() {
        return vidaAtual;
    }

    /**
     * Define a vida atual do Pokémon.
     *
     * @param vidaAtual quantidade atual de vida
     */
    public void setVidaAtual(Integer vidaAtual) {
        this.vidaAtual = vidaAtual;
    }

    /** @return vida máxima do Pokémon */
    public Integer getVidaMaxima() {
        return vidaMaxima;
    }

    /**
     * Define a vida máxima do Pokémon.
     *
     * @param vidaMaxima quantidade máxima de vida
     */
    public void setVidaMaxima(Integer vidaMaxima) {
        this.vidaMaxima = vidaMaxima;
    }

    /** @return lista de descrições do Pokémon */
    public List<PokemonDescricao> getDescricoes() {
        return descricoes;
    }

    /**
     * Define a lista de descrições do Pokémon.
     *
     * @param descricoes lista de descrições
     */
    public void setDescricoes(List<PokemonDescricao> descricoes) {
        this.descricoes = descricoes;
    }

    /** @return lista de tipos do Pokémon */
    public List<Tipo> getTipos() {
        return tipos;
    }

    public Integer getNivel() { return nivel; }
    public void setNivel(Integer nivel) { this.nivel = nivel; }

    public List<String> getHabilidades() { return habilidades; }
    public void setHabilidades(List<String> habilidades) { this.habilidades = habilidades; }

    public Double getAltura() { return altura; }
    public void setAltura(Double altura) { this.altura = altura; }

    public Double getPeso() { return peso; }
    public void setPeso(Double peso) { this.peso = peso; }

    /**
     * Define a lista de tipos do Pokémon.
     *
     * @param tipos lista de tipos
     */
    public void setTipos(List<Tipo> tipos) {
        this.tipos = tipos;
    }

    /** @return stats do Pokémon */
    public PokemonStats getStats() {
        return stats;
    }

    /**
     * Define os stats do Pokémon.
     *
     * @param stats stats do Pokémon
     */
    public void setStats(PokemonStats stats) {
        this.stats = stats;
    }

    /** @return treinador associado ao Pokémon */
    public Treinador getTreinador() {
        return treinador;
    }
    /** @param treinador treinador associado ao Pokémon */
    public void setTreinador(Treinador treinador) {
        this.treinador = treinador;
    }

    /**
     * Restaura a vida do Pokémon para o valor máximo.
     */
    public void tratar() {
        this.vidaAtual = this.vidaMaxima;
    }

    /**
     * Verifica se o Pokémon precisa ser curado.
     *
     * @return true se vidaAtual < vidaMaxima, false caso contrário
     */
    public boolean precisaCurar() {
        return vidaAtual < vidaMaxima;
    }
}
