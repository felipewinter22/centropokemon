-- ============================================================================
-- CENTRO POKÉMON - VIEWS E RELATÓRIOS
-- Implementação de views para relatórios com junções complexas
-- ============================================================================

\c centro_pokemon;

SET search_path TO centro, relatorios, public;

-- ============================================================================
-- 1. VIEW: Visão Completa de Pokémon com Tipos e Habilidades
-- ============================================================================

CREATE OR REPLACE VIEW relatorios.vw_pokemon_completo AS
SELECT 
    p.id,
    p.poke_api_id,
    p.nome_pt,
    p.nome_en,
    p.apelido,
    p.nivel,
    p.experiencia,
    p.vida_atual,
    p.vida_maxima,
    ROUND((p.vida_atual::NUMERIC / p.vida_maxima::NUMERIC) * 100, 2) as percentual_vida,
    p.sprite_url,
    p.data_captura,
    -- Dados do treinador
    t.id as treinador_id,
    t.nome as treinador_nome,
    t.usuario as treinador_usuario,
    -- Tipos (agregados)
    STRING_AGG(DISTINCT tp.nome_pt, ', ' ORDER BY tp.nome_pt) as tipos_pt,
    STRING_AGG(DISTINCT tp.nome_en, ', ' ORDER BY tp.nome_en) as tipos_en,
    -- Habilidades (agregadas)
    STRING_AGG(DISTINCT h.nome_pt, ', ' ORDER BY h.nome_pt) as habilidades_pt,
    STRING_AGG(DISTINCT h.nome_en, ', ' ORDER BY h.nome_en) as habilidades_en,
    -- Status
    CASE 
        WHEN p.vida_atual = 0 THEN 'Derrotado'
        WHEN p.vida_atual < p.vida_maxima * 0.2 THEN 'Crítico'
        WHEN p.vida_atual < p.vida_maxima * 0.5 THEN 'Ferido'
        WHEN p.vida_atual < p.vida_maxima THEN 'Levemente Ferido'
        ELSE 'Saudável'
    END as status_saude
FROM centro.pokemon p
JOIN centro.treinador t ON t.id = p.treinador_id
LEFT JOIN centro.pokemon_tipo pt ON pt.pokemon_id = p.id
LEFT JOIN centro.tipo tp ON tp.id = pt.tipo_id
LEFT JOIN centro.pokemon_habilidade ph ON ph.pokemon_id = p.id
LEFT JOIN centro.habilidade h ON h.id = ph.habilidade_id
GROUP BY p.id, t.id, t.nome, t.usuario;

COMMENT ON VIEW relatorios.vw_pokemon_completo IS 
'Visão completa de pokémon com todos os relacionamentos e status de saúde';

-- ============================================================================
-- 2. VIEW: Consultas Detalhadas
-- ============================================================================

CREATE OR REPLACE VIEW relatorios.vw_consultas_detalhadas AS
SELECT 
    c.id,
    c.tipo_consulta,
    c.data_hora,
    c.status,
    c.observacoes,
    c.data_criacao,
    c.data_conclusao,
    -- Tempo de atendimento
    CASE 
        WHEN c.data_conclusao IS NOT NULL THEN
            EXTRACT(EPOCH FROM (c.data_conclusao - c.data_hora)) / 60
        ELSE NULL
    END as tempo_atendimento_minutos,
    -- Dados do treinador
    t.id as treinador_id,
    t.nome as treinador_nome,
    t.usuario as treinador_usuario,
    t.email as treinador_email,
    t.telefone as treinador_telefone,
    -- Dados do pokémon
    p.id as pokemon_id,
    p.nome_pt as pokemon_nome,
    p.nivel as pokemon_nivel,
    p.vida_atual as pokemon_vida_atual,
    p.vida_maxima as pokemon_vida_maxima,
    -- Classificação de urgência
    CASE 
        WHEN c.tipo_consulta = 'EMERGENCIA' THEN 'Alta'
        WHEN c.tipo_consulta = 'CONSULTA' THEN 'Média'
        ELSE 'Baixa'
    END as urgencia
FROM centro.consulta c
JOIN centro.treinador t ON t.id = c.treinador_id
JOIN centro.pokemon p ON p.id = c.pokemon_id;

