-- ============================================================================
-- CENTRO POKÉMON - DADOS INICIAIS
-- Inserção de dados básicos e de teste
-- ============================================================================

\c centro_pokemon;

SET search_path TO centro, public;

-- ============================================================================
-- 1. TIPOS POKÉMON
-- ============================================================================

INSERT INTO centro.tipo (nome_pt, nome_en, cor) VALUES
('Normal', 'normal', '#A8A878'),
('Fogo', 'fire', '#F08030'),
('Água', 'water', '#6890F0'),
('Elétrico', 'electric', '#F8D030'),
('Planta', 'grass', '#78C850'),
('Gelo', 'ice', '#98D8D8'),
('Lutador', 'fighting', '#C03028'),
('Venenoso', 'poison', '#A040A0'),
('Terrestre', 'ground', '#E0C068'),
('Voador', 'flying', '#A890F0'),
('Psíquico', 'psychic', '#F85888'),
('Inseto', 'bug', '#A8B820'),
('Pedra', 'rock', '#B8A038'),
('Fantasma', 'ghost', '#705898'),
('Dragão', 'dragon', '#7038F8'),
('Sombrio', 'dark', '#705848'),
('Metálico', 'steel', '#B8B8D0'),
('Fada', 'fairy', '#EE99AC')
ON CONFLICT (nome_en) DO NOTHING;

-- ============================================================================
-- 2. HABILIDADES COMUNS
-- ============================================================================

INSERT INTO centro.habilidade (nome_pt, nome_en, descricao) VALUES
('Estático', 'Static', 'Pode paralisar o oponente ao contato'),
('Chama', 'Blaze', 'Aumenta poder de ataques de fogo quando HP está baixo'),
('Torrente', 'Torrent', 'Aumenta poder de ataques de água quando HP está baixo'),
('Supercrescimento', 'Overgrow', 'Aumenta poder de ataques de planta quando HP está baixo'),
('Intimidação', 'Intimidate', 'Reduz o ataque do oponente'),
('Levitação', 'Levitate', 'Imunidade a ataques terrestres'),
('Cura Natural', 'Natural Cure', 'Cura problemas de status ao trocar'),
('Sincronização', 'Synchronize', 'Passa problemas de status para o oponente'),
('Foco Interno', 'Inner Focus', 'Previne flinching'),
('Olho Composto', 'Compound Eyes', 'Aumenta precisão dos movimentos')
ON CONFLICT (nome_en) DO NOTHING;

-- ============================================================================
-- 3. TREINADORES DE TESTE
-- ============================================================================

-- Senha: "pikachu123" (em produção usar BCrypt)
INSERT INTO centro.treinador (nome, usuario, email, senha, telefone) VALUES
('Ash Ketchum', 'ash', 'ash@pokemon.com', 'pikachu123', '47999999999'),
('Misty Waterflower', 'misty', 'misty@pokemon.com', 'starmie123', '47988888888'),
('Brock Harrison', 'brock', 'brock@pokemon.com', 'onix123', '47977777777'),
('Gary Oak', 'gary', 'gary@pokemon.com', 'rival123', '47966666666')
ON CONFLICT (usuario) DO NOTHING;

-- ============================================================================
-- 4. POKÉMON DE TESTE
-- ============================================================================

-- Pokémon do Ash
INSERT INTO centro.pokemon (treinador_id, poke_api_id, nome_pt, nome_en, sprite_url, vida_atual, vida_maxima, nivel, experiencia, apelido)
SELECT 
    t.id,
    25,
    'Pikachu',
    'Pikachu',
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png',
    100,
    100,
    50,
    125000,
    'Pikachu'
FROM centro.treinador t WHERE t.usuario = 'ash';

INSERT INTO centro.pokemon (treinador_id, poke_api_id, nome_pt, nome_en, sprite_url, vida_atual, vida_maxima, nivel, experiencia)
SELECT 
    t.id,
    6,
    'Charizard',
    'Charizard',
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/6.png',
    85,
    120,
    45,
    91125,
    NULL
FROM centro.treinador t WHERE t.usuario = 'ash';

-- Pokémon da Misty
INSERT INTO centro.pokemon (treinador_id, poke_api_id, nome_pt, nome_en, sprite_url, vida_atual, vida_maxima, nivel, experiencia)
SELECT 
    t.id,
    121,
    'Starmie',
    'Starmie',
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/121.png',
    95,
    95,
    40,
    64000,
    NULL
FROM centro.treinador t WHERE t.usuario = 'misty';

-- Pokémon do Brock
INSERT INTO centro.pokemon (treinador_id, poke_api_id, nome_pt, nome_en, sprite_url, vida_atual, vida_maxima, nivel, experiencia)
SELECT 
    t.id,
    95,
    'Onix',
    'Onix',
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/95.png',
    70,
    110,
    38,
    54872,
    NULL
