/*
 * Centro Pokémon - Data Inicialização
 * ---------------------------------------
 * @file        DataInicializacao.java
 * @author      Gustavo Pigatto, Matheus Schvann, Alexandre Lampert, Mateus Stock, Felipe Winter
 * @version     1.3
 * @date        2025-11-22
 * @description Serviço responsável por buscar dados na PokeAPI v2 e montar
 *               objetos de domínio (Pokémon, Tipos, Stats, Descrições).
 *               Persistência será integrada nas próximas etapas.
 */

package com.centropokemon.service;

import com.centropokemon.model.Pokemon;
import com.centropokemon.model.PokemonDescricao;
import com.centropokemon.model.PokemonStats;
import com.centropokemon.model.Tipo;
import com.centropokemon.repository.PokemonRepository;
import com.centropokemon.repository.PokemonStatsRepository;
import com.centropokemon.repository.PokemonDescricaoRepository;
import com.centropokemon.repository.TipoRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpEntity;
import org.springframework.http.ResponseEntity;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;

/**
 * Serviço de inicialização de dados a partir da PokeAPI v2.
 * Realiza requisições HTTP, interpreta respostas e constrói entidades JPA
 * prontas para persistência.
 */
@Service
public class DataInicializacao {

    private static final String API_BASE = "https://pokeapi.co/api/v2";
    private static final int TOTAL_POKEMON = 898;
    

    /**
     * Mapa de tradução de tipos da API (inglês) para português.
     */
    private static final Map<String, String> TRADUCAO_TIPOS;

    static {
        TRADUCAO_TIPOS = new HashMap<>();
        TRADUCAO_TIPOS.put("normal", "Normal");
        TRADUCAO_TIPOS.put("fighting", "Lutador");
        TRADUCAO_TIPOS.put("flying", "Voador");
        TRADUCAO_TIPOS.put("poison", "Venenoso");
        TRADUCAO_TIPOS.put("ground", "Terrestre");
        TRADUCAO_TIPOS.put("rock", "Pedra");
        TRADUCAO_TIPOS.put("bug", "Inseto");
        TRADUCAO_TIPOS.put("ghost", "Fantasma");
        TRADUCAO_TIPOS.put("steel", "Aço");
        TRADUCAO_TIPOS.put("fire", "Fogo");
        TRADUCAO_TIPOS.put("water", "Água");
        TRADUCAO_TIPOS.put("grass", "Planta");
        TRADUCAO_TIPOS.put("electric", "Elétrico");
        TRADUCAO_TIPOS.put("psychic", "Psíquico");
        TRADUCAO_TIPOS.put("ice", "Gelo");
        TRADUCAO_TIPOS.put("dragon", "Dragão");
        TRADUCAO_TIPOS.put("dark", "Sombrio");
        TRADUCAO_TIPOS.put("fairy", "Fada");
    }

    /**
    * Construtor com injeção de repositórios e clientes HTTP/JSON.
    */
    public DataInicializacao(
            PokemonRepository pokemonRepository,
            TipoRepository tipoRepository,
            PokemonStatsRepository statsRepository,
            PokemonDescricaoRepository descricaoRepository
    ) {
        this.http = new RestTemplate();
        this.mapper = new ObjectMapper();
        this.pokemonRepository = pokemonRepository;
        this.tipoRepository = tipoRepository;
        this.statsRepository = statsRepository;
        this.descricaoRepository = descricaoRepository;
    }

