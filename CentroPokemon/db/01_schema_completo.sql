-- ============================================================================
-- CENTRO POKÉMON - SCHEMA COMPLETO
-- Banco de Dados II - Sistema de Gerenciamento de Centro Pokémon
-- ============================================================================
-- Autores: Alexandre Lampert, Felipe Winter, Gustavo Pigatto, 
--          Mateus Stock, Matheus Schvan
-- Data: 24/11/2025
-- Versão: 2.0
-- ============================================================================

-- ============================================================================
-- 1. CRIAÇÃO DO BANCO DE DADOS
-- ============================================================================

-- Remover banco se existir (cuidado em produção!)
-- DROP DATABASE IF EXISTS centro_pokemon;

-- Criar banco com encoding UTF-8
CREATE DATABASE centro_pokemon
    WITH 
    ENCODING = 'UTF8'
    LC_COLLATE = 'pt_BR.UTF-8'
    LC_CTYPE = 'pt_BR.UTF-8'
    TEMPLATE = template0;

-- Conectar ao banco
\c centro_pokemon;

-- ============================================================================
-- 2. EXTENSÕES
-- ============================================================================

-- Extensão para funções de criptografia
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Extensão para UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 3. SCHEMAS
-- ============================================================================

-- Schema para dados principais
CREATE SCHEMA IF NOT EXISTS centro;

-- Schema para auditoria
CREATE SCHEMA IF NOT EXISTS auditoria;

-- Schema para relatórios
CREATE SCHEMA IF NOT EXISTS relatorios;

-- Definir search_path padrão
SET search_path TO centro, public;

-- ============================================================================
-- 4. TABELAS PRINCIPAIS
-- ============================================================================

-- Tabela de Treinadores
CREATE TABLE centro.treinador (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    usuario VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL, -- Hash BCrypt
    telefone VARCHAR(20),
    data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    
    -- Constraints
    CONSTRAINT ck_treinador_nome_valido CHECK (LENGTH(TRIM(nome)) >= 3),
    CONSTRAINT ck_treinador_usuario_valido CHECK (LENGTH(TRIM(usuario)) >= 3),
    CONSTRAINT ck_treinador_email_valido CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT ck_treinador_telefone_valido CHECK (telefone IS NULL OR telefone ~ '^\d{10,11}$')
);

-- Tabela de Tipos Pokémon
CREATE TABLE centro.tipo (
    id SERIAL PRIMARY KEY,
    nome_pt VARCHAR(50) NOT NULL UNIQUE,
    nome_en VARCHAR(50) NOT NULL UNIQUE,
    cor VARCHAR(7) NOT NULL, -- Hex color
    
    CONSTRAINT ck_tipo_cor_valida CHECK (cor ~ '^#[0-9A-Fa-f]{6}$')
);

