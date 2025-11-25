-- ============================================================================
-- CENTRO POKÉMON - TESTES E VALIDAÇÃO
-- Scripts para testar todas as funcionalidades do banco
-- ============================================================================

\c centro_pokemon;

SET search_path TO centro, relatorios, public;

\echo '============================================================================'
\echo 'CENTRO POKÉMON - SUITE DE TESTES'
\echo '============================================================================'
\echo ''

-- ============================================================================
-- 1. TESTES DE TRIGGERS
-- ============================================================================

\echo '1. TESTANDO TRIGGERS...'
\echo ''

-- Teste 1.1: Trigger de atualização de data
\echo '  1.1 Testando atualização automática de data_atualizacao...'
UPDATE centro.treinador SET nome = 'Ash Ketchum Updated' WHERE usuario = 'ash';
SELECT 
    CASE 
        WHEN data_atualizacao > data_cadastro THEN '  ✓ PASSOU: data_atualizacao foi atualizada'
        ELSE '  ✗ FALHOU: data_atualizacao não foi atualizada'
    END as resultado
FROM centro.treinador WHERE usuario = 'ash';

-- Teste 1.2: Trigger de validação de vida
\echo '  1.2 Testando validação de vida do pokémon...'
UPDATE centro.pokemon SET vida_atual = 999 WHERE id = 1;
SELECT 
    CASE 
        WHEN vida_atual <= vida_maxima THEN '  ✓ PASSOU: Vida foi ajustada automaticamente'
        ELSE '  ✗ FALHOU: Vida excedeu o máximo'
    END as resultado
FROM centro.pokemon WHERE id = 1;

-- Teste 1.3: Trigger de registro de cura
\echo '  1.3 Testando registro automático de cura...'
DO $$
DECLARE
    v_count_antes INTEGER;
    v_count_depois INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count_antes FROM centro.historico_cura;
    UPDATE centro.pokemon SET vida_atual = vida_maxima WHERE id = 1;
    SELECT COUNT(*) INTO v_count_depois FROM centro.historico_cura;
    
    IF v_count_depois > v_count_antes THEN
        RAISE NOTICE '  ✓ PASSOU: Cura foi registrada no histórico';
    ELSE
        RAISE NOTICE '  ✗ FALHOU: Cura não foi registrada';
    END IF;
END $$;

-- Teste 1.4: Trigger de auditoria
\echo '  1.4 Testando auditoria de operações...'
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count 
    FROM auditoria.treinador_audit 
    WHERE treinador_id = (SELECT id FROM centro.treinador WHERE usuario = 'ash' LIMIT 1);
    
    IF v_count > 0 THEN
        RAISE NOTICE '  ✓ PASSOU: Operações foram auditadas';
    ELSE
        RAISE NOTICE '  ✗ FALHOU: Auditoria não está funcionando';
    END IF;
END $$;

\echo ''

-- ============================================================================
-- 2. TESTES DE STORED PROCEDURES
-- ============================================================================

\echo '2. TESTANDO STORED PROCEDURES...'
\echo ''

-- Teste 2.1: Curar pokémon
\echo '  2.1 Testando procedure curar_pokemon...'
DO $$
DECLARE
    v_vida_antes INTEGER;
    v_vida_depois INTEGER;
BEGIN
    -- Reduzir vida
    UPDATE centro.pokemon SET vida_atual = 50 WHERE id = 1;
    SELECT vida_atual INTO v_vida_antes FROM centro.pokemon WHERE id = 1;
    
    -- Curar
    CALL centro.curar_pokemon(1, 'CENTRO_POKEMON');
    SELECT vida_atual INTO v_vida_depois FROM centro.pokemon WHERE id = 1;
    
    IF v_vida_depois > v_vida_antes THEN
        RAISE NOTICE '  ✓ PASSOU: Pokémon foi curado (% -> %)', v_vida_antes, v_vida_depois;
    ELSE
        RAISE NOTICE '  ✗ FALHOU: Pokémon não foi curado';
    END IF;
END $$;

-- Teste 2.2: Agendar consulta
\echo '  2.2 Testando procedure agendar_consulta...'
DO $$
DECLARE
    v_consulta_id BIGINT;