COMMENT ON VIEW relatorios.vw_consultas_detalhadas IS 
'Visão detalhada de consultas com informações de treinador e pokémon';

-- ============================================================================
-- 3. VIEW: Histórico de Curas Completo
-- ============================================================================

CREATE OR REPLACE VIEW relatorios.vw_historico_curas AS
SELECT 
    hc.id,
    hc.data_cura,
    hc.vida_antes,
    hc.vida_depois,
    hc.vida_depois - hc.vida_antes as hp_recuperado,
    hc.metodo,
    -- Dados do pokémon
    p.id as pokemon_id,
    p.nome_pt as pokemon_nome,
    p.nivel as pokemon_nivel,
    -- Dados do treinador
    t.id as treinador_id,
    t.nome as treinador_nome,
    t.usuario as treinador_usuario,
    -- Análise
    ROUND(((hc.vida_depois - hc.vida_antes)::NUMERIC / p.vida_maxima::NUMERIC) * 100, 2) as percentual_recuperado
FROM centro.historico_cura hc
JOIN centro.pokemon p ON p.id = hc.pokemon_id
JOIN centro.treinador t ON t.id = p.treinador_id;

COMMENT ON VIEW relatorios.vw_historico_curas IS 
'Histórico completo de curas com análise de recuperação';

-- ============================================================================
-- 4. VIEW: Estatísticas por Treinador
-- ============================================================================

CREATE OR REPLACE VIEW relatorios.vw_estatisticas_treinador AS
SELECT 
    t.id as treinador_id,
    t.nome,
    t.usuario,
    t.email,
    t.data_cadastro,
    -- Estatísticas de pokémon
    COUNT(DISTINCT p.id) as total_pokemon,
    COALESCE(ROUND(AVG(p.nivel), 2), 0) as nivel_medio,
    COALESCE(MAX(p.nivel), 0) as nivel_maximo,
    COALESCE(SUM(p.experiencia), 0) as experiencia_total,
    -- Estatísticas de saúde
    COUNT(DISTINCT CASE WHEN p.vida_atual = p.vida_maxima THEN p.id END) as pokemon_saudaveis,
    COUNT(DISTINCT CASE WHEN p.vida_atual < p.vida_maxima * 0.5 THEN p.id END) as pokemon_feridos,
    COUNT(DISTINCT CASE WHEN p.vida_atual = 0 THEN p.id END) as pokemon_derrotados,
    -- Estatísticas de consultas
    COUNT(DISTINCT c.id) as total_consultas,
    COUNT(DISTINCT CASE WHEN c.status = 'AGENDADA' THEN c.id END) as consultas_agendadas,
    COUNT(DISTINCT CASE WHEN c.status = 'CONCLUIDA' THEN c.id END) as consultas_concluidas,
    -- Estatísticas de curas
    COUNT(DISTINCT hc.id) as total_curas,
    COALESCE(SUM(hc.vida_depois - hc.vida_antes), 0) as hp_total_recuperado,
    -- Pokémon mais forte
    (SELECT p2.nome_pt 
     FROM centro.pokemon p2 
     WHERE p2.treinador_id = t.id 
     ORDER BY p2.nivel DESC, p2.experiencia DESC 
     LIMIT 1) as pokemon_mais_forte
FROM centro.treinador t
LEFT JOIN centro.pokemon p ON p.treinador_id = t.id
LEFT JOIN centro.consulta c ON c.treinador_id = t.id
LEFT JOIN centro.historico_cura hc ON hc.pokemon_id = p.id
GROUP BY t.id, t.nome, t.usuario, t.email, t.data_cadastro;

COMMENT ON VIEW relatorios.vw_estatisticas_treinador IS 
'Estatísticas completas por treinador incluindo pokémon, consultas e curas';

-- ============================================================================
-- 5. VIEW: Ranking de Treinadores
-- ============================================================================

CREATE OR REPLACE VIEW relatorios.vw_ranking_treinadores AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY 
        COALESCE(SUM(p.nivel), 0) DESC,
        COALESCE(SUM(p.experiencia), 0) DESC
    ) as posicao,
    t.id,
    t.nome,
    t.usuario,
    COUNT(p.id) as total_pokemon,
    COALESCE(ROUND(AVG(p.nivel), 2), 0) as nivel_medio,
    COALESCE(SUM(p.nivel), 0) as soma_niveis,
    COALESCE(SUM(p.experiencia), 0) as experiencia_total,
    -- Pontuação (fórmula customizada)
    COALESCE(SUM(p.nivel), 0) * 10 + COALESCE(SUM(p.experiencia), 0) / 1000 as pontuacao