-- Tabela de Pokémon do Treinador
CREATE TABLE centro.pokemon (
    id BIGSERIAL PRIMARY KEY,
    treinador_id BIGINT NOT NULL,
    poke_api_id INTEGER NOT NULL,
    nome_pt VARCHAR(100) NOT NULL,
    nome_en VARCHAR(100) NOT NULL,
    sprite_url TEXT,
    vida_atual INTEGER NOT NULL DEFAULT 100,
    vida_maxima INTEGER NOT NULL DEFAULT 100,
    nivel INTEGER NOT NULL DEFAULT 5,
    experiencia INTEGER NOT NULL DEFAULT 0,
    data_captura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    apelido VARCHAR(100),
    
    -- Foreign Keys
    CONSTRAINT fk_pokemon_treinador FOREIGN KEY (treinador_id) 
        REFERENCES centro.treinador(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT ck_pokemon_vida_atual_valida CHECK (vida_atual >= 0 AND vida_atual <= vida_maxima),
    CONSTRAINT ck_pokemon_vida_maxima_valida CHECK (vida_maxima > 0 AND vida_maxima <= 999),
    CONSTRAINT ck_pokemon_nivel_valido CHECK (nivel >= 1 AND nivel <= 100),
    CONSTRAINT ck_pokemon_experiencia_valida CHECK (experiencia >= 0),
    CONSTRAINT ck_pokemon_poke_api_id_valido CHECK (poke_api_id > 0)
);

-- Tabela de relacionamento Pokémon-Tipo (N:N)
CREATE TABLE centro.pokemon_tipo (
    pokemon_id BIGINT NOT NULL,
    tipo_id INTEGER NOT NULL,
    
    PRIMARY KEY (pokemon_id, tipo_id),
    
    CONSTRAINT fk_pokemon_tipo_pokemon FOREIGN KEY (pokemon_id) 
        REFERENCES centro.pokemon(id) ON DELETE CASCADE,
    CONSTRAINT fk_pokemon_tipo_tipo FOREIGN KEY (tipo_id) 
        REFERENCES centro.tipo(id) ON DELETE CASCADE
);

-- Tabela de Habilidades
CREATE TABLE centro.habilidade (
    id SERIAL PRIMARY KEY,
    nome_pt VARCHAR(100) NOT NULL UNIQUE,
    nome_en VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT
);

-- Tabela de relacionamento Pokémon-Habilidade (N:N)
CREATE TABLE centro.pokemon_habilidade (
    pokemon_id BIGINT NOT NULL,
    habilidade_id INTEGER NOT NULL,
    
    PRIMARY KEY (pokemon_id, habilidade_id),
    
    CONSTRAINT fk_pokemon_habilidade_pokemon FOREIGN KEY (pokemon_id) 
        REFERENCES centro.pokemon(id) ON DELETE CASCADE,
    CONSTRAINT fk_pokemon_habilidade_habilidade FOREIGN KEY (habilidade_id) 
        REFERENCES centro.habilidade(id) ON DELETE CASCADE
);

-- Tabela de Consultas
CREATE TABLE centro.consulta (
    id BIGSERIAL PRIMARY KEY,
    treinador_id BIGINT NOT NULL,
    pokemon_id BIGINT NOT NULL,
    tipo_consulta VARCHAR(50) NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    observacoes TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'AGENDADA',
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_conclusao TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_consulta_treinador FOREIGN KEY (treinador_id) 
        REFERENCES centro.treinador(id) ON DELETE CASCADE,
    CONSTRAINT fk_consulta_pokemon FOREIGN KEY (pokemon_id) 
        REFERENCES centro.pokemon(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT ck_consulta_tipo_valido CHECK (tipo_consulta IN ('CONSULTA', 'VACINACAO', 'CHECKUP', 'EMERGENCIA')),
    CONSTRAINT ck_consulta_status_valido CHECK (status IN ('AGENDADA', 'EM_ATENDIMENTO', 'CONCLUIDA', 'CANCELADA')),
    CONSTRAINT ck_consulta_data_futura CHECK (data_hora >= data_criacao),
    CONSTRAINT ck_consulta_conclusao_valida CHECK (
        (status = 'CONCLUIDA' AND data_conclusao IS NOT NULL) OR 
        (status != 'CONCLUIDA' AND data_conclusao IS NULL)
    )
);

-- Tabela de Histórico de Cura
CREATE TABLE centro.historico_cura (
    id BIGSERIAL PRIMARY KEY,
    pokemon_id BIGINT NOT NULL,
    vida_antes INTEGER NOT NULL,
    vida_depois INTEGER NOT NULL,
    data_cura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metodo VARCHAR(50) NOT NULL DEFAULT 'CENTRO_POKEMON',
    
    CONSTRAINT fk_historico_cura_pokemon FOREIGN KEY (pokemon_id) 
        REFERENCES centro.pokemon(id) ON DELETE CASCADE,
    
    CONSTRAINT ck_historico_cura_vida_valida CHECK (vida_antes >= 0 AND vida_depois >= vida_antes),
    CONSTRAINT ck_historico_cura_metodo_valido CHECK (metodo IN ('CENTRO_POKEMON', 'POCAO', 'SUPER_POCAO', 'HIPER_POCAO', 'REVIVE'))
);

-- ============================================================================
-- 5. TABELAS DE AUDITORIA
-- ============================================================================

-- Tabela de auditoria de treinadores
CREATE TABLE auditoria.treinador_audit (
    id BIGSERIAL PRIMARY KEY,
    treinador_id BIGINT NOT NULL,
    operacao VARCHAR(10) NOT NULL,
    usuario_db VARCHAR(100) NOT NULL,
    data_operacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dados_antigos JSONB,
    dados_novos JSONB,
    
    CONSTRAINT ck_audit_operacao_valida CHECK (operacao IN ('INSERT', 'UPDATE', 'DELETE'))
);

-- Tabela de auditoria de pokémon
CREATE TABLE auditoria.pokemon_audit (
    id BIGSERIAL PRIMARY KEY,
    pokemon_id BIGINT NOT NULL,
    operacao VARCHAR(10) NOT NULL,
    usuario_db VARCHAR(100) NOT NULL,
    data_operacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dados_antigos JSONB,
    dados_novos JSONB,
    
    CONSTRAINT ck_audit_pokemon_operacao_valida CHECK (operacao IN ('INSERT', 'UPDATE', 'DELETE'))
);

-- Tabela de log de acesso
CREATE TABLE auditoria.log_acesso (
    id BIGSERIAL PRIMARY KEY,
    treinador_id BIGINT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    acao VARCHAR(100) NOT NULL,
    sucesso BOOLEAN NOT NULL,
    mensagem TEXT,
    data_acesso TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 6. ÍNDICES
-- ============================================================================

-- Índices para Treinador
CREATE INDEX idx_treinador_usuario ON centro.treinador(usuario);
CREATE INDEX idx_treinador_email ON centro.treinador(email);
CREATE INDEX idx_treinador_ativo ON centro.treinador(ativo);
CREATE INDEX idx_treinador_data_cadastro ON centro.treinador(data_cadastro);

-- Índices para Pokémon
CREATE INDEX idx_pokemon_treinador ON centro.pokemon(treinador_id);
CREATE INDEX idx_pokemon_nome_pt ON centro.pokemon(nome_pt);
CREATE INDEX idx_pokemon_nivel ON centro.pokemon(nivel);
CREATE INDEX idx_pokemon_vida_atual ON centro.pokemon(vida_atual);
CREATE INDEX idx_pokemon_data_captura ON centro.pokemon(data_captura);

-- Índices para Consulta
CREATE INDEX idx_consulta_treinador ON centro.consulta(treinador_id);
CREATE INDEX idx_consulta_pokemon ON centro.consulta(pokemon_id);
CREATE INDEX idx_consulta_data_hora ON centro.consulta(data_hora);
CREATE INDEX idx_consulta_status ON centro.consulta(status);
CREATE INDEX idx_consulta_tipo ON centro.consulta(tipo_consulta);

-- Índices compostos
CREATE INDEX idx_pokemon_treinador_nivel ON centro.pokemon(treinador_id, nivel DESC);
CREATE INDEX idx_consulta_treinador_data ON centro.consulta(treinador_id, data_hora DESC);

-- Índices para auditoria
CREATE INDEX idx_treinador_audit_treinador ON auditoria.treinador_audit(treinador_id);
CREATE INDEX idx_treinador_audit_data ON auditoria.treinador_audit(data_operacao);
CREATE INDEX idx_pokemon_audit_pokemon ON auditoria.pokemon_audit(pokemon_id);
CREATE INDEX idx_pokemon_audit_data ON auditoria.pokemon_audit(data_operacao);
CREATE INDEX idx_log_acesso_treinador ON auditoria.log_acesso(treinador_id);
CREATE INDEX idx_log_acesso_data ON auditoria.log_acesso(data_acesso);

-- ============================================================================
-- 7. COMENTÁRIOS
-- ============================================================================

COMMENT ON TABLE centro.treinador IS 'Tabela de treinadores cadastrados no sistema';
COMMENT ON TABLE centro.pokemon IS 'Tabela de pokémon capturados pelos treinadores';
COMMENT ON TABLE centro.consulta IS 'Tabela de consultas agendadas no Centro Pokémon';
COMMENT ON TABLE centro.historico_cura IS 'Histórico de todas as curas realizadas';
COMMENT ON TABLE auditoria.treinador_audit IS 'Auditoria de operações na tabela treinador';
COMMENT ON TABLE auditoria.pokemon_audit IS 'Auditoria de operações na tabela pokemon';
COMMENT ON TABLE auditoria.log_acesso IS 'Log de acessos e ações dos usuários';

-- ============================================================================
-- FIM DO SCHEMA
-- ============================================================================