    /**
     * Busca e constrói um Pokémon completo a partir da PokeAPI.
     * Inclui nome em EN/PT, sprite com fallback, tipos traduzidos,
     * stats e descrições em PT/EN.
     *
     * @param nomeOuId nome em inglês ou ID numérico do Pokémon
     * @return entidade Pokemon preenchida
     */
    public Pokemon carregarPokemon(String nomeOuId) {
        JsonNode pokemonNode = getPokemonNode(nomeOuId);
        if (pokemonNode == null) {
            return null;
        }

        int id = pokemonNode.path("id").asInt();
        String nomeEn = pokemonNode.path("name").asText();
        String spriteUrl = escolherSprite(pokemonNode.path("sprites"), nomeEn, id);

        Pokemon pokemon = new Pokemon();
        pokemon.setPokeApiId(id);
        pokemon.setNomeEn(nomeEn);
        pokemon.setSpriteUrl(spriteUrl);

        Integer heightDm = pokemonNode.path("height").isMissingNode() ? null : pokemonNode.path("height").asInt();
        Integer weightHg = pokemonNode.path("weight").isMissingNode() ? null : pokemonNode.path("weight").asInt();
        if (heightDm != null) pokemon.setAltura(heightDm / 10.0);
        if (weightHg != null) pokemon.setPeso(weightHg / 10.0);

        List<Tipo> tipos = extrairTipos(pokemonNode.path("types"));
        pokemon.setTipos(resolverTipos(tipos));

        PokemonStats stats = extrairStats(pokemonNode.path("stats"));
        stats.setPokemon(pokemon);
        pokemon.setStats(stats);
        if (stats.getHp() != null) {
            pokemon.setVidaMaxima(stats.getHp());
            pokemon.setVidaAtual(stats.getHp());
        }
        List<String> habilidades = extrairHabilidades(pokemonNode.path("abilities"));
        pokemon.setHabilidades(habilidades);

        JsonNode speciesNode = getSpeciesNode(String.valueOf(id));
        String nomePt = extrairNomePt(speciesNode);
        pokemon.setNomePt(nomePt != null ? nomePt : nomeEn);

        PokemonDescricao descricao = extrairDescricao(speciesNode, pokemon);
        List<PokemonDescricao> descricoes = new ArrayList<>();
        if (descricao != null) {
            descricoes.add(descricao);
        }
        pokemon.setDescricoes(descricoes);

        if (pokemon.getSpriteUrl() == null || pokemon.getSpriteUrl().isBlank()) {
            pokemon.setSpriteUrl("https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/" + id + ".png");
        }
        Pokemon salvo = salvarOuAtualizarPokemon(pokemon);
        return salvo;
    }

    /**
     * Monta o Pokémon diretamente da PokeAPI SEM persistir no banco.
     * Usado pela Pokédex para funcionar mesmo sem BD disponível.
     *
     * @param nomeOuId nome (en) ou id
     * @return entidade Pokemon preenchida (não persistida)
     */
    public Pokemon montarPokemon(String nomeOuId) {
        JsonNode pokemonNode = getPokemonNode(nomeOuId);
        if (pokemonNode == null) {
            return null;
        }

        int id = pokemonNode.path("id").asInt();
        String nomeEn = pokemonNode.path("name").asText();
        String spriteUrl = escolherSprite(pokemonNode.path("sprites"), nomeEn, id);

        Pokemon pokemon = new Pokemon();
        pokemon.setPokeApiId(id);
        pokemon.setNomeEn(nomeEn);
        pokemon.setSpriteUrl(spriteUrl);

        Integer heightDm = pokemonNode.path("height").isMissingNode() ? null : pokemonNode.path("height").asInt();
        Integer weightHg = pokemonNode.path("weight").isMissingNode() ? null : pokemonNode.path("weight").asInt();
        if (heightDm != null) pokemon.setAltura(heightDm / 10.0);
        if (weightHg != null) pokemon.setPeso(weightHg / 10.0);

        // Tipos: usa lista pura sem consultar/salvar no repositório
        List<Tipo> tipos = extrairTipos(pokemonNode.path("types"));
        pokemon.setTipos(tipos);

        // Stats: monta objeto em memória
        PokemonStats stats = extrairStats(pokemonNode.path("stats"));
        stats.setPokemon(pokemon);
        pokemon.setStats(stats);
        if (stats.getHp() != null) {
            pokemon.setVidaMaxima(stats.getHp());
            pokemon.setVidaAtual(stats.getHp());
        }

        JsonNode speciesNode = getSpeciesNode(String.valueOf(id));
        String nomePt = extrairNomePt(speciesNode);
        pokemon.setNomePt(nomePt != null ? nomePt : nomeEn);

        PokemonDescricao descricao = extrairDescricao(speciesNode, pokemon);
        List<PokemonDescricao> descricoes = new ArrayList<>();
        if (descricao != null) {
            descricoes.add(descricao);
        }
        pokemon.setDescricoes(descricoes);

        if (pokemon.getSpriteUrl() == null || pokemon.getSpriteUrl().isBlank()) {
            pokemon.setSpriteUrl("https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/" + id + ".png");
        }
        return pokemon;
    }

