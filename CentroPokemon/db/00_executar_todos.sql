-- ============================================================================
-- CENTRO POKÉMON - SCRIPT MASTER
-- Executa todos os scripts na ordem correta
-- ============================================================================
-- ATENÇÃO: Execute este script como superusuário do PostgreSQL
-- Exemplo: psql -U postgres -f 00_executar_todos.sql
-- ============================================================================

\echo '============================================================================'
\echo 'CENTRO POKÉMON - INSTALAÇÃO COMPLETA DO BANCO DE DADOS'
\echo '============================================================================'
\echo ''
\echo 'Este script irá:'
\echo '  1. Criar o banco de dados e schemas'
\echo '  2. Criar todas as tabelas com constraints e índices'
\echo '  3. Inserir dados iniciais'
\echo '  4. Criar triggers para integridade e auditoria'
\echo '  5. Criar stored procedures para regras de negócio'
\echo '  6. Criar views e relatórios'
\echo '  7. Configurar políticas de acesso e usuários'
\echo '  8. Configurar sistema de backup'
\echo ''
\echo 'Pressione Ctrl+C para cancelar ou Enter para continuar...'
\echo ''

-- Pausar para confirmação (comentar se quiser execução automática)
-- \prompt 'Pressione Enter para continuar...' dummy

\echo ''
\echo '============================================================================'
\echo 'PASSO 1/7: Criando schema completo...'
\echo '============================================================================'
\i 01_schema_completo.sql

\echo ''
\echo '============================================================================'
\echo 'PASSO 2/7: Inserindo dados iniciais...'
\echo '============================================================================'
\i 02_dados_iniciais.sql

\echo ''
\echo '============================================================================'
\echo 'PASSO 3/7: Criando triggers...'
\echo '============================================================================'
\i 03_triggers.sql

\echo ''
\echo '============================================================================'
\echo 'PASSO 4/7: Criando stored procedures...'
\echo '============================================================================'
\i 04_stored_procedures.sql

\echo ''
\echo '============================================================================'
\echo 'PASSO 5/7: Criando views e relatórios...'
\echo '============================================================================'
\i 05_views_relatorios.sql

\echo ''
\echo '============================================================================'
\echo 'PASSO 6/7: Configurando políticas de acesso...'
\echo '============================================================================'
\i 06_politicas_acesso.sql

\echo ''
\echo '============================================================================'
\echo 'PASSO 7/7: Configurando sistema de backup...'
\echo '============================================================================'
\i 07_backup_restore.sql

\echo ''
\echo '============================================================================'
\echo 'INSTALAÇÃO CONCLUÍDA COM SUCESSO!'
\echo '============================================================================'
\echo ''
\echo 'Resumo da instalação:'
\echo ''

-- Estatísticas finais
\c centro_pokemon

SELECT '✓ Banco de dados: centro_pokemon' as status;
SELECT '✓ Schemas: ' || COUNT(*) || ' (centro, auditoria, relatorios)' as status
FROM pg_namespace WHERE nspname IN ('centro', 'auditoria', 'relatorios');

SELECT '✓ Tabelas: ' || COUNT(*) as status
FROM pg_tables WHERE schemaname IN ('centro', 'auditoria');

SELECT '✓ Views: ' || COUNT(*) as status
FROM pg_views WHERE schemaname = 'relatorios';

SELECT '✓ Triggers: ' || COUNT(*) as status
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname IN ('centro', 'auditoria') AND NOT t.tgisinternal;

SELECT '✓ Procedures: ' || COUNT(*) as status
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'centro' AND p.prokind = 'p';

SELECT '✓ Usuários: ' || COUNT(*) as status
FROM pg_roles
WHERE rolname LIKE '%centro_pokemon%' OR rolname IN ('admin_master', 'enfermeira_joy', 'enfermeira_chansey', 'app_backend', 'relatorio_bi');

\echo ''
\echo 'Próximos passos:'
\echo '  1. Atualizar application.properties com as credenciais do usuário app_backend'
\echo '  2. Configurar backup automático (ver 07_backup_restore.sql)'
\echo '  3. Testar a aplicação Spring Boot'
\echo ''
\echo 'Credenciais criadas (ALTERE EM PRODUÇÃO!):'
\echo '  - admin_master / Admin@2025!'
\echo '  - enfermeira_joy / Joy@2025!'
\echo '  - enfermeira_chansey / Chansey@2025!'
\echo '  - app_backend / AppBackend@2025!'
\echo '  - relatorio_bi / RelatBI@2025!'
\echo ''
\echo 'Para testar procedures, execute:'
\echo '  CALL centro.curar_pokemon(1);'
\echo '  CALL centro.gerar_estatisticas_treinador(1, NULL, NULL, NULL, NULL, NULL);'
\echo ''
\echo 'Para visualizar relatórios, execute:'
\echo '  SELECT * FROM relatorios.vw_estatisticas_treinador;'
\echo '  SELECT * FROM relatorios.vw_ranking_treinadores;'
\echo ''
\echo '============================================================================'
