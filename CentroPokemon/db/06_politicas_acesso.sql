-- ============================================================================
-- CENTRO POKÉMON - POLÍTICAS DE ACESSO
-- Criação de usuários, grupos e concessão de privilégios
-- ============================================================================

\c centro_pokemon;

-- ============================================================================
-- 1. CRIAÇÃO DE ROLES (GRUPOS)
-- ============================================================================

-- Role para Administradores do Sistema
CREATE ROLE admin_centro_pokemon;

COMMENT ON ROLE admin_centro_pokemon IS 
'Administradores com acesso total ao sistema';

-- Role para Enfermeiras/Atendentes do Centro Pokémon
CREATE ROLE enfermeira_centro_pokemon;

COMMENT ON ROLE enfermeira_centro_pokemon IS 
'Enfermeiras que realizam atendimentos e consultas';

-- Role para Treinadores (usuários finais)
CREATE ROLE treinador_centro_pokemon;

COMMENT ON ROLE treinador_centro_pokemon IS 
'Treinadores que utilizam os serviços do centro';

-- Role para Relatórios (apenas leitura)
CREATE ROLE relatorio_centro_pokemon;

COMMENT ON ROLE relatorio_centro_pokemon IS 
'Usuários que podem apenas visualizar relatórios';

-- Role para Aplicação (backend)
CREATE ROLE app_centro_pokemon;

COMMENT ON ROLE app_centro_pokemon IS 
'Usuário utilizado pela aplicação Spring Boot';

-- ============================================================================
-- 2. PRIVILÉGIOS PARA ADMINISTRADORES
-- ============================================================================

-- Acesso total a todos os schemas
GRANT ALL PRIVILEGES ON SCHEMA centro TO admin_centro_pokemon;
GRANT ALL PRIVILEGES ON SCHEMA auditoria TO admin_centro_pokemon;
GRANT ALL PRIVILEGES ON SCHEMA relatorios TO admin_centro_pokemon;

-- Acesso total a todas as tabelas
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA centro TO admin_centro_pokemon;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA auditoria TO admin_centro_pokemon;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA relatorios TO admin_centro_pokemon;

-- Acesso a sequences
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA centro TO admin_centro_pokemon;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA auditoria TO admin_centro_pokemon;

-- Acesso a functions e procedures
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA centro TO admin_centro_pokemon;
GRANT ALL PRIVILEGES ON ALL PROCEDURES IN SCHEMA centro TO admin_centro_pokemon;

-- Privilégios futuros
ALTER DEFAULT PRIVILEGES IN SCHEMA centro 
    GRANT ALL ON TABLES TO admin_centro_pokemon;
ALTER DEFAULT PRIVILEGES IN SCHEMA centro 
    GRANT ALL ON SEQUENCES TO admin_centro_pokemon;
ALTER DEFAULT PRIVILEGES IN SCHEMA centro 
    GRANT ALL ON FUNCTIONS TO admin_centro_pokemon;

-- ============================================================================
-- 3. PRIVILÉGIOS PARA ENFERMEIRAS
-- ============================================================================

-- Acesso aos schemas
GRANT USAGE ON SCHEMA centro TO enfermeira_centro_pokemon;
GRANT USAGE ON SCHEMA relatorios TO enfermeira_centro_pokemon;

-- Leitura em todas as tabelas
GRANT SELECT ON ALL TABLES IN SCHEMA centro TO enfermeira_centro_pokemon;
GRANT SELECT ON ALL TABLES IN SCHEMA relatorios TO enfermeira_centro_pokemon;

-- Permissões específicas para consultas
GRANT INSERT, UPDATE ON centro.consulta TO enfermeira_centro_pokemon;
GRANT USAGE, SELECT ON SEQUENCE centro.consulta_id_seq TO enfermeira_centro_pokemon;

-- Permissões para curar pokémon
GRANT UPDATE (vida_atual) ON centro.pokemon TO enfermeira_centro_pokemon;

-- Permissões para histórico de cura
GRANT INSERT ON centro.historico_cura TO enfermeira_centro_pokemon;
GRANT USAGE, SELECT ON SEQUENCE centro.historico_cura_id_seq TO enfermeira_centro_pokemon;