BEGIN
    CALL centro.agendar_consulta(
        1, -- treinador_id
        1, -- pokemon_id
        'CHECKUP',
        CURRENT_TIMESTAMP + INTERVAL '3 days',
        'Teste de consulta',
        v_consulta_id
    );
    
    IF v_consulta_id IS NOT NULL THEN
        RAISE NOTICE '  ✓ PASSOU: Consulta agendada com ID %', v_consulta_id;
    ELSE
        RAISE NOTICE '  ✗ FALHOU: Consulta não foi agendada';
    END IF;
END $$;

-- Teste 2.3: Concluir consulta
\echo '  2.3 Testando procedure concluir_consulta...'
DO $$
DECLARE
    v_consulta_id BIGINT;
    v_status VARCHAR(20);
BEGIN
    -- Pegar última consulta agendada
    SELECT id INTO v_consulta_id 
    FROM centro.consulta 
    WHERE status = 'AGENDADA' 
    ORDER BY id DESC 
    LIMIT 1;
    
    IF v_consulta_id IS NOT NULL THEN
        CALL centro.concluir_consulta(v_consulta_id, 'Teste de conclusão');
        SELECT status INTO v_status FROM centro.consulta WHERE id = v_consulta_id;
        
        IF v_status = 'CONCLUIDA' THEN
            RAISE NOTICE '  ✓ PASSOU: Consulta concluída com sucesso';
        ELSE
            RAISE NOTICE '  ✗ FALHOU: Status não foi atualizado';
        END IF;
    ELSE
        RAISE NOTICE '  ⚠ AVISO: Nenhuma consulta agendada para testar';
    END IF;
END $$;

-- Teste 2.4: Subir nível
\echo '  2.4 Testando procedure subir_nivel_pokemon...'
DO $$
DECLARE
    v_nivel_antes INTEGER;
    v_nivel_depois INTEGER;
BEGIN
    SELECT nivel INTO v_nivel_antes FROM centro.pokemon WHERE id = 1;
    CALL centro.subir_nivel_pokemon(1, 1);
    SELECT nivel INTO v_nivel_depois FROM centro.pokemon WHERE id = 1;
    
    IF v_nivel_depois > v_nivel_antes THEN
        RAISE NOTICE '  ✓ PASSOU: Pokémon subiu de nível (% -> %)', v_nivel_antes, v_nivel_depois;
    ELSE
        RAISE NOTICE '  ✗ FALHOU: Nível não foi atualizado';
    END IF;
END $$;

-- Teste 2.5: Estatísticas do treinador
\echo '  2.5 Testando procedure gerar_estatisticas_treinador...'
DO $$
DECLARE
    v_total_pokemon INTEGER;
    v_nivel_medio NUMERIC;
    v_total_consultas INTEGER;
    v_total_curas INTEGER;
    v_pokemon_mais_forte VARCHAR(100);
BEGIN
    CALL centro.gerar_estatisticas_treinador(
        1,
        v_total_pokemon,
        v_nivel_medio,
        v_total_consultas,
        v_total_curas,
        v_pokemon_mais_forte
    );
    
    IF v_total_pokemon IS NOT NULL THEN
        RAISE NOTICE '  ✓ PASSOU: Estatísticas geradas';
        RAISE NOTICE '    - Total Pokémon: %', v_total_pokemon;
        RAISE NOTICE '    - Nível Médio: %', v_nivel_medio;
        RAISE NOTICE '    - Total Consultas: %', v_total_consultas;
        RAISE NOTICE '    - Total Curas: %', v_total_curas;
        RAISE NOTICE '    - Mais Forte: %', v_pokemon_mais_forte;
    ELSE
        RAISE NOTICE '  ✗ FALHOU: Estatísticas não foram geradas';
    END IF;
END $$;

\echo ''

-- ============================================================================
-- 3. TESTES DE VIEWS
-- ============================================================================

\echo '3. TESTANDO VIEWS...'
\echo ''

-- Teste 3.1: View de pokémon completo
\echo '  3.1 Testando vw_pokemon_completo...'
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM relatorios.vw_pokemon_completo;
    
    IF v_count > 0 THEN
        RAISE NOTICE '  ✓ PASSOU: View retornou % registros', v_count;
    ELSE
        RAISE NOTICE '  ✗ FALHOU: View não retornou dados';
    END IF;
END $$;

