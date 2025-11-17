package com.centropokemon.model;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

public class Tipo {

    /*
 * Centro Pokémon - Classe base Tipo
 * ---------------------------------------
 * @file        Tipo.java
 * @author      Gustavo Pigatto, Matheus Schvann, Alexandre Lampert, Mateus Stock, Felipe Winter
 * @version     1.0
 * @date        2025-11-16
 * @description Entidade JPA que representa um tipo de Pokémon.
 * Exemplos: Fogo, Água, Planta, Elétrico, etc.
 */

/**
 * Entidade JPA que representa um tipo de Pokémon.
 * Inclui suporte à tradução entre inglês (API) e português.
 */

package com.centropokemon.model;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "tipos")
public class Tipo {

    /** Identificador do tipo. */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    /** Nome do tipo em português (compatível com coluna existente). */
    @Column(name = "nome", nullable = false, unique = true)
    private String nome;

    /** Nome do tipo em português. */
    @Column(name = "nome_pt", nullable = false)
    private String nomePt;

    /** Nome do tipo em inglês (valor bruto vindo da API). */
    @Column(name = "nome_en", nullable = false)
    private String nomeEn;

    /** Relacionamento com Pokémons que possuem este tipo. */
    @ManyToMany(mappedBy = "tipos", fetch = FetchType.LAZY)
    private List<Pokemon> pokemons = new ArrayList<>();

    /** Construtor padrão. */
    public Tipo() {}

    /**
     * Construtor que inicializa com um nome em português.
     *
     * @param nome nome em português
     */
    public Tipo(String nome) {
        this.nome = nome;
        this.nomePt = nome;
        this.nomeEn = traduzirReverso(nome);
    }

    /**
     * Construtor que inicializa com nomes em português e inglês.
     *
     * @param nomePt nome do tipo em português
     * @param nomeEn nome do tipo em inglês
     */
    public Tipo(String nomePt, String nomeEn) {
        this.nomePt = nomePt;
        this.nomeEn = nomeEn;
        this.nome = nomePt;
    }

    /** @return identificador do tipo */
    public Integer getId() {
        return id;
    }

    /**
     * Define o identificador do tipo.
     *
     * @param id novo identificador
     */
    public void setId(Integer id) {
        this.id = id;
    }

    /** @return nome do tipo (português) */
    public String getNome() {
        return nome;
    }

    /**
     * Define o nome do tipo (português).
     * Também atualiza `nomePt` para manter consistência.
     *
     * @param nome nome em português
     */
    public void setNome(String nome) {
        this.nome = nome;
        this.nomePt = nome;
    }

    /** @return lista de Pokémons associados a este tipo */
    public List<Pokemon> getPokemons() {
        return pokemons;
    }

    /**
     * Define a lista de Pokémons associados a este tipo.
     *
     * @param pokemons lista de Pokémons
     */
    public void setPokemons(List<Pokemon> pokemons) {
        this.pokemons = pokemons;
	}

    /** @return nome do tipo em português */
    public String getNomePt() {
        return nomePt;
    }

    /**
     * Define o nome do tipo em português.
     * Também mantém o campo `nome` sincronizado.
     *
     * @param nomePt nome em português
     */
    public void setNomePt(String nomePt) {
        this.nomePt = nomePt;
        this.nome = nomePt;
    }

    /** @return nome do tipo em inglês */
    public String getNomeEn() {
        return nomeEn;
    }

    /**
     * Define o nome do tipo em inglês.
     *
     * @param nomeEn nome em inglês
     */
    public void setNomeEn(String nomeEn) {
        this.nomeEn = nomeEn;
    }

    /**
     * Normaliza e atribui o tipo a partir do valor recebido da API.
     * Preenche `nomeEn` com o valor normalizado e `nomePt`/`nome` com a tradução.
     *
     * @param apiType valor do tipo vindo da API (ex.: "fire", "water", "metal")
     */
    public void setFromApiType(String apiType) {
        String normalized = normalizar(apiType);
        this.nomeEn = normalized;
        this.nomePt = traduzir(normalized);
        this.nome = this.nomePt;
    }