FROM centro.treinador t
LEFT JOIN centro.pokemon p ON p.treinador_id = t.id
GROUP BY t.id, t.nome, t.usuario
ORDER BY pontuacao DESC;

COMMENT ON VIEW relatorios.vw_ranking_treinadores IS 
'Ranking de treinadores baseado em níveis e experiência dos pokémon';

-- ============================================================================
-- 6. VIEW: Pokémon Mais Populares
-- ============================================================================

CREATE OR REPLACE VIEW relatorios.vw_pokemon_populares AS
SELECT 
    p.poke_api_id,
    p.nome_pt,
    p.nome_en,
    COUNT(*) as total_capturados,
    ROUND(AVG(p.nivel), 2) as nivel_medio,
    COUNT(DISTINCT p.treinador_id) as total_treinadores,
    -- Tipos mais comuns
    (SELECT STRING_AGG(DISTINCT tp.nome_pt, ', ')
     FROM centro.pokemon p2
     JOIN centro.pokemon_tipo pt ON pt.pokemon_id = p2.id
     JOIN centro.tipo tp ON tp.id = pt.tipo_id
     WHERE p2.poke_api_id = p.poke_api_id
     LIMIT 1) as tipos
FROM centro.pokemon p
GROUP BY p.poke_api_id, p.nome_pt, p.nome_en
ORDER BY total_capturados DESC, nivel_medio DESC;

COMMENT ON VIEW relatorios.vw_pokemon_populares IS 
'Pokémon mais capturados e suas estatísticas';

-- ============================================================================
-- 7. VIEW: Agenda do Dia
-- ============================================================================

CREATE OR REPLACE VIEW relatorios.vw_agenda_dia AS
SELECT 
    c.id,
    c.data_hora,
    c.tipo_consulta,
    c.status,
    t.nome as treinador_nome,
    t.telefone as treinador_telefone,
    p.nome_pt as pokemon_nome,
    p.nivel as pokemon_nivel,
    -- Tempo até a consulta
    CASE 
        WHEN c.data_hora > CURRENT_TIMESTAMP THEN
            EXTRACT(EPOCH FROM (c.data_hora - CURRENT_TIMESTAMP)) / 3600
        ELSE 0
    END as horas_ate_consulta,
    -- Classificação
    CASE 
        WHEN c.data_hora < CURRENT_TIMESTAMP AND c.status = 'AGENDADA' THEN 'Atrasada'
        WHEN c.data_hora <= CURRENT_TIMESTAMP + INTERVAL '1 hour' AND c.status = 'AGENDADA' THEN 'Próxima'
        WHEN c.status = 'EM_ATENDIMENTO' THEN 'Em Atendimento'
        ELSE 'Agendada'
    END as situacao
FROM centro.consulta c
JOIN centro.treinador t ON t.id = c.treinador_id
JOIN centro.pokemon p ON p.id = c.pokemon_id
WHERE DATE(c.data_hora) = CURRENT_DATE
  AND c.status IN ('AGENDADA', 'EM_ATENDIMENTO')
ORDER BY c.data_hora;

COMMENT ON VIEW relatorios.vw_agenda_dia IS 
'Agenda de consultas do dia com situação atual';

-- ============================================================================
-- 8. VIEW: Pokémon Críticos (Precisam de Atenção)
-- ============================================================================

CREATE OR REPLACE VIEW relatorios.vw_pokemon_criticos AS
SELECT 
    p.id,
    p.nome_pt,
    p.nivel,
    p.vida_atual,
    p.vida_maxima,
    ROUND((p.vida_atual::NUMERIC / p.vida_maxima::NUMERIC) * 100, 2) as percentual_vida,
    t.id as treinador_id,
    t.nome as treinador_nome,
    t.telefone as treinador_telefone,
    t.email as treinador_email,
    -- Última cura
    (SELECT MAX(hc.data_cura)
     FROM centro.historico_cura hc
     WHERE hc.pokemon_id = p.id) as ultima_cura,
    -- Consulta agendada
    (SELECT MIN(c.data_hora)
     FROM centro.consulta c
     WHERE c.pokemon_id = p.id
       AND c.status = 'AGENDADA') as proxima_consulta