-- Teste 3.2: View de consultas detalhadas
\echo '  3.2 Testando vw_consultas_detalhadas...'
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM relatorios.vw_consultas_detalhadas;
    
    IF v_count > 0 THEN
        RAISE NOTICE '  ✓ PASSOU: View retornou % registros', v_count;
    ELSE
        RAISE NOTICE '  ⚠ AVISO: View não retornou dados (pode ser normal)';
    END IF;
END $$;

-- Teste 3.3: View de estatísticas
\echo '  3.3 Testando vw_estatisticas_treinador...'
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM relatorios.vw_estatisticas_treinador;
    
    IF v_count > 0 THEN
        RAISE NOTICE '  ✓ PASSOU: View retornou % registros', v_count;
    ELSE
        RAISE NOTICE '  ✗ FALHOU: View não retornou dados';
    END IF;
END $$;

-- Teste 3.4: View de ranking
\echo '  3.4 Testando vw_ranking_treinadores...'
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM relatorios.vw_ranking_treinadores;
    
    IF v_count > 0 THEN
        RAISE NOTICE '  ✓ PASSOU: View retornou % registros', v_count;
    ELSE
        RAISE NOTICE '  ✗ FALHOU: View não retornou dados';
    END IF;
END $$;

\echo ''

-- ============================================================================
-- 4. TESTES DE CONSTRAINTS
-- ============================================================================

\echo '4. TESTANDO CONSTRAINTS...'
\echo ''

-- Teste 4.1: Constraint de email único
\echo '  4.1 Testando constraint de email único...'
DO $$
BEGIN
    INSERT INTO centro.treinador (nome, usuario, email, senha)
    VALUES ('Teste', 'teste_unique', 'ash@pokemon.com', 'senha123');
    RAISE NOTICE '  ✗ FALHOU: Constraint de email único não funcionou';
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE '  ✓ PASSOU: Constraint de email único funcionou';
END $$;

-- Teste 4.2: Constraint de vida válida
\echo '  4.2 Testando constraint de vida válida...'
DO $$
BEGIN
    INSERT INTO centro.pokemon (treinador_id, poke_api_id, nome_pt, nome_en, vida_atual, vida_maxima, nivel)
    VALUES (1, 999, 'Teste', 'Test', -10, 100, 5);
    RAISE NOTICE '  ✗ FALHOU: Constraint de vida válida não funcionou';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE '  ✓ PASSOU: Constraint de vida válida funcionou';
END $$;

-- Teste 4.3: Constraint de nível válido
\echo '  4.3 Testando constraint de nível válido...'
DO $$
BEGIN
    INSERT INTO centro.pokemon (treinador_id, poke_api_id, nome_pt, nome_en, vida_atual, vida_maxima, nivel)
    VALUES (1, 999, 'Teste', 'Test', 100, 100, 150);
    RAISE NOTICE '  ✗ FALHOU: Constraint de nível válido não funcionou';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE '  ✓ PASSOU: Constraint de nível válido funcionou';
END $$;

-- Teste 4.4: Foreign key constraint
\echo '  4.4 Testando foreign key constraint...'
DO $$
BEGIN
    INSERT INTO centro.pokemon (treinador_id, poke_api_id, nome_pt, nome_en, vida_atual, vida_maxima, nivel)
    VALUES (99999, 1, 'Teste', 'Test', 100, 100, 5);
    RAISE NOTICE '  ✗ FALHOU: Foreign key constraint não funcionou';
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE '  ✓ PASSOU: Foreign key constraint funcionou';
END $$;

\echo ''

-- ============================================================================
-- 5. TESTES DE ÍNDICES
-- ============================================================================

\echo '5. TESTANDO ÍNDICES...'
\echo ''

-- Teste 5.1: Verificar existência de índices
\echo '  5.1 Verificando índices criados...'
SELECT 
    CASE 
        WHEN COUNT(*) >= 15 THEN '  ✓ PASSOU: ' || COUNT(*) || ' índices encontrados'
        ELSE '  ⚠ AVISO: Apenas ' || COUNT(*) || ' índices encontrados'
    END as resultado
FROM pg_indexes
WHERE schemaname IN ('centro', 'auditoria');

-- Teste 5.2: Performance de consulta com índice
\echo '  5.2 Testando performance com índice...'
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM centro.pokemon WHERE treinador_id = 1;

