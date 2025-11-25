-- ============================================================================
-- CENTRO POKÉMON - TRIGGERS
-- Implementação de triggers para integridade e auditoria
-- ============================================================================

\c centro_pokemon;

SET search_path TO centro, public;

-- ============================================================================
-- 1. TRIGGER: Atualizar data_atualizacao do Treinador
-- ============================================================================

CREATE OR REPLACE FUNCTION centro.atualizar_data_modificacao()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_atualizacao = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_treinador_atualizar_data
    BEFORE UPDATE ON centro.treinador
    FOR EACH ROW
    EXECUTE FUNCTION centro.atualizar_data_modificacao();

COMMENT ON TRIGGER trg_treinador_atualizar_data ON centro.treinador IS 
'Atualiza automaticamente o campo data_atualizacao quando um treinador é modificado';

-- ============================================================================
-- 2. TRIGGER: Validar vida do Pokémon antes de inserir/atualizar
-- ============================================================================

CREATE OR REPLACE FUNCTION centro.validar_vida_pokemon()
RETURNS TRIGGER AS $$
BEGIN
    -- Garantir que vida_atual não exceda vida_maxima
    IF NEW.vida_atual > NEW.vida_maxima THEN
        NEW.vida_atual := NEW.vida_maxima;
    END IF;
    
    -- Garantir que vida_atual não seja negativa
    IF NEW.vida_atual < 0 THEN
        NEW.vida_atual := 0;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pokemon_validar_vida
    BEFORE INSERT OR UPDATE ON centro.pokemon
    FOR EACH ROW
    EXECUTE FUNCTION centro.validar_vida_pokemon();

COMMENT ON TRIGGER trg_pokemon_validar_vida ON centro.pokemon IS 
'Valida e ajusta automaticamente os valores de vida do Pokémon';

-- ============================================================================
-- 3. TRIGGER: Registrar histórico de cura automaticamente
-- ============================================================================

CREATE OR REPLACE FUNCTION centro.registrar_cura_automatica()
RETURNS TRIGGER AS $$
BEGIN
    -- Só registra se a vida aumentou
    IF NEW.vida_atual > OLD.vida_atual THEN
        INSERT INTO centro.historico_cura (
            pokemon_id,
            vida_antes,
            vida_depois,
            metodo
        ) VALUES (
            NEW.id,
            OLD.vida_atual,
            NEW.vida_atual,
            'CENTRO_POKEMON'
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pokemon_registrar_cura
    AFTER UPDATE ON centro.pokemon
    FOR EACH ROW
    WHEN (NEW.vida_atual > OLD.vida_atual)
    EXECUTE FUNCTION centro.registrar_cura_automatica();

COMMENT ON TRIGGER trg_pokemon_registrar_cura ON centro.pokemon IS 
'Registra automaticamente no histórico quando um Pokémon é curado';

-- ============================================================================
-- 4. TRIGGER: Auditoria de Treinadores
-- ============================================================================

CREATE OR REPLACE FUNCTION auditoria.auditar_treinador()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria.treinador_audit (
            treinador_id,
            operacao,
            usuario_db,
            dados_novos
        ) VALUES (
            NEW.id,
            'INSERT',
            current_user,
            row_to_json(NEW)
        );
        RETURN NEW;
        
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria.treinador_audit (
            treinador_id,
            operacao,
            usuario_db,
            dados_antigos,
            dados_novos
        ) VALUES (
            NEW.id,
            'UPDATE',
            current_user,
            row_to_json(OLD),
            row_to_json(NEW)
        );
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria.treinador_audit (
            treinador_id,
            operacao,
            usuario_db,
            dados_antigos
        ) VALUES (
            OLD.id,
            'DELETE',
            current_user,
            row_to_json(OLD)
        );
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_treinador_auditoria
    AFTER INSERT OR UPDATE OR DELETE ON centro.treinador
    FOR EACH ROW
    EXECUTE FUNCTION auditoria.auditar_treinador();

COMMENT ON TRIGGER trg_treinador_auditoria ON centro.treinador IS 
'Registra todas as operações (INSERT, UPDATE, DELETE) na tabela de auditoria';

-- ============================================================================
-- 5. TRIGGER: Auditoria de Pokémon
-- ============================================================================

CREATE OR REPLACE FUNCTION auditoria.auditar_pokemon()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria.pokemon_audit (
            pokemon_id,
            operacao,
            usuario_db,
            dados_novos
        ) VALUES (
            NEW.id,
            'INSERT',
            current_user,
            row_to_json(NEW)
        );
        RETURN NEW;
        
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria.pokemon_audit (
            pokemon_id,
            operacao,
            usuario_db,
            dados_antigos,
            dados_novos
        ) VALUES (
            NEW.id,
            'UPDATE',
            current_user,
            row_to_json(OLD),
            row_to_json(NEW)
        );
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria.pokemon_audit (
            pokemon_id,
            operacao,
            usuario_db,
            dados_antigos
        ) VALUES (
            OLD.id,
            'DELETE',
            current_user,
            row_to_json(OLD)
        );
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pokemon_auditoria
    AFTER INSERT OR UPDATE OR DELETE ON centro.pokemon
    FOR EACH ROW
    EXECUTE FUNCTION auditoria.auditar_pokemon();

COMMENT ON TRIGGER trg_pokemon_auditoria ON centro.pokemon IS 
'Registra todas as operações (INSERT, UPDATE, DELETE) na tabela de auditoria de pokémon';

-- ============================================================================
-- 6. TRIGGER: Validar horário de consulta
-- ============================================================================

CREATE OR REPLACE FUNCTION centro.validar_horario_consulta()
RETURNS TRIGGER AS $$
DECLARE
    conflito INTEGER;
BEGIN
    -- Verificar se já existe consulta no mesmo horário para o mesmo pokémon
    SELECT COUNT(*) INTO conflito
    FROM centro.consulta
    WHERE pokemon_id = NEW.pokemon_id
      AND status IN ('AGENDADA', 'EM_ATENDIMENTO')
      AND id != COALESCE(NEW.id, 0)
      AND ABS(EXTRACT(EPOCH FROM (data_hora - NEW.data_hora))) < 3600; -- 1 hora
    
    IF conflito > 0 THEN
        RAISE EXCEPTION 'Já existe uma consulta agendada para este Pokémon no horário próximo';
    END IF;
    
    -- Validar que a consulta não é no passado (exceto para updates)
    IF TG_OP = 'INSERT' AND NEW.data_hora < CURRENT_TIMESTAMP THEN
        RAISE EXCEPTION 'Não é possível agendar consulta no passado';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_consulta_validar_horario
    BEFORE INSERT OR UPDATE ON centro.consulta
    FOR EACH ROW
    EXECUTE FUNCTION centro.validar_horario_consulta();

COMMENT ON TRIGGER trg_consulta_validar_horario ON centro.consulta IS 
'Valida horários de consulta evitando conflitos e agendamentos no passado';

-- ============================================================================
-- 7. TRIGGER: Atualizar status da consulta automaticamente
-- ============================================================================

CREATE OR REPLACE FUNCTION centro.atualizar_status_consulta()
RETURNS TRIGGER AS $$
BEGIN
    -- Se data_conclusao foi preenchida, marcar como CONCLUIDA
    IF NEW.data_conclusao IS NOT NULL AND OLD.data_conclusao IS NULL THEN
        NEW.status := 'CONCLUIDA';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_consulta_atualizar_status
    BEFORE UPDATE ON centro.consulta
    FOR EACH ROW
    WHEN (NEW.data_conclusao IS NOT NULL AND OLD.data_conclusao IS NULL)
    EXECUTE FUNCTION centro.atualizar_status_consulta();

COMMENT ON TRIGGER trg_consulta_atualizar_status ON centro.consulta IS 
'Atualiza automaticamente o status da consulta quando é concluída';

-- ============================================================================
-- 8. TRIGGER: Prevenir exclusão de Pokémon com consultas ativas
-- ============================================================================

CREATE OR REPLACE FUNCTION centro.prevenir_exclusao_pokemon_com_consulta()
RETURNS TRIGGER AS $$
DECLARE
    consultas_ativas INTEGER;
BEGIN
    -- Verificar se existem consultas ativas
    SELECT COUNT(*) INTO consultas_ativas
    FROM centro.consulta
    WHERE pokemon_id = OLD.id
      AND status IN ('AGENDADA', 'EM_ATENDIMENTO');
    
    IF consultas_ativas > 0 THEN
        RAISE EXCEPTION 'Não é possível excluir Pokémon com consultas ativas. Cancele as consultas primeiro.';
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pokemon_prevenir_exclusao
    BEFORE DELETE ON centro.pokemon
    FOR EACH ROW
    EXECUTE FUNCTION centro.prevenir_exclusao_pokemon_com_consulta();

COMMENT ON TRIGGER trg_pokemon_prevenir_exclusao ON centro.pokemon IS 
'Previne a exclusão de Pokémon que possuem consultas ativas';

-- ============================================================================
-- 9. TRIGGER: Calcular experiência baseada no nível
-- ============================================================================

CREATE OR REPLACE FUNCTION centro.calcular_experiencia()
RETURNS TRIGGER AS $$
BEGIN
    -- Se o nível mudou, recalcular experiência mínima
    IF TG_OP = 'INSERT' OR NEW.nivel != OLD.nivel THEN
        -- Fórmula simplificada: exp = nivel^3
        IF NEW.experiencia < (NEW.nivel * NEW.nivel * NEW.nivel) THEN
            NEW.experiencia := NEW.nivel * NEW.nivel * NEW.nivel;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pokemon_calcular_experiencia
    BEFORE INSERT OR UPDATE ON centro.pokemon
    FOR EACH ROW
    EXECUTE FUNCTION centro.calcular_experiencia();

COMMENT ON TRIGGER trg_pokemon_calcular_experiencia ON centro.pokemon IS 
'Garante que a experiência do Pokémon seja consistente com seu nível';

-- ============================================================================
-- 10. TRIGGER: Notificar quando Pokémon está com vida crítica
-- ============================================================================

CREATE OR REPLACE FUNCTION centro.notificar_vida_critica()
RETURNS TRIGGER AS $$
DECLARE
    percentual_vida NUMERIC;
BEGIN
    percentual_vida := (NEW.vida_atual::NUMERIC / NEW.vida_maxima::NUMERIC) * 100;
    
    -- Se vida está abaixo de 20%, criar notificação
    IF percentual_vida < 20 AND percentual_vida < (OLD.vida_atual::NUMERIC / OLD.vida_maxima::NUMERIC) * 100 THEN
        -- Aqui poderia inserir em uma tabela de notificações
        RAISE NOTICE 'ALERTA: Pokémon % (ID: %) está com vida crítica: %/%', 
            NEW.nome_pt, NEW.id, NEW.vida_atual, NEW.vida_maxima;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pokemon_notificar_vida_critica
    AFTER UPDATE ON centro.pokemon
    FOR EACH ROW
    WHEN (NEW.vida_atual < OLD.vida_atual)
    EXECUTE FUNCTION centro.notificar_vida_critica();

COMMENT ON TRIGGER trg_pokemon_notificar_vida_critica ON centro.pokemon IS 
'Emite notificação quando a vida do Pokémon atinge nível crítico';

-- ============================================================================
-- FIM DOS TRIGGERS
-- ============================================================================

-- Listar todos os triggers criados
SELECT 
    schemaname,
    tablename,
    triggername,
    obj_description(oid, 'pg_trigger') as descricao
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname IN ('centro', 'auditoria')
  AND NOT tgisinternal
ORDER BY schemaname, tablename, triggername;
