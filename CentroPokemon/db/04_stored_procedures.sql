-- ============================================================================
-- CENTRO POKÉMON - STORED PROCEDURES
-- Implementação de procedures para regras de negócio
-- ============================================================================

\c centro_pokemon;

SET search_path TO centro, public;

-- ============================================================================
-- 1. PROCEDURE: Curar Pokémon Completamente
-- ============================================================================

CREATE OR REPLACE PROCEDURE centro.curar_pokemon(
    p_pokemon_id BIGINT,
    p_metodo VARCHAR(50) DEFAULT 'CENTRO_POKEMON'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_vida_antes INTEGER;
    v_vida_maxima INTEGER;
BEGIN
    -- Buscar vida atual
    SELECT vida_atual, vida_maxima 
    INTO v_vida_antes, v_vida_maxima
    FROM centro.pokemon
    WHERE id = p_pokemon_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pokémon com ID % não encontrado', p_pokemon_id;
    END IF;
    
    -- Curar completamente
    UPDATE centro.pokemon
    SET vida_atual = vida_maxima
    WHERE id = p_pokemon_id;
    
    -- Registrar no histórico (trigger já faz isso, mas podemos forçar o método)
    INSERT INTO centro.historico_cura (pokemon_id, vida_antes, vida_depois, metodo)
    VALUES (p_pokemon_id, v_vida_antes, v_vida_maxima, p_metodo);
    
    RAISE NOTICE 'Pokémon ID % curado: % -> % HP', p_pokemon_id, v_vida_antes, v_vida_maxima;
END;
$$;

COMMENT ON PROCEDURE centro.curar_pokemon IS 
'Cura um Pokémon completamente e registra no histórico';

-- ============================================================================
-- 2. PROCEDURE: Curar Todos os Pokémon de um Treinador
-- ============================================================================

CREATE OR REPLACE PROCEDURE centro.curar_todos_pokemon_treinador(
    p_treinador_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_pokemon RECORD;
    v_total_curados INTEGER := 0;
BEGIN
    -- Verificar se treinador existe
    IF NOT EXISTS (SELECT 1 FROM centro.treinador WHERE id = p_treinador_id) THEN
        RAISE EXCEPTION 'Treinador com ID % não encontrado', p_treinador_id;
    END IF;
    
    -- Curar cada pokémon
    FOR v_pokemon IN 
        SELECT id, nome_pt, vida_atual, vida_maxima
        FROM centro.pokemon
        WHERE treinador_id = p_treinador_id
          AND vida_atual < vida_maxima
    LOOP
        CALL centro.curar_pokemon(v_pokemon.id, 'CENTRO_POKEMON');
        v_total_curados := v_total_curados + 1;
    END LOOP;
    
    RAISE NOTICE 'Total de % Pokémon curados para o treinador ID %', v_total_curados, p_treinador_id;
END;
$$;

COMMENT ON PROCEDURE centro.curar_todos_pokemon_treinador IS 
'Cura todos os Pokémon de um treinador que estejam feridos';

-- ============================================================================
-- 3. PROCEDURE: Agendar Consulta com Validações
-- ============================================================================

CREATE OR REPLACE PROCEDURE centro.agendar_consulta(
    p_treinador_id BIGINT,
    p_pokemon_id BIGINT,
    p_tipo_consulta VARCHAR(50),
    p_data_hora TIMESTAMP,
    p_observacoes TEXT DEFAULT NULL,
    OUT p_consulta_id BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar treinador
    IF NOT EXISTS (SELECT 1 FROM centro.treinador WHERE id = p_treinador_id) THEN
        RAISE EXCEPTION 'Treinador com ID % não encontrado', p_treinador_id;
    END IF;
    
    -- Validar pokémon
    IF NOT EXISTS (SELECT 1 FROM centro.pokemon WHERE id = p_pokemon_id AND treinador_id = p_treinador_id) THEN
        RAISE EXCEPTION 'Pokémon com ID % não encontrado ou não pertence ao treinador', p_pokemon_id;
    END IF;
    
    -- Validar tipo de consulta
    IF p_tipo_consulta NOT IN ('CONSULTA', 'VACINACAO', 'CHECKUP', 'EMERGENCIA') THEN
        RAISE EXCEPTION 'Tipo de consulta inválido: %', p_tipo_consulta;
    END IF;
    
    -- Validar data futura
    IF p_data_hora < CURRENT_TIMESTAMP THEN
        RAISE EXCEPTION 'Data da consulta deve ser no futuro';
    END IF;
    
    -- Inserir consulta
    INSERT INTO centro.consulta (
        treinador_id,
        pokemon_id,
        tipo_consulta,
        data_hora,
        observacoes,
        status
    ) VALUES (
        p_treinador_id,
        p_pokemon_id,
        p_tipo_consulta,
        p_data_hora,
        p_observacoes,
        'AGENDADA'
    ) RETURNING id INTO p_consulta_id;
    
    RAISE NOTICE 'Consulta ID % agendada com sucesso para %', p_consulta_id, p_data_hora;
END;
$$;

COMMENT ON PROCEDURE centro.agendar_consulta IS 
'Agenda uma consulta com validações completas de negócio';

-- ============================================================================
-- 4. PROCEDURE: Concluir Consulta
-- ============================================================================

CREATE OR REPLACE PROCEDURE centro.concluir_consulta(
    p_consulta_id BIGINT,
    p_observacoes_finais TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR(20);
    v_pokemon_id BIGINT;
BEGIN
    -- Buscar consulta
    SELECT status, pokemon_id
    INTO v_status, v_pokemon_id
    FROM centro.consulta
    WHERE id = p_consulta_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Consulta com ID % não encontrada', p_consulta_id;
    END IF;
    
    IF v_status = 'CONCLUIDA' THEN
        RAISE EXCEPTION 'Consulta já foi concluída';
    END IF;
    
    IF v_status = 'CANCELADA' THEN
        RAISE EXCEPTION 'Consulta foi cancelada';
    END IF;
    
    -- Atualizar consulta
    UPDATE centro.consulta
    SET status = 'CONCLUIDA',
        data_conclusao = CURRENT_TIMESTAMP,
        observacoes = COALESCE(p_observacoes_finais, observacoes)
    WHERE id = p_consulta_id;
    
    -- Curar o pokémon automaticamente
    CALL centro.curar_pokemon(v_pokemon_id, 'CONSULTA');
    
    RAISE NOTICE 'Consulta ID % concluída com sucesso', p_consulta_id;
END;
$$;

COMMENT ON PROCEDURE centro.concluir_consulta IS 
'Conclui uma consulta e cura o Pokémon automaticamente';

-- ============================================================================
-- 5. PROCEDURE: Cancelar Consulta
-- ============================================================================

CREATE OR REPLACE PROCEDURE centro.cancelar_consulta(
    p_consulta_id BIGINT,
    p_motivo TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR(20);
BEGIN
    -- Buscar consulta
    SELECT status INTO v_status
    FROM centro.consulta
    WHERE id = p_consulta_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Consulta com ID % não encontrada', p_consulta_id;
    END IF;
    
    IF v_status = 'CONCLUIDA' THEN
        RAISE EXCEPTION 'Não é possível cancelar consulta já concluída';
    END IF;
    
    IF v_status = 'CANCELADA' THEN
        RAISE EXCEPTION 'Consulta já está cancelada';
    END IF;
    
    -- Cancelar consulta
    UPDATE centro.consulta
    SET status = 'CANCELADA',
        observacoes = COALESCE(observacoes || E'\n\nMotivo do cancelamento: ' || p_motivo, p_motivo)
    WHERE id = p_consulta_id;
    
    RAISE NOTICE 'Consulta ID % cancelada', p_consulta_id;
END;
$$;

COMMENT ON PROCEDURE centro.cancelar_consulta IS 
'Cancela uma consulta agendada';

-- ============================================================================
-- 6. PROCEDURE: Cadastrar Pokémon Completo
-- ============================================================================

CREATE OR REPLACE PROCEDURE centro.cadastrar_pokemon_completo(
    p_treinador_id BIGINT,
    p_poke_api_id INTEGER,
    p_nome_pt VARCHAR(100),
    p_nome_en VARCHAR(100),
    p_sprite_url TEXT,
    p_nivel INTEGER DEFAULT 5,
    p_tipos INTEGER[] DEFAULT NULL,
    p_habilidades INTEGER[] DEFAULT NULL,
    OUT p_pokemon_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_tipo_id INTEGER;
    v_habilidade_id INTEGER;
    v_vida_maxima INTEGER;
BEGIN
    -- Validar treinador
    IF NOT EXISTS (SELECT 1 FROM centro.treinador WHERE id = p_treinador_id) THEN
        RAISE EXCEPTION 'Treinador com ID % não encontrado', p_treinador_id;
    END IF;
    
    -- Calcular vida máxima baseada no nível (fórmula simplificada)
    v_vida_maxima := 50 + (p_nivel * 5);
    
    -- Inserir pokémon
    INSERT INTO centro.pokemon (
        treinador_id,
        poke_api_id,
        nome_pt,
        nome_en,
        sprite_url,
        vida_atual,
        vida_maxima,
        nivel,
        experiencia
    ) VALUES (
        p_treinador_id,
        p_poke_api_id,
        p_nome_pt,
        p_nome_en,
        p_sprite_url,
        v_vida_maxima,
        v_vida_maxima,
        p_nivel,
        p_nivel * p_nivel * p_nivel
    ) RETURNING id INTO p_pokemon_id;
    
    -- Adicionar tipos
    IF p_tipos IS NOT NULL THEN
        FOREACH v_tipo_id IN ARRAY p_tipos
        LOOP
            INSERT INTO centro.pokemon_tipo (pokemon_id, tipo_id)
            VALUES (p_pokemon_id, v_tipo_id);
        END LOOP;
    END IF;
    
    -- Adicionar habilidades
    IF p_habilidades IS NOT NULL THEN
        FOREACH v_habilidade_id IN ARRAY p_habilidades
        LOOP
            INSERT INTO centro.pokemon_habilidade (pokemon_id, habilidade_id)
            VALUES (p_pokemon_id, v_habilidade_id);
        END LOOP;
    END IF;
    
    RAISE NOTICE 'Pokémon % (ID: %) cadastrado com sucesso', p_nome_pt, p_pokemon_id;
END;
$$;

COMMENT ON PROCEDURE centro.cadastrar_pokemon_completo IS 
'Cadastra um Pokémon com todos os seus relacionamentos (tipos e habilidades)';

-- ============================================================================
-- 7. PROCEDURE: Aplicar Dano ao Pokémon
-- ============================================================================

CREATE OR REPLACE PROCEDURE centro.aplicar_dano_pokemon(
    p_pokemon_id BIGINT,
    p_dano INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_vida_atual INTEGER;
    v_nova_vida INTEGER;
BEGIN
    -- Buscar vida atual
    SELECT vida_atual INTO v_vida_atual
    FROM centro.pokemon
    WHERE id = p_pokemon_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pokémon com ID % não encontrado', p_pokemon_id;
    END IF;
    
    -- Calcular nova vida
    v_nova_vida := GREATEST(0, v_vida_atual - p_dano);
    
    -- Atualizar vida
    UPDATE centro.pokemon
    SET vida_atual = v_nova_vida
    WHERE id = p_pokemon_id;
    
    IF v_nova_vida = 0 THEN
        RAISE NOTICE 'Pokémon ID % foi derrotado!', p_pokemon_id;
    ELSE
        RAISE NOTICE 'Pokémon ID % recebeu % de dano. Vida: %', p_pokemon_id, p_dano, v_nova_vida;
    END IF;
END;
$$;

COMMENT ON PROCEDURE centro.aplicar_dano_pokemon IS 
'Aplica dano a um Pokémon, reduzindo sua vida atual';

-- ============================================================================
-- 8. PROCEDURE: Subir Nível do Pokémon
-- ============================================================================

CREATE OR REPLACE PROCEDURE centro.subir_nivel_pokemon(
    p_pokemon_id BIGINT,
    p_niveis INTEGER DEFAULT 1
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_nivel_atual INTEGER;
    v_novo_nivel INTEGER;
    v_vida_maxima_atual INTEGER;
    v_nova_vida_maxima INTEGER;
BEGIN
    -- Buscar dados atuais
    SELECT nivel, vida_maxima
    INTO v_nivel_atual, v_vida_maxima_atual
    FROM centro.pokemon
    WHERE id = p_pokemon_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pokémon com ID % não encontrado', p_pokemon_id;
    END IF;
    
    -- Calcular novo nível (máximo 100)
    v_novo_nivel := LEAST(100, v_nivel_atual + p_niveis);
    
    -- Calcular nova vida máxima
    v_nova_vida_maxima := 50 + (v_novo_nivel * 5);
    
    -- Atualizar pokémon
    UPDATE centro.pokemon
    SET nivel = v_novo_nivel,
        vida_maxima = v_nova_vida_maxima,
        vida_atual = vida_atual + (v_nova_vida_maxima - v_vida_maxima_atual), -- Aumenta vida proporcional
        experiencia = v_novo_nivel * v_novo_nivel * v_novo_nivel
    WHERE id = p_pokemon_id;
    
    RAISE NOTICE 'Pokémon ID % subiu do nível % para %!', p_pokemon_id, v_nivel_atual, v_novo_nivel;
END;
$$;

COMMENT ON PROCEDURE centro.subir_nivel_pokemon IS 
'Aumenta o nível de um Pokémon e ajusta seus atributos';

-- ============================================================================
-- 9. PROCEDURE: Limpar Consultas Antigas
-- ============================================================================

CREATE OR REPLACE PROCEDURE centro.limpar_consultas_antigas(
    p_dias_atras INTEGER DEFAULT 90
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_removidas INTEGER;
BEGIN
    -- Remover consultas concluídas ou canceladas antigas
    WITH deleted AS (
        DELETE FROM centro.consulta
        WHERE status IN ('CONCLUIDA', 'CANCELADA')
          AND data_hora < CURRENT_TIMESTAMP - (p_dias_atras || ' days')::INTERVAL
        RETURNING id
    )
    SELECT COUNT(*) INTO v_total_removidas FROM deleted;
    
    RAISE NOTICE 'Total de % consultas antigas removidas', v_total_removidas;
END;
$$;

COMMENT ON PROCEDURE centro.limpar_consultas_antigas IS 
'Remove consultas concluídas ou canceladas com mais de X dias';

-- ============================================================================
-- 10. PROCEDURE: Estatísticas do Treinador
-- ============================================================================

CREATE OR REPLACE PROCEDURE centro.gerar_estatisticas_treinador(
    p_treinador_id BIGINT,
    OUT p_total_pokemon INTEGER,
    OUT p_nivel_medio NUMERIC,
    OUT p_total_consultas INTEGER,
    OUT p_total_curas INTEGER,
    OUT p_pokemon_mais_forte VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Total de pokémon
    SELECT COUNT(*)
    INTO p_total_pokemon
    FROM centro.pokemon
    WHERE treinador_id = p_treinador_id;
    
    -- Nível médio
    SELECT ROUND(AVG(nivel), 2)
    INTO p_nivel_medio
    FROM centro.pokemon
    WHERE treinador_id = p_treinador_id;
    
    -- Total de consultas
    SELECT COUNT(*)
    INTO p_total_consultas
    FROM centro.consulta
    WHERE treinador_id = p_treinador_id;
    
    -- Total de curas
    SELECT COUNT(*)
    INTO p_total_curas
    FROM centro.historico_cura hc
    JOIN centro.pokemon p ON p.id = hc.pokemon_id
    WHERE p.treinador_id = p_treinador_id;
    
    -- Pokémon mais forte (maior nível)
    SELECT nome_pt
    INTO p_pokemon_mais_forte
    FROM centro.pokemon
    WHERE treinador_id = p_treinador_id
    ORDER BY nivel DESC, experiencia DESC
    LIMIT 1;
END;
$$;

COMMENT ON PROCEDURE centro.gerar_estatisticas_treinador IS 
'Gera estatísticas completas de um treinador';

-- ============================================================================
-- FIM DAS STORED PROCEDURES
-- ============================================================================

-- Listar todas as procedures criadas
SELECT 
    n.nspname as schema,
    p.proname as nome,
    pg_get_function_arguments(p.oid) as parametros,
    obj_description(p.oid, 'pg_proc') as descricao
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'centro'
  AND p.prokind = 'p'
ORDER BY p.proname;