    public Pokemon carregarPokemonAleatorio() {
        int id = (int) (Math.random() * TOTAL_POKEMON) + 1;
        return carregarPokemon(String.valueOf(id));
    }

    /**
     * Monta Pokémon aleatório SEM persistir.
     */
    public Pokemon montarPokemonAleatorio() {
        int id = (int) (Math.random() * TOTAL_POKEMON) + 1;
        return montarPokemon(String.valueOf(id));
    }

    public Pokemon carregarPokemonAleatorioPorTipo(String type) {
        JsonNode typeNode = getTypeNode(type);
        if (typeNode == null) {
            return null;
        }
        JsonNode list = typeNode.path("pokemon");
        if (!list.isArray() || list.isEmpty()) {
            return null;
        }
        int idx = (int) (Math.random() * list.size());
        JsonNode entry = list.get(idx).path("pokemon");
        String url = entry.path("url").asText();
        String[] parts = url.split("/");
        String idStr = parts[parts.length - 1].isBlank() ? parts[parts.length - 2] : parts[parts.length - 1];
        return carregarPokemon(idStr);
    }

    /**
     * Monta Pokémon aleatório por tipo SEM persistir.
     */
    public Pokemon montarPokemonAleatorioPorTipo(String type) {
        JsonNode typeNode = getTypeNode(type);
        if (typeNode == null) {
            return null;
        }
        JsonNode list = typeNode.path("pokemon");
        if (!list.isArray() || list.isEmpty()) {
            return null;
        }
        int idx = (int) (Math.random() * list.size());
        JsonNode entry = list.get(idx).path("pokemon");
        String url = entry.path("url").asText();
        String[] parts = url.split("/");
        String idStr = parts[parts.length - 1].isBlank() ? parts[parts.length - 2] : parts[parts.length - 1];
        return montarPokemon(idStr);
    }

    private final RestTemplate http;
    private final ObjectMapper mapper;
    private final PokemonRepository pokemonRepository;
    private final TipoRepository tipoRepository;
    private final PokemonStatsRepository statsRepository;
    private final PokemonDescricaoRepository descricaoRepository;

    private List<Tipo> resolverTipos(List<Tipo> tipos) {
        List<Tipo> resolvidos = new ArrayList<>();
        for (Tipo tipo : tipos) {
            Optional<Tipo> existente = tipoRepository.findByNomeEnIgnoreCase(tipo.getNomeEn());
            if (existente.isEmpty()) {
                existente = tipoRepository.findByNomePtIgnoreCase(tipo.getNomePt());
            }
            Tipo t = existente.orElseGet(() -> tipoRepository.save(tipo));
            resolvidos.add(t);
        }
        return resolvidos;
    }