    /**
     * Traduz um tipo da API (inglês/sinônimos) para português.
     * Valores não reconhecidos retornam "Desconhecido".
     *
     * @param apiType valor normalizado do tipo
     * @return tradução em português
     */
    public static String traduzir(String apiType) {
        switch (apiType) {
            case "fire": return "Fogo";
            case "water": return "Água";
            case "grass": return "Planta";
            case "electric": return "Elétrico";
            case "ice": return "Gelo";
            case "fighting": return "Lutador";
            case "poison": return "Venenoso";
            case "ground": return "Terrestre";
            case "flying": return "Voador";
            case "psychic": return "Psíquico";
            case "bug": return "Inseto";
            case "rock": return "Pedra";
            case "ghost": return "Fantasma";
            case "dragon": return "Dragão";
            case "dark": return "Sombrio";
            case "steel":
            case "metal": return "Aço";
            case "fairy": return "Fada";
            case "normal": return "Normal";
            default: return "Desconhecido";
        }
    }

    /**
     * Reverte um nome em português para o correspondente em inglês básico.
     * Útil para inicializações a partir de português.
     *
     * @param nomePt nome em português
     * @return nome básico em inglês
     */
    public static String traduzirReverso(String nomePt) {
        String pt = normalizar(nomePt);
        switch (pt) {
            case "fogo": return "fire";
            case "agua": return "water";
            case "planta": return "grass";
            case "eletrico": return "electric";
            case "gelo": return "ice";
            case "lutador": return "fighting";
            case "venenoso": return "poison";
            case "terrestre": return "ground";
            case "voador": return "flying";
            case "psiquico": return "psychic";
            case "inseto": return "bug";
            case "pedra": return "rock";
            case "fantasma": return "ghost";
            case "dragao": return "dragon";
            case "sombrio": return "dark";
            case "aco": return "steel";
            case "fada": return "fairy";
            case "normal": return "normal";
            default: return pt;
        }
    }

    /**
     * Normaliza strings para comparação/tradução: trim, minúsculas, remove acentos e hífens.
     *
     * @param valor valor de entrada
     * @return valor normalizado
     */
    public static String normalizar(String valor) {
        if (valor == null) return "";
        String v = valor.trim().toLowerCase();
        v = v.replace("á", "a").replace("â", "a").replace("ã", "a").replace("à", "a");
        v = v.replace("é", "e").replace("ê", "e");
        v = v.replace("í", "i").replace("î", "i");
        v = v.replace("ó", "o").replace("ô", "o").replace("õ", "o");
        v = v.replace("ú", "u").replace("û", "u");
        v = v.replace("ç", "c");
        v = v.replace("-", "");
        return v;
    }

    /**
     * Enumeração interna com os tipos básicos de Pokémon.
     * Inclui documentação breve para cada tipo.
     */
    public enum TipoBasico {
        /** Tipo Normal: sem vantagens claras, equilíbrio geral. */ NORMAL,
        /** Tipo Fogo: forte contra Planta, Gelo, Inseto e Aço. */ FOGO,
        /** Tipo Água: forte contra Fogo, Pedra e Terrestre. */ AGUA,
        /** Tipo Planta: forte contra Água, Terrestre e Pedra. */ PLANTA,
        /** Tipo Elétrico: forte contra Água e Voador. */ ELETRICO,
        /** Tipo Gelo: forte contra Dragão, Planta, Voador e Terra. */ GELO,
        /** Tipo Lutador: forte contra Normal, Pedra, Gelo e Aço. */ LUTADOR,
        /** Tipo Venenoso: forte contra Planta e Fada. */ VENENOSO,
        /** Tipo Terrestre: forte contra Fogo, Elétrico, Venenoso e Pedra. */ TERRESTRE,
        /** Tipo Voador: forte contra Lutador, Planta e Inseto. */ VOADOR,
        /** Tipo Psíquico: forte contra Lutador e Venenoso. */ PSIQUICO,
        /** Tipo Inseto: forte contra Planta, Psíquico e Sombrio. */ INSETO,
        /** Tipo Pedra: forte contra Fogo, Gelo, Voador e Inseto. */ PEDRA,
        /** Tipo Fantasma: forte contra Psíquico e Fantasma. */ FANTASMA,
        /** Tipo Dragão: forte contra Dragão. */ DRAGAO,
        /** Tipo Sombrio: forte contra Psíquico e Fantasma. */ SOMBRIO,
        /** Tipo Aço: forte contra Gelo, Pedra e Fada. */ ACO,
        /** Tipo Fada: forte contra Lutador, Dragão e Sombrio. */ FADA
    }
}
}