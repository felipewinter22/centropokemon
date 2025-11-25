-- ============================================================================
-- CENTRO POKÉMON - BACKUP E RESTORE
-- Scripts e procedures para backup e restauração
-- ============================================================================

\c centro_pokemon;

SET search_path TO centro, public;

-- ============================================================================
-- 1. PROCEDURE: Backup Completo do Banco
-- ============================================================================

-- Nota: Esta procedure gera comandos que devem ser executados no shell
-- Para executar o backup real, use os comandos gerados

CREATE OR REPLACE PROCEDURE centro.gerar_comando_backup_completo(
    p_diretorio_destino TEXT DEFAULT '/backup/centro_pokemon'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_data_hora TEXT;
    v_arquivo TEXT;
    v_comando TEXT;
BEGIN
    -- Gerar timestamp para o arquivo
    v_data_hora := TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD_HH24MISS');
    v_arquivo := p_diretorio_destino || '/centro_pokemon_full_' || v_data_hora || '.backup';
    
    -- Gerar comando pg_dump
    v_comando := 'pg_dump -h localhost -U postgres -F c -b -v -f ' || v_arquivo || ' centro_pokemon';
    
    RAISE NOTICE '=== COMANDO DE BACKUP COMPLETO ===';
    RAISE NOTICE '%', v_comando;
    RAISE NOTICE '';
    RAISE NOTICE 'Execute este comando no terminal para realizar o backup.';
    RAISE NOTICE 'Arquivo de destino: %', v_arquivo;
END;
$$;

COMMENT ON PROCEDURE centro.gerar_comando_backup_completo IS 
'Gera o comando para realizar backup completo do banco de dados';

-- ============================================================================
-- 2. PROCEDURE: Backup Apenas dos Dados
-- ============================================================================

CREATE OR REPLACE PROCEDURE centro.gerar_comando_backup_dados(
    p_diretorio_destino TEXT DEFAULT '/backup/centro_pokemon'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_data_hora TEXT;
    v_arquivo TEXT;
    v_comando TEXT;
BEGIN
    v_data_hora := TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD_HH24MISS');
    v_arquivo := p_diretorio_destino || '/centro_pokemon_data_' || v_data_hora || '.sql';
    
    -- Backup apenas dos dados (sem schema)
    v_comando := 'pg_dump -h localhost -U postgres -a -f ' || v_arquivo || ' centro_pokemon';
    
    RAISE NOTICE '=== COMANDO DE BACKUP DE DADOS ===';
    RAISE NOTICE '%', v_comando;
    RAISE NOTICE '';
    RAISE NOTICE 'Execute este comando no terminal para realizar o backup dos dados.';
    RAISE NOTICE 'Arquivo de destino: %', v_arquivo;
END;
$$;

COMMENT ON PROCEDURE centro.gerar_comando_backup_dados IS 
'Gera o comando para realizar backup apenas dos dados';

-- ============================================================================
-- 3. PROCEDURE: Backup Apenas do Schema
-- ============================================================================

CREATE OR REPLACE PROCEDURE centro.gerar_comando_backup_schema(
    p_diretorio_destino TEXT DEFAULT '/backup/centro_pokemon'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_data_hora TEXT;
    v_arquivo TEXT;
    v_comando TEXT;
BEGIN
    v_data_hora := TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD_HH24MISS');
    v_arquivo := p_diretorio_destino || '/centro_pokemon_schema_' || v_data_hora || '.sql';
    
    -- Backup apenas do schema (sem dados)
    v_comando := 'pg_dump -h localhost -U postgres -s -f ' || v_arquivo || ' centro_pokemon';
    
    RAISE NOTICE '=== COMANDO DE BACKUP DE SCHEMA ===';
    RAISE NOTICE '%', v_comando;
    RAISE NOTICE '';
    RAISE NOTICE 'Execute este comando no terminal para realizar o backup do schema.';
    RAISE NOTICE 'Arquivo de destino: %', v_arquivo;
END;
$$;

COMMENT ON PROCEDURE centro.gerar_comando_backup_schema IS 
'Gera o comando para realizar backup apenas do schema';

-- ============================================================================
-- 4. PROCEDURE: Backup de Tabelas Específicas
-- ============================================================================

CREATE OR REPLACE PROCEDURE centro.gerar_comando_backup_tabelas(
    p_tabelas TEXT[],
    p_diretorio_destino TEXT DEFAULT '/backup/centro_pokemon'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_data_hora TEXT;
    v_arquivo TEXT;
    v_comando TEXT;
    v_tabela TEXT;
    v_lista_tabelas TEXT := '';
BEGIN
    v_data_hora := TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD_HH24MISS');
    v_arquivo := p_diretorio_destino || '/centro_pokemon_tables_' || v_data_hora || '.sql';
    
    -- Construir lista de tabelas
    FOREACH v_tabela IN ARRAY p_tabelas
    LOOP
        v_lista_tabelas := v_lista_tabelas || ' -t ' || v_tabela;
    END LOOP;
    
    v_comando := 'pg_dump -h localhost -U postgres' || v_lista_tabelas || ' -f ' || v_arquivo || ' centro_pokemon';
    
    RAISE NOTICE '=== COMANDO DE BACKUP DE TABELAS ESPECÍFICAS ===';
    RAISE NOTICE '%', v_comando;
    RAISE NOTICE '';
    RAISE NOTICE 'Tabelas: %', ARRAY_TO_STRING(p_tabelas, ', ');
    RAISE NOTICE 'Arquivo de destino: %', v_arquivo;
END;
$$;

COMMENT ON PROCEDURE centro.gerar_comando_backup_tabelas IS 
'Gera o comando para realizar backup de tabelas específicas';

-- ============================================================================
-- 5. PROCEDURE: Restore Completo
-- ============================================================================

CREATE OR REPLACE PROCEDURE centro.gerar_comando_restore_completo(
    p_arquivo_backup TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_comando TEXT;
BEGIN
    v_comando := 'pg_restore -h localhost -U postgres -d centro_pokemon -c -v ' || p_arquivo_backup;
    
    RAISE NOTICE '=== COMANDO DE RESTORE COMPLETO ===';
    RAISE NOTICE '%', v_comando;
    RAISE NOTICE '';
    RAISE NOTICE 'ATENÇÃO: Este comando irá LIMPAR (-c) e RESTAURAR o banco!';
    RAISE NOTICE 'Arquivo de origem: %', p_arquivo_backup;
    RAISE NOTICE '';
    RAISE NOTICE 'Para restore sem limpar dados existentes, remova a opção -c';
END;
$$;

COMMENT ON PROCEDURE centro.gerar_comando_restore_completo IS 
'Gera o comando para restaurar backup completo';

-- ============================================================================
-- 6. TABELA DE CONTROLE DE BACKUPS
-- ============================================================================

CREATE TABLE IF NOT EXISTS centro.backup_historico (
    id BIGSERIAL PRIMARY KEY,
    tipo_backup VARCHAR(50) NOT NULL,
    data_backup TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    arquivo_backup TEXT NOT NULL,
    tamanho_bytes BIGINT,
    usuario_backup VARCHAR(100) NOT NULL DEFAULT current_user,
    status VARCHAR(20) NOT NULL DEFAULT 'SUCESSO',
    observacoes TEXT,
    
    CONSTRAINT ck_backup_tipo_valido CHECK (tipo_backup IN ('COMPLETO', 'DADOS', 'SCHEMA', 'TABELAS', 'INCREMENTAL')),
    CONSTRAINT ck_backup_status_valido CHECK (status IN ('SUCESSO', 'FALHA', 'EM_ANDAMENTO'))
);

COMMENT ON TABLE centro.backup_historico IS 
'Histórico de backups realizados no sistema';

-- ============================================================================
-- 7. PROCEDURE: Registrar Backup no Histórico
-- ============================================================================

CREATE OR REPLACE PROCEDURE centro.registrar_backup(
    p_tipo_backup VARCHAR(50),
    p_arquivo_backup TEXT,
    p_tamanho_bytes BIGINT DEFAULT NULL,
    p_status VARCHAR(20) DEFAULT 'SUCESSO',
    p_observacoes TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO centro.backup_historico (
        tipo_backup,
        arquivo_backup,
        tamanho_bytes,
        status,
        observacoes
    ) VALUES (
        p_tipo_backup,
        p_arquivo_backup,
        p_tamanho_bytes,
        p_status,
        p_observacoes
    );
    
    RAISE NOTICE 'Backup registrado no histórico: % - %', p_tipo_backup, p_arquivo_backup;
END;
$$;

COMMENT ON PROCEDURE centro.registrar_backup IS 
'Registra um backup realizado no histórico';

-- ============================================================================
-- 8. PROCEDURE: Backup Incremental (Apenas Dados Modificados)
-- ============================================================================

CREATE OR REPLACE PROCEDURE centro.backup_incremental(
    p_data_referencia TIMESTAMP DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_data_referencia TIMESTAMP;
    v_total_treinadores INTEGER;
    v_total_pokemon INTEGER;
    v_total_consultas INTEGER;
BEGIN
    -- Se não informado, usar último backup
    IF p_data_referencia IS NULL THEN
        SELECT MAX(data_backup) INTO v_data_referencia
        FROM centro.backup_historico
        WHERE status = 'SUCESSO';
        
        IF v_data_referencia IS NULL THEN
            v_data_referencia := CURRENT_TIMESTAMP - INTERVAL '1 day';
        END IF;
    ELSE
        v_data_referencia := p_data_referencia;
    END IF;
    
    -- Contar registros modificados
    SELECT COUNT(*) INTO v_total_treinadores
    FROM centro.treinador
    WHERE data_atualizacao >= v_data_referencia;
    
    SELECT COUNT(*) INTO v_total_pokemon
    FROM centro.pokemon
    WHERE data_captura >= v_data_referencia;
    
    SELECT COUNT(*) INTO v_total_consultas
    FROM centro.consulta
    WHERE data_criacao >= v_data_referencia;
    
    RAISE NOTICE '=== BACKUP INCREMENTAL ===';
    RAISE NOTICE 'Data de referência: %', v_data_referencia;
    RAISE NOTICE 'Treinadores modificados: %', v_total_treinadores;
    RAISE NOTICE 'Pokémon capturados: %', v_total_pokemon;
    RAISE NOTICE 'Consultas criadas: %', v_total_consultas;
    RAISE NOTICE '';
    RAISE NOTICE 'Para realizar o backup incremental, use:';
    RAISE NOTICE 'COPY (SELECT * FROM centro.treinador WHERE data_atualizacao >= ''%'') TO ''/backup/treinadores_inc.csv'' CSV HEADER;', v_data_referencia;
    RAISE NOTICE 'COPY (SELECT * FROM centro.pokemon WHERE data_captura >= ''%'') TO ''/backup/pokemon_inc.csv'' CSV HEADER;', v_data_referencia;
    RAISE NOTICE 'COPY (SELECT * FROM centro.consulta WHERE data_criacao >= ''%'') TO ''/backup/consultas_inc.csv'' CSV HEADER;', v_data_referencia;
END;
$$;

COMMENT ON PROCEDURE centro.backup_incremental IS 
'Gera comandos para backup incremental de dados modificados';

-- ============================================================================
-- 9. PROCEDURE: Verificar Integridade do Banco
-- ============================================================================

CREATE OR REPLACE PROCEDURE centro.verificar_integridade(
    OUT p_total_erros INTEGER,
    OUT p_mensagem TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_erros TEXT[] := ARRAY[]::TEXT[];
    v_count INTEGER;
BEGIN
    p_total_erros := 0;
    
    -- Verificar pokémon sem treinador
    SELECT COUNT(*) INTO v_count
    FROM centro.pokemon p
    LEFT JOIN centro.treinador t ON t.id = p.treinador_id
    WHERE t.id IS NULL;
    
    IF v_count > 0 THEN
        v_erros := array_append(v_erros, v_count || ' pokémon sem treinador');
        p_total_erros := p_total_erros + v_count;
    END IF;
    
    -- Verificar consultas sem pokémon
    SELECT COUNT(*) INTO v_count
    FROM centro.consulta c
    LEFT JOIN centro.pokemon p ON p.id = c.pokemon_id
    WHERE p.id IS NULL;
    
    IF v_count > 0 THEN
        v_erros := array_append(v_erros, v_count || ' consultas sem pokémon');
        p_total_erros := p_total_erros + v_count;
    END IF;
    
    -- Verificar vida inválida
    SELECT COUNT(*) INTO v_count
    FROM centro.pokemon
    WHERE vida_atual > vida_maxima OR vida_atual < 0;
    
    IF v_count > 0 THEN
        v_erros := array_append(v_erros, v_count || ' pokémon com vida inválida');
        p_total_erros := p_total_erros + v_count;
    END IF;
    
    -- Gerar mensagem
    IF p_total_erros = 0 THEN
        p_mensagem := 'Banco de dados íntegro. Nenhum erro encontrado.';
    ELSE
        p_mensagem := 'Encontrados ' || p_total_erros || ' erros: ' || ARRAY_TO_STRING(v_erros, '; ');
    END IF;
    
    RAISE NOTICE '%', p_mensagem;
END;
$$;

COMMENT ON PROCEDURE centro.verificar_integridade IS 
'Verifica a integridade referencial e de dados do banco';

-- ============================================================================
-- 10. SCRIPTS DE BACKUP AUTOMATIZADO (CRON)
-- ============================================================================

-- Criar função para backup automático diário
CREATE OR REPLACE FUNCTION centro.backup_automatico_diario()
RETURNS VOID AS $$
DECLARE
    v_arquivo TEXT;
    v_data TEXT;
BEGIN
    v_data := TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD');
    v_arquivo := '/backup/centro_pokemon/auto_' || v_data || '.backup';
    
    -- Registrar início
    CALL centro.registrar_backup('COMPLETO', v_arquivo, NULL, 'EM_ANDAMENTO', 'Backup automático diário');
    
    -- Aqui seria executado o comando real de backup
    -- Por enquanto, apenas registramos
    
    RAISE NOTICE 'Backup automático iniciado: %', v_arquivo;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION centro.backup_automatico_diario IS 
'Função para ser chamada pelo cron para backup automático diário';

-- ============================================================================
-- COMANDOS ÚTEIS PARA BACKUP/RESTORE
-- ============================================================================

/*
=== COMANDOS SHELL PARA BACKUP ===

# Backup completo (formato custom)
pg_dump -h localhost -U postgres -F c -b -v -f /backup/centro_pokemon_full.backup centro_pokemon

# Backup completo (formato SQL)
pg_dump -h localhost -U postgres -f /backup/centro_pokemon_full.sql centro_pokemon

# Backup apenas dados
pg_dump -h localhost -U postgres -a -f /backup/centro_pokemon_data.sql centro_pokemon

# Backup apenas schema
pg_dump -h localhost -U postgres -s -f /backup/centro_pokemon_schema.sql centro_pokemon

# Backup de tabela específica
pg_dump -h localhost -U postgres -t centro.pokemon -f /backup/pokemon.sql centro_pokemon

# Backup compactado
pg_dump -h localhost -U postgres centro_pokemon | gzip > /backup/centro_pokemon.sql.gz

=== COMANDOS SHELL PARA RESTORE ===

# Restore de backup custom
pg_restore -h localhost -U postgres -d centro_pokemon -c -v /backup/centro_pokemon_full.backup

# Restore de backup SQL
psql -h localhost -U postgres -d centro_pokemon -f /backup/centro_pokemon_full.sql

# Restore de backup compactado
gunzip -c /backup/centro_pokemon.sql.gz | psql -h localhost -U postgres -d centro_pokemon

# Restore sem limpar dados existentes
pg_restore -h localhost -U postgres -d centro_pokemon -v /backup/centro_pokemon_full.backup

=== CONFIGURAÇÃO DE BACKUP AUTOMÁTICO (CRON) ===

# Editar crontab
crontab -e

# Backup diário às 2h da manhã
0 2 * * * pg_dump -h localhost -U postgres -F c centro_pokemon > /backup/centro_pokemon_$(date +\%Y\%m\%d).backup

# Backup semanal aos domingos às 3h
0 3 * * 0 pg_dump -h localhost -U postgres -F c centro_pokemon > /backup/centro_pokemon_weekly_$(date +\%Y\%m\%d).backup

# Limpeza de backups antigos (manter últimos 30 dias)
0 4 * * * find /backup/centro_pokemon_*.backup -mtime +30 -delete

*/

-- ============================================================================
-- FIM DOS SCRIPTS DE BACKUP E RESTORE
-- ============================================================================

-- Listar histórico de backups
SELECT 
    id,
    tipo_backup,
    data_backup,
    arquivo_backup,
    CASE 
        WHEN tamanho_bytes IS NOT NULL THEN 
            ROUND(tamanho_bytes / 1024.0 / 1024.0, 2) || ' MB'
        ELSE 'N/A'
    END as tamanho,
    usuario_backup,
    status
FROM centro.backup_historico
ORDER BY data_backup DESC
LIMIT 10;