    private Pokemon salvarOuAtualizarPokemon(Pokemon pokemon) {
        Optional<Pokemon> existente = pokemonRepository.findByPokeApiId(pokemon.getPokeApiId());
        Pokemon alvo;
        if (existente.isPresent()) {
            alvo = existente.get();
            alvo.setNomeEn(pokemon.getNomeEn());
            alvo.setNomePt(pokemon.getNomePt());
            alvo.setSpriteUrl(pokemon.getSpriteUrl());
            alvo.setTipos(pokemon.getTipos());
            alvo.setVidaMaxima(pokemon.getVidaMaxima());
            alvo.setVidaAtual(pokemon.getVidaAtual());
            if (pokemon.getStats() != null) {
                PokemonStats stats = alvo.getStats();
                if (stats == null) {
                    stats = new PokemonStats();
                    stats.setPokemon(alvo);
                    alvo.setStats(stats);
                }
                stats.setHp(pokemon.getStats().getHp());
                stats.setAtaque(pokemon.getStats().getAtaque());
                stats.setDefesa(pokemon.getStats().getDefesa());
                stats.setVelocidade(pokemon.getStats().getVelocidade());
                stats.setAtaqueEspecial(pokemon.getStats().getAtaqueEspecial());
                stats.setDefesaEspecial(pokemon.getStats().getDefesaEspecial());
            }
            if (pokemon.getDescricoes() != null) {
                List<PokemonDescricao> descricoesAtualizadas = new ArrayList<>();
                for (PokemonDescricao d : pokemon.getDescricoes()) {
                    d.setPokemon(alvo);
                    descricoesAtualizadas.add(d);
                }
                alvo.setDescricoes(descricoesAtualizadas);
            }
        } else {
            alvo = pokemon;
        }
        return pokemonRepository.save(alvo);
    }

    /**
     * Extrai o melhor sprite disponível, priorizando Official Artwork,
     * depois Dream World e por fim front_default.
     *
     * @param sprites nó JSON de sprites
     * @return URL da imagem
     */
    private String extrairMelhorSprite(JsonNode sprites) {
        if (sprites == null || sprites.isMissingNode()) return null;
        JsonNode other = sprites.path("other");
        String home = other.path("home").path("front_default").asText(null);
        if (home != null && !home.isBlank()) return home;
        String official = other.path("official-artwork").path("front_default").asText(null);
        if (official != null && !official.isBlank()) return official;
        String front = sprites.path("front_default").asText(null);
        if (front != null && !front.isBlank()) return front;
        String dream = other.path("dream_world").path("front_default").asText(null);
        return dream;
    }

    private String escolherSprite(JsonNode sprites, String nomeEn, int id) {
        List<String> candidatos = new ArrayList<>();
        String primario = extrairMelhorSprite(sprites);
        if (primario != null && !primario.isBlank()) candidatos.add(primario);
        String idStr3 = String.format("%03d", id);
        candidatos.add("https://assets.pokemon.com/assets/cms2/img/pokedex/full/" + idStr3 + ".png");
        String nomeLower = nomeEn == null ? null : nomeEn.toLowerCase();
        if (nomeLower != null && !nomeLower.isBlank()) {
            candidatos.add("https://img.pokemondb.net/artwork/large/" + nomeLower + ".jpg");
        }
        candidatos.add("https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/" + id + ".png");

        for (String url : candidatos) {
            if (url == null || url.isBlank()) continue;
            if (urlDisponivel(url)) return url;
        }
        return primario;
    }

    private boolean urlDisponivel(String url) {
        try {
            ResponseEntity<Void> resp = http.exchange(url, HttpMethod.HEAD, HttpEntity.EMPTY, Void.class);
            int code = resp.getStatusCode().value();
            return code >= 200 && code < 400;
        } catch (RestClientResponseException e) {
            int code = e.getRawStatusCode();
            return code >= 200 && code < 400;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Constrói a lista de tipos a partir do JSON de tipos.
     *
     * @param types nó JSON "types"
     * @return lista de tipos traduzidos
     */
    private List<Tipo> extrairTipos(JsonNode types) {
        List<Tipo> lista = new ArrayList<>();
        if (types == null || !types.isArray()) return lista;
        for (JsonNode t : types) {
            String en = t.path("type").path("name").asText();
            String pt = TRADUCAO_TIPOS.getOrDefault(en, en);
            Tipo tipo = new Tipo();
            tipo.setNome(pt);
            tipo.setNomeEn(en);
            tipo.setNomePt(pt);
            lista.add(tipo);
        }
        return lista;
    }

    /**
     * Constrói os atributos base do Pokémon a partir do JSON de stats.
     *
     * @param stats nó JSON "stats"
     * @return entidade PokemonStats preenchida
     */
    private PokemonStats extrairStats(JsonNode stats) {
        if (stats == null || !stats.isArray()) return new PokemonStats();
        Integer hp = null, atk = null, def = null, spd = null, spAtk = null, spDef = null;
        for (JsonNode s : stats) {
            String nome = s.path("stat").path("name").asText();
            int base = s.path("base_stat").asInt();
            switch (nome) {
                case "hp": hp = base; break;
                case "attack": atk = base; break;
                case "defense": def = base; break;
                case "speed": spd = base; break;
                case "special-attack": spAtk = base; break;
                case "special-defense": spDef = base; break;
                default: break;
            }
        }
        return new PokemonStats(null, hp, atk, def, spd, spAtk, spDef);
    }

    /**
     * Obtém o nome em português a partir do JSON de species.
     *
     * @param species nó JSON "pokemon-species"
     * @return nome em português ou null
     */
    private String extrairNomePt(JsonNode species) {
        if (species == null || species.isMissingNode()) return null;
        JsonNode names = species.path("names");
        if (names.isArray()) {
            for (JsonNode n : names) {
                String lang = n.path("language").path("name").asText();
                if (Objects.equals(lang, "pt-BR")) {
                    return n.path("name").asText();
                }
            }
            for (JsonNode n : names) {
                String lang = n.path("language").path("name").asText();
                if (Objects.equals(lang, "en")) {
                    return n.path("name").asText();
                }
            }
        }
        return null;
    }

    /**
     * Extrai uma descrição em PT e EN a partir do JSON de species.
     *
     * @param species nó JSON "pokemon-species"
     * @param pokemon entidade alvo
     * @return PokemonDescricao com textos PT/EN ou null
     */
    private PokemonDescricao extrairDescricao(JsonNode species, Pokemon pokemon) {
        if (species == null || species.isMissingNode()) return null;
        String pt = null, en = null;
        JsonNode entries = species.path("flavor_text_entries");
        if (entries.isArray()) {
            for (JsonNode e : entries) {
                String lang = e.path("language").path("name").asText();
                String text = limparDescricao(e.path("flavor_text").asText());
                if (pt == null && Objects.equals(lang, "pt-BR")) pt = text;
                if (en == null && Objects.equals(lang, "en")) en = text;
                if (pt != null && en != null) break;
            }
        }
        return new PokemonDescricao(pokemon, pt, en);
    }

    /**
     * Remove quebras de linha e formata texto da descrição.
     *
     * @param raw texto bruto
     * @return texto limpo
     */
    private String limparDescricao(String raw) {
        if (raw == null) return null;
        return raw.replace('\n', ' ').replace('\f', ' ').trim();
    }

    /**
     * Faz a chamada ao endpoint pokemon/{nomeOuId} e retorna o JSON.
     *
     * @param nomeOuId identificador do Pokémon (nome ou ID)
     * @return nó JSON ou null
     */
    private JsonNode getPokemonNode(String nomeOuId) {
        try {
            String url = API_BASE + "/pokemon/" + nomeOuId.toLowerCase();
            String body = http.getForObject(url, String.class);
            return mapper.readTree(body);
        } catch (Exception e) {
            return null;
        }
    }

    private JsonNode getTypeNode(String type) {
        try {
            String url = API_BASE + "/type/" + type.toLowerCase();
            String body = http.getForObject(url, String.class);
            return mapper.readTree(body);
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Faz a chamada ao endpoint pokemon-species/{id} e retorna o JSON.
     *
     * @param id identificador numérico
     * @return nó JSON ou null
     */
    private JsonNode getSpeciesNode(String id) {
        try {
            String url = API_BASE + "/pokemon-species/" + id;
            String body = http.getForObject(url, String.class);
            return mapper.readTree(body);
        } catch (Exception e) {
            return null;
        }
    }

    private List<String> extrairHabilidades(JsonNode abilities) {
        List<String> lista = new ArrayList<>();
        if (abilities == null || !abilities.isArray()) return lista;
        for (JsonNode a : abilities) {
            String nome = a.path("ability").path("name").asText(null);
            if (nome != null && !nome.isBlank()) lista.add(nome);
        }
        return lista;
    }
}