FROM centro.pokemon p
JOIN centro.treinador t ON t.id = p.treinador_id
WHERE p.vida_atual < p.vida_maxima * 0.3
ORDER BY (p.vida_atual::NUMERIC / p.vida_maxima::NUMERIC) ASC;

COMMENT ON VIEW relatorios.vw_pokemon_criticos IS 
'Pokémon com vida crítica que precisam de atenção urgente';

-- ============================================================================
-- 9. VIEW: Auditoria Resumida
-- ============================================================================

CREATE OR REPLACE VIEW relatorios.vw_auditoria_resumo AS
SELECT 
    'Treinador' as tabela,
    operacao,
    COUNT(*) as total_operacoes,
    MIN(data_operacao) as primeira_operacao,
    MAX(data_operacao) as ultima_operacao
FROM auditoria.treinador_audit
GROUP BY operacao
UNION ALL
SELECT 
    'Pokemon' as tabela,
    operacao,
    COUNT(*) as total_operacoes,
    MIN(data_operacao) as primeira_operacao,
    MAX(data_operacao) as ultima_operacao
FROM auditoria.pokemon_audit
GROUP BY operacao
ORDER BY tabela, operacao;

COMMENT ON VIEW relatorios.vw_auditoria_resumo IS 
'Resumo de operações de auditoria por tabela';

-- ============================================================================
-- 10. VIEW: Tipos Mais Comuns
-- ============================================================================

CREATE OR REPLACE VIEW relatorios.vw_tipos_estatisticas AS
SELECT 
    t.id,
    t.nome_pt,
    t.nome_en,
    t.cor,
    COUNT(DISTINCT pt.pokemon_id) as total_pokemon,
    ROUND(AVG(p.nivel), 2) as nivel_medio,
    COUNT(DISTINCT p.treinador_id) as total_treinadores,
    -- Pokémon mais forte deste tipo
    (SELECT p2.nome_pt
     FROM centro.pokemon p2
     JOIN centro.pokemon_tipo pt2 ON pt2.pokemon_id = p2.id
     WHERE pt2.tipo_id = t.id
     ORDER BY p2.nivel DESC, p2.experiencia DESC
     LIMIT 1) as pokemon_mais_forte
FROM centro.tipo t
LEFT JOIN centro.pokemon_tipo pt ON pt.tipo_id = t.id
LEFT JOIN centro.pokemon p ON p.id = pt.pokemon_id
GROUP BY t.id, t.nome_pt, t.nome_en, t.cor
ORDER BY total_pokemon DESC;

COMMENT ON VIEW relatorios.vw_tipos_estatisticas IS 
'Estatísticas de tipos pokémon mais comuns';

-- ============================================================================
-- RELATÓRIOS SQL PRONTOS
-- ============================================================================

-- Relatório 1: Top 10 Treinadores
CREATE OR REPLACE VIEW relatorios.vw_top10_treinadores AS
SELECT * FROM relatorios.vw_ranking_treinadores LIMIT 10;

-- Relatório 2: Consultas Pendentes
CREATE OR REPLACE VIEW relatorios.vw_consultas_pendentes AS
SELECT * FROM relatorios.vw_consultas_detalhadas
WHERE status IN ('AGENDADA', 'EM_ATENDIMENTO')
ORDER BY data_hora;

-- Relatório 3: Pokémon que Precisam de Cura
CREATE OR REPLACE VIEW relatorios.vw_pokemon_precisam_cura AS
SELECT * FROM relatorios.vw_pokemon_completo
WHERE vida_atual < vida_maxima
ORDER BY percentual_vida ASC;

-- ============================================================================
-- FIM DAS VIEWS E RELATÓRIOS
-- ============================================================================

-- Listar todas as views criadas
SELECT 
    schemaname,
    viewname,
    obj_description((schemaname || '.' || viewname)::regclass, 'pg_class') as descricao
FROM pg_views
WHERE schemaname = 'relatorios'
ORDER BY viewname;