-- Acesso a procedures de cura e consulta
GRANT EXECUTE ON PROCEDURE centro.curar_pokemon TO enfermeira_centro_pokemon;
GRANT EXECUTE ON PROCEDURE centro.curar_todos_pokemon_treinador TO enfermeira_centro_pokemon;
GRANT EXECUTE ON PROCEDURE centro.concluir_consulta TO enfermeira_centro_pokemon;
GRANT EXECUTE ON PROCEDURE centro.cancelar_consulta TO enfermeira_centro_pokemon;

-- Privilégios futuros
ALTER DEFAULT PRIVILEGES IN SCHEMA centro 
    GRANT SELECT ON TABLES TO enfermeira_centro_pokemon;

-- ============================================================================
-- 4. PRIVILÉGIOS PARA TREINADORES
-- ============================================================================

-- Acesso aos schemas
GRANT USAGE ON SCHEMA centro TO treinador_centro_pokemon;
GRANT USAGE ON SCHEMA relatorios TO treinador_centro_pokemon;

-- Leitura limitada
GRANT SELECT ON centro.tipo TO treinador_centro_pokemon;
GRANT SELECT ON centro.habilidade TO treinador_centro_pokemon;

-- Acesso aos próprios dados (implementado via RLS - Row Level Security)
GRANT SELECT, UPDATE ON centro.treinador TO treinador_centro_pokemon;
GRANT SELECT, INSERT, UPDATE, DELETE ON centro.pokemon TO treinador_centro_pokemon;
GRANT SELECT, INSERT ON centro.consulta TO treinador_centro_pokemon;
GRANT SELECT ON centro.historico_cura TO treinador_centro_pokemon;

-- Acesso a sequences
GRANT USAGE, SELECT ON SEQUENCE centro.pokemon_id_seq TO treinador_centro_pokemon;
GRANT USAGE, SELECT ON SEQUENCE centro.consulta_id_seq TO treinador_centro_pokemon;

-- Acesso a tabelas de relacionamento
GRANT SELECT, INSERT, DELETE ON centro.pokemon_tipo TO treinador_centro_pokemon;
GRANT SELECT, INSERT, DELETE ON centro.pokemon_habilidade TO treinador_centro_pokemon;

-- Acesso a procedures específicas
GRANT EXECUTE ON PROCEDURE centro.agendar_consulta TO treinador_centro_pokemon;
GRANT EXECUTE ON PROCEDURE centro.cadastrar_pokemon_completo TO treinador_centro_pokemon;
GRANT EXECUTE ON PROCEDURE centro.gerar_estatisticas_treinador TO treinador_centro_pokemon;

-- Acesso a views de relatórios pessoais
GRANT SELECT ON relatorios.vw_pokemon_completo TO treinador_centro_pokemon;
GRANT SELECT ON relatorios.vw_consultas_detalhadas TO treinador_centro_pokemon;
GRANT SELECT ON relatorios.vw_historico_curas TO treinador_centro_pokemon;

-- ============================================================================
-- 5. PRIVILÉGIOS PARA RELATÓRIOS (SOMENTE LEITURA)
-- ============================================================================

-- Acesso aos schemas
GRANT USAGE ON SCHEMA centro TO relatorio_centro_pokemon;
GRANT USAGE ON SCHEMA relatorios TO relatorio_centro_pokemon;
GRANT USAGE ON SCHEMA auditoria TO relatorio_centro_pokemon;

-- Leitura em todas as tabelas
GRANT SELECT ON ALL TABLES IN SCHEMA centro TO relatorio_centro_pokemon;
GRANT SELECT ON ALL TABLES IN SCHEMA relatorios TO relatorio_centro_pokemon;
GRANT SELECT ON ALL TABLES IN SCHEMA auditoria TO relatorio_centro_pokemon;

-- Privilégios futuros
ALTER DEFAULT PRIVILEGES IN SCHEMA centro 
    GRANT SELECT ON TABLES TO relatorio_centro_pokemon;
ALTER DEFAULT PRIVILEGES IN SCHEMA relatorios 
    GRANT SELECT ON TABLES TO relatorio_centro_pokemon;
ALTER DEFAULT PRIVILEGES IN SCHEMA auditoria 
    GRANT SELECT ON TABLES TO relatorio_centro_pokemon;

-- ============================================================================
-- 6. PRIVILÉGIOS PARA APLICAÇÃO (BACKEND)
-- ============================================================================

-- Acesso aos schemas
GRANT USAGE ON SCHEMA centro TO app_centro_pokemon;
GRANT USAGE ON SCHEMA auditoria TO app_centro_pokemon;
GRANT USAGE ON SCHEMA relatorios TO app_centro_pokemon;

-- Acesso completo às tabelas principais
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA centro TO app_centro_pokemon;
GRANT SELECT ON ALL TABLES IN SCHEMA relatorios TO app_centro_pokemon;
GRANT INSERT ON ALL TABLES IN SCHEMA auditoria TO app_centro_pokemon;

-- Acesso a sequences
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA centro TO app_centro_pokemon;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA auditoria TO app_centro_pokemon;

-- Acesso a todas as procedures e functions
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA centro TO app_centro_pokemon;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA centro TO app_centro_pokemon;

-- Privilégios futuros
ALTER DEFAULT PRIVILEGES IN SCHEMA centro 
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_centro_pokemon;
ALTER DEFAULT PRIVILEGES IN SCHEMA centro 
    GRANT USAGE, SELECT ON SEQUENCES TO app_centro_pokemon;
ALTER DEFAULT PRIVILEGES IN SCHEMA centro 
    GRANT EXECUTE ON FUNCTIONS TO app_centro_pokemon;
ALTER DEFAULT PRIVILEGES IN SCHEMA centro 
    GRANT EXECUTE ON PROCEDURES TO app_centro_pokemon;

-- ============================================================================
-- 7. CRIAÇÃO DE USUÁRIOS ESPECÍFICOS
-- ============================================================================

-- Usuário Administrador
CREATE USER admin_master WITH PASSWORD 'Admin@2025!';
GRANT admin_centro_pokemon TO admin_master;
ALTER USER admin_master WITH SUPERUSER;

COMMENT ON ROLE admin_master IS 
'Usuário administrador master do sistema';

-- Usuário Enfermeira 1
CREATE USER enfermeira_joy WITH PASSWORD 'Joy@2025!';
GRANT enfermeira_centro_pokemon TO enfermeira_joy;

COMMENT ON ROLE enfermeira_joy IS 
'Enfermeira Joy - Atendente principal';

-- Usuário Enfermeira 2
CREATE USER enfermeira_chansey WITH PASSWORD 'Chansey@2025!';
GRANT enfermeira_centro_pokemon TO enfermeira_chansey;

COMMENT ON ROLE enfermeira_chansey IS 
'Enfermeira Chansey - Atendente auxiliar';

-- Usuário para Aplicação Spring Boot
CREATE USER app_backend WITH PASSWORD 'AppBackend@2025!';
GRANT app_centro_pokemon TO app_backend;

COMMENT ON ROLE app_backend IS 
'Usuário utilizado pela aplicação Spring Boot';

-- Usuário para Relatórios/BI
CREATE USER relatorio_bi WITH PASSWORD 'RelatBI@2025!';
GRANT relatorio_centro_pokemon TO relatorio_bi;

COMMENT ON ROLE relatorio_bi IS 
'Usuário para ferramentas de BI e relatórios';

-- ============================================================================
-- 8. ROW LEVEL SECURITY (RLS) - Segurança em Nível de Linha
-- ============================================================================

-- Habilitar RLS nas tabelas sensíveis
ALTER TABLE centro.pokemon ENABLE ROW LEVEL SECURITY;
ALTER TABLE centro.consulta ENABLE ROW LEVEL SECURITY;
ALTER TABLE centro.historico_cura ENABLE ROW LEVEL SECURITY;

-- Política: Treinadores só veem seus próprios pokémon
CREATE POLICY pokemon_treinador_policy ON centro.pokemon
    FOR ALL
    TO treinador_centro_pokemon
    USING (treinador_id = current_setting('app.current_treinador_id')::BIGINT);

-- Política: Treinadores só veem suas próprias consultas
CREATE POLICY consulta_treinador_policy ON centro.consulta
    FOR ALL
    TO treinador_centro_pokemon
    USING (treinador_id = current_setting('app.current_treinador_id')::BIGINT);

-- Política: Treinadores só veem histórico de cura de seus pokémon
CREATE POLICY historico_cura_treinador_policy ON centro.historico_cura
    FOR SELECT
    TO treinador_centro_pokemon
    USING (
        pokemon_id IN (
            SELECT id FROM centro.pokemon 
            WHERE treinador_id = current_setting('app.current_treinador_id')::BIGINT
        )
    );

-- Políticas para enfermeiras (acesso total para leitura)
CREATE POLICY pokemon_enfermeira_policy ON centro.pokemon
    FOR SELECT
    TO enfermeira_centro_pokemon
    USING (true);

CREATE POLICY consulta_enfermeira_policy ON centro.consulta
    FOR ALL
    TO enfermeira_centro_pokemon
    USING (true);

CREATE POLICY historico_cura_enfermeira_policy ON centro.historico_cura
    FOR SELECT
    TO enfermeira_centro_pokemon
    USING (true);

-- Políticas para aplicação (acesso total)
CREATE POLICY pokemon_app_policy ON centro.pokemon
    FOR ALL
    TO app_centro_pokemon
    USING (true);

CREATE POLICY consulta_app_policy ON centro.consulta
    FOR ALL
    TO app_centro_pokemon
    USING (true);

CREATE POLICY historico_cura_app_policy ON centro.historico_cura
    FOR ALL
    TO app_centro_pokemon
    USING (true);

-- Políticas para admin (acesso total)
CREATE POLICY pokemon_admin_policy ON centro.pokemon
    FOR ALL
    TO admin_centro_pokemon
    USING (true);

CREATE POLICY consulta_admin_policy ON centro.consulta
    FOR ALL
    TO admin_centro_pokemon
    USING (true);

CREATE POLICY historico_cura_admin_policy ON centro.historico_cura
    FOR ALL
    TO admin_centro_pokemon
    USING (true);

-- ============================================================================
-- 9. FUNÇÕES AUXILIARES PARA RLS
-- ============================================================================

-- Função para definir o treinador atual na sessão
CREATE OR REPLACE FUNCTION centro.set_current_treinador(p_treinador_id BIGINT)
RETURNS VOID AS $$
BEGIN
    PERFORM set_config('app.current_treinador_id', p_treinador_id::TEXT, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION centro.set_current_treinador IS 
'Define o ID do treinador atual para RLS';

-- Função para obter o treinador atual
CREATE OR REPLACE FUNCTION centro.get_current_treinador()
RETURNS BIGINT AS $$
BEGIN
    RETURN current_setting('app.current_treinador_id', true)::BIGINT;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION centro.get_current_treinador IS 
'Retorna o ID do treinador atual da sessão';

-- ============================================================================
-- 10. REVOGAÇÕES DE SEGURANÇA
-- ============================================================================

-- Revogar acesso público
REVOKE ALL ON SCHEMA centro FROM PUBLIC;
REVOKE ALL ON SCHEMA auditoria FROM PUBLIC;
REVOKE ALL ON SCHEMA relatorios FROM PUBLIC;

REVOKE ALL ON ALL TABLES IN SCHEMA centro FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA auditoria FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA relatorios FROM PUBLIC;

REVOKE ALL ON ALL SEQUENCES IN SCHEMA centro FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA auditoria FROM PUBLIC;

REVOKE ALL ON ALL FUNCTIONS IN SCHEMA centro FROM PUBLIC;
REVOKE ALL ON ALL PROCEDURES IN SCHEMA centro FROM PUBLIC;

-- ============================================================================
-- FIM DAS POLÍTICAS DE ACESSO
-- ============================================================================

-- Listar todos os usuários e suas roles
SELECT 
    r.rolname as usuario,
    ARRAY_AGG(r2.rolname) as roles,
    r.rolsuper as superuser,
    r.rolcreatedb as create_db,
    r.rolcanlogin as can_login
FROM pg_roles r
LEFT JOIN pg_auth_members m ON m.member = r.oid
LEFT JOIN pg_roles r2 ON r2.oid = m.roleid
WHERE r.rolname LIKE '%centro_pokemon%' OR r.rolname IN ('admin_master', 'enfermeira_joy', 'enfermeira_chansey', 'app_backend', 'relatorio_bi')
GROUP BY r.rolname, r.rolsuper, r.rolcreatedb, r.rolcanlogin
ORDER BY r.rolname;

-- Listar políticas RLS
SELECT 
    schemaname,
    tablename,
    policyname,
    roles,
    cmd,
    qual
FROM pg_policies
WHERE schemaname = 'centro'
ORDER BY tablename, policyname;