\echo ''

-- ============================================================================
-- 6. TESTES DE SEGURANÇA (RLS)
-- ============================================================================

\echo '6. TESTANDO ROW LEVEL SECURITY...'
\echo ''

-- Teste 6.1: Verificar RLS habilitado
\echo '  6.1 Verificando RLS habilitado...'
SELECT 
    CASE 
        WHEN COUNT(*) >= 3 THEN '  ✓ PASSOU: RLS habilitado em ' || COUNT(*) || ' tabelas'
        ELSE '  ⚠ AVISO: RLS habilitado em apenas ' || COUNT(*) || ' tabelas'
    END as resultado
FROM pg_tables
WHERE schemaname = 'centro' AND rowsecurity = true;

-- Teste 6.2: Verificar políticas criadas
\echo '  6.2 Verificando políticas RLS...'
SELECT 
    CASE 
        WHEN COUNT(*) >= 10 THEN '  ✓ PASSOU: ' || COUNT(*) || ' políticas criadas'
        ELSE '  ⚠ AVISO: Apenas ' || COUNT(*) || ' políticas criadas'
    END as resultado
FROM pg_policies
WHERE schemaname = 'centro';

\echo ''

-- ============================================================================
-- 7. TESTES DE INTEGRIDADE
-- ============================================================================

\echo '7. TESTANDO INTEGRIDADE DO BANCO...'
\echo ''

CALL centro.verificar_integridade(NULL, NULL);

\echo ''

-- ============================================================================
-- 8. RELATÓRIO FINAL
-- ============================================================================

\echo '============================================================================'
\echo 'RELATÓRIO FINAL DE TESTES'
\echo '============================================================================'
\echo ''

-- Estatísticas gerais
SELECT '📊 ESTATÍSTICAS GERAIS' as secao;
\echo ''

SELECT 'Treinadores cadastrados: ' || COUNT(*) as info FROM centro.treinador
UNION ALL
SELECT 'Pokémon cadastrados: ' || COUNT(*) FROM centro.pokemon
UNION ALL
SELECT 'Consultas agendadas: ' || COUNT(*) FROM centro.consulta
UNION ALL
SELECT 'Curas realizadas: ' || COUNT(*) FROM centro.historico_cura
UNION ALL
SELECT 'Registros de auditoria: ' || COUNT(*) FROM auditoria.treinador_audit;

\echo ''
SELECT '🔧 OBJETOS DO BANCO' as secao;
\echo ''

SELECT 'Tabelas: ' || COUNT(*) as info
FROM pg_tables WHERE schemaname IN ('centro', 'auditoria')
UNION ALL
SELECT 'Views: ' || COUNT(*) 
FROM pg_views WHERE schemaname = 'relatorios'
UNION ALL
SELECT 'Triggers: ' || COUNT(*) 
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname IN ('centro', 'auditoria') AND NOT t.tgisinternal
UNION ALL
SELECT 'Procedures: ' || COUNT(*) 
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'centro' AND p.prokind = 'p'
UNION ALL
SELECT 'Índices: ' || COUNT(*) 
FROM pg_indexes WHERE schemaname IN ('centro', 'auditoria');

\echo ''
SELECT '👥 USUÁRIOS E SEGURANÇA' as secao;
\echo ''

SELECT 'Roles criados: ' || COUNT(*) as info
FROM pg_roles WHERE rolname LIKE '%centro_pokemon%'
UNION ALL
SELECT 'Usuários criados: ' || COUNT(*) 
FROM pg_roles WHERE rolname IN ('admin_master', 'enfermeira_joy', 'enfermeira_chansey', 'app_backend', 'relatorio_bi')
UNION ALL
SELECT 'Políticas RLS: ' || COUNT(*) 
FROM pg_policies WHERE schemaname = 'centro';

\echo ''
\echo '============================================================================'
\echo 'TESTES CONCLUÍDOS!'
\echo '============================================================================'
\echo ''
\echo 'Verifique os resultados acima.'
\echo 'Todos os testes marcados com ✓ passaram com sucesso.'
\echo 'Testes marcados com ✗ falharam e precisam de atenção.'
\echo 'Avisos marcados com ⚠ são informativos.'
\echo ''