FROM centro.treinador t WHERE t.usuario = 'brock';

-- ============================================================================
-- 5. RELACIONAMENTOS POKÉMON-TIPO
-- ============================================================================

-- Pikachu (Elétrico)
INSERT INTO centro.pokemon_tipo (pokemon_id, tipo_id)
SELECT p.id, t.id
FROM centro.pokemon p
CROSS JOIN centro.tipo t
WHERE p.nome_en = 'Pikachu' AND t.nome_en = 'electric';

-- Charizard (Fogo/Voador)
INSERT INTO centro.pokemon_tipo (pokemon_id, tipo_id)
SELECT p.id, t.id
FROM centro.pokemon p
CROSS JOIN centro.tipo t
WHERE p.nome_en = 'Charizard' AND t.nome_en IN ('fire', 'flying');

-- Starmie (Água/Psíquico)
INSERT INTO centro.pokemon_tipo (pokemon_id, tipo_id)
SELECT p.id, t.id
FROM centro.pokemon p
CROSS JOIN centro.tipo t
WHERE p.nome_en = 'Starmie' AND t.nome_en IN ('water', 'psychic');

-- Onix (Pedra/Terrestre)
INSERT INTO centro.pokemon_tipo (pokemon_id, tipo_id)
SELECT p.id, t.id
FROM centro.pokemon p
CROSS JOIN centro.tipo t
WHERE p.nome_en = 'Onix' AND t.nome_en IN ('rock', 'ground');

-- ============================================================================
-- 6. RELACIONAMENTOS POKÉMON-HABILIDADE
-- ============================================================================

-- Pikachu - Estático
INSERT INTO centro.pokemon_habilidade (pokemon_id, habilidade_id)
SELECT p.id, h.id
FROM centro.pokemon p
CROSS JOIN centro.habilidade h
WHERE p.nome_en = 'Pikachu' AND h.nome_en = 'Static';

-- Charizard - Chama
INSERT INTO centro.pokemon_habilidade (pokemon_id, habilidade_id)
SELECT p.id, h.id
FROM centro.pokemon p
CROSS JOIN centro.habilidade h
WHERE p.nome_en = 'Charizard' AND h.nome_en = 'Blaze';

-- ============================================================================
-- 7. CONSULTAS DE TESTE
-- ============================================================================

-- Consulta agendada para Pikachu
INSERT INTO centro.consulta (treinador_id, pokemon_id, tipo_consulta, data_hora, observacoes, status)
SELECT 
    t.id,
    p.id,
    'CHECKUP',
    CURRENT_TIMESTAMP + INTERVAL '2 days',
    'Check-up de rotina',
    'AGENDADA'
FROM centro.treinador t
JOIN centro.pokemon p ON p.treinador_id = t.id
WHERE t.usuario = 'ash' AND p.nome_en = 'Pikachu';

-- Consulta concluída para Charizard
INSERT INTO centro.consulta (treinador_id, pokemon_id, tipo_consulta, data_hora, observacoes, status, data_conclusao)
SELECT 
    t.id,
    p.id,
    'CONSULTA',
    CURRENT_TIMESTAMP - INTERVAL '1 day',
    'Tratamento de queimaduras leves',
    'CONCLUIDA',
    CURRENT_TIMESTAMP - INTERVAL '1 day' + INTERVAL '30 minutes'
FROM centro.treinador t
JOIN centro.pokemon p ON p.treinador_id = t.id
WHERE t.usuario = 'ash' AND p.nome_en = 'Charizard';

-- ============================================================================
-- 8. HISTÓRICO DE CURA
-- ============================================================================

-- Cura do Charizard
INSERT INTO centro.historico_cura (pokemon_id, vida_antes, vida_depois, metodo)
SELECT 
    p.id,
    50,
    85,
    'CENTRO_POKEMON'
FROM centro.pokemon p
WHERE p.nome_en = 'Charizard';

-- ============================================================================
-- FIM DOS DADOS INICIAIS
-- ============================================================================

-- Verificar dados inseridos
SELECT 'Tipos cadastrados:' as info, COUNT(*) as total FROM centro.tipo
UNION ALL
SELECT 'Habilidades cadastradas:', COUNT(*) FROM centro.habilidade
UNION ALL
SELECT 'Treinadores cadastrados:', COUNT(*) FROM centro.treinador
UNION ALL
SELECT 'Pokémon cadastrados:', COUNT(*) FROM centro.pokemon
UNION ALL
SELECT 'Consultas agendadas:', COUNT(*) FROM centro.consulta;
