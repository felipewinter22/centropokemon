# Banco de Dados - Centro Pokémon
## Estrutura do Banco

### Schemas
```
centro_pokemon/
├── centro/          # Dados principais
├── auditoria/       # Logs e auditoria
└── relatorios/      # Views para relatórios
```

### Tabelas Principais

#### centro.treinador
```sql
- id (PK)
- nome, usuario, email, senha
- telefone, data_cadastro, data_atualizacao
- ativo (boolean)
```

#### centro.pokemon
```sql
- id (PK)
- treinador_id (FK)
- poke_api_id, nome_pt, nome_en
- vida_atual, vida_maxima, nivel, experiencia
- sprite_url, data_captura, apelido
```

#### centro.consulta
```sql
- id (PK)
- treinador_id (FK), pokemon_id (FK)
- tipo_consulta, data_hora, status
- observacoes, data_criacao, data_conclusao
```

#### centro.historico_cura
```sql
- id (PK)
- pokemon_id (FK)
- vida_antes, vida_depois
- data_cura, metodo
```

### Tabelas de Relacionamento (N:N)
- `centro.pokemon_tipo` - Pokémon ↔ Tipos
- `centro.pokemon_habilidade` - Pokémon ↔ Habilidades

### Tabelas de Auditoria
- `auditoria.treinador_audit` - Auditoria de treinadores
- `auditoria.pokemon_audit` - Auditoria de pokémon
- `auditoria.log_acesso` - Log de acessos

---

## Instalação

### Pré-requisitos
- PostgreSQL 12+
- Usuário com privilégios de superusuário

### Instalação Completa (Recomendado)

```bash
# 1. Executar script master (instala tudo)
psql -U postgres -f 00_executar_todos.sql
```

### Instalação Manual (Passo a Passo)

```bash
# 1. Schema e tabelas
psql -U postgres -f 01_schema_completo.sql

# 2. Dados iniciais
psql -U postgres -f 02_dados_iniciais.sql

# 3. Triggers
psql -U postgres -f 03_triggers.sql

# 4. Stored Procedures
psql -U postgres -f 04_stored_procedures.sql

# 5. Views e Relatórios
psql -U postgres -f 05_views_relatorios.sql

# 6. Políticas de Acesso
psql -U postgres -f 06_politicas_acesso.sql

# 7. Backup e Restore
psql -U postgres -f 07_backup_restore.sql
```

### Configuração da Aplicação

Atualizar `application.properties`:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/centro_pokemon
spring.datasource.username=app_backend
spring.datasource.password=AppBackend@2025!
spring.jpa.hibernate.ddl-auto=validate
```

---

## Usuários e Permissões

### Roles (Grupos)

| Role | Descrição | Permissões |
|------|-----------|------------|
| `admin_centro_pokemon` | Administradores | Acesso total |
| `enfermeira_centro_pokemon` | Enfermeiras | Consultas, curas, leitura |
| `treinador_centro_pokemon` | Treinadores | Apenas seus dados (RLS) |
| `relatorio_centro_pokemon` | Relatórios/BI | Somente leitura |
| `app_centro_pokemon` | Aplicação | CRUD completo |

### Usuários Criados

| Usuário | Senha | Role | Uso |
|---------|-------|------|-----|
| `admin_master` | `Admin@2025!` | admin | Administração |
| `enfermeira_joy` | `Joy@2025!` | enfermeira | Atendimento |
| `enfermeira_chansey` | `Chansey@2025!` | enfermeira | Atendimento |
| `app_backend` | `AppBackend@2025!` | app | Spring Boot |
| `relatorio_bi` | `RelatBI@2025!` | relatorio | Power BI |

⚠️ **IMPORTANTE**: Altere todas as senhas em produção!

### Row Level Security (RLS)

Treinadores só acessam seus próprios dados:

```sql
-- Definir treinador da sessão
SELECT centro.set_current_treinador(1);

-- Agora só verá seus pokémon
SELECT * FROM centro.pokemon;
```

---

## Triggers

### Lista de Triggers Implementados

1. **trg_treinador_atualizar_data**
   - Atualiza `data_atualizacao` automaticamente

2. **trg_pokemon_validar_vida**
   - Valida e ajusta vida do pokémon

3. **trg_pokemon_registrar_cura**
   - Registra curas no histórico automaticamente

4. **trg_treinador_auditoria**
   - Auditoria completa de treinadores

5. **trg_pokemon_auditoria**
   - Auditoria completa de pokémon

6. **trg_consulta_validar_horario**
   - Valida horários e evita conflitos

7. **trg_consulta_atualizar_status**
   - Atualiza status ao concluir

8. **trg_pokemon_prevenir_exclusao**
   - Previne exclusão com consultas ativas

9. **trg_pokemon_calcular_experiencia**
   - Calcula experiência baseada no nível

10. **trg_pokemon_notificar_vida_critica**
    - Notifica quando vida está crítica

### Exemplo de Uso

```sql
-- Trigger automático ao atualizar vida
UPDATE centro.pokemon SET vida_atual = 100 WHERE id = 1;
-- Trigger registra no histórico automaticamente
```

---

## Stored Procedures

### Lista de Procedures

1. **curar_pokemon(pokemon_id, metodo)**
   ```sql
   CALL centro.curar_pokemon(1, 'CENTRO_POKEMON');
   ```

2. **curar_todos_pokemon_treinador(treinador_id)**
   ```sql
   CALL centro.curar_todos_pokemon_treinador(1);
   ```

3. **agendar_consulta(...)**
   ```sql
   CALL centro.agendar_consulta(
       1, -- treinador_id
       1, -- pokemon_id
       'CHECKUP',
       CURRENT_TIMESTAMP + INTERVAL '2 days',
       'Check-up de rotina',
       NULL -- OUT consulta_id
   );
   ```

4. **concluir_consulta(consulta_id, observacoes)**
   ```sql
   CALL centro.concluir_consulta(1, 'Pokémon curado com sucesso');
   ```

5. **cancelar_consulta(consulta_id, motivo)**
   ```sql
   CALL centro.cancelar_consulta(1, 'Treinador não compareceu');
   ```

6. **cadastrar_pokemon_completo(...)**
   ```sql
   CALL centro.cadastrar_pokemon_completo(
       1, -- treinador_id
       25, -- pikachu
       'Pikachu',
       'Pikachu',
       'https://...',
       5, -- nivel
       ARRAY[4], -- tipo elétrico
       ARRAY[1], -- habilidade estático
       NULL -- OUT pokemon_id
   );
   ```

7. **aplicar_dano_pokemon(pokemon_id, dano)**
   ```sql
   CALL centro.aplicar_dano_pokemon(1, 30);
   ```

8. **subir_nivel_pokemon(pokemon_id, niveis)**
   ```sql
   CALL centro.subir_nivel_pokemon(1, 1);
   ```

9. **limpar_consultas_antigas(dias_atras)**
   ```sql
   CALL centro.limpar_consultas_antigas(90);
   ```

10. **gerar_estatisticas_treinador(treinador_id, OUT ...)**
    ```sql
    CALL centro.gerar_estatisticas_treinador(1, NULL, NULL, NULL, NULL, NULL);
    ```

---

## Views e Relatórios

### Views Principais

#### 1. vw_pokemon_completo
Visão completa de pokémon com tipos, habilidades e status de saúde.

```sql
SELECT * FROM relatorios.vw_pokemon_completo WHERE treinador_id = 1;
```

#### 2. vw_consultas_detalhadas
Consultas com informações de treinador e pokémon.

```sql
SELECT * FROM relatorios.vw_consultas_detalhadas 
WHERE status = 'AGENDADA' 
ORDER BY data_hora;
```

#### 3. vw_estatisticas_treinador
Estatísticas completas por treinador.

```sql
SELECT * FROM relatorios.vw_estatisticas_treinador 
ORDER BY total_pokemon DESC;
```

#### 4. vw_ranking_treinadores
Ranking de treinadores por pontuação.

```sql
SELECT * FROM relatorios.vw_ranking_treinadores LIMIT 10;
```

#### 5. vw_pokemon_populares
Pokémon mais capturados.

```sql
SELECT * FROM relatorios.vw_pokemon_populares LIMIT 10;
```

#### 6. vw_agenda_dia
Agenda de consultas do dia.

```sql
SELECT * FROM relatorios.vw_agenda_dia;
```

#### 7. vw_pokemon_criticos
Pokémon com vida crítica.

```sql
SELECT * FROM relatorios.vw_pokemon_criticos;
```

#### 8. vw_historico_curas
Histórico completo de curas.

```sql
SELECT * FROM relatorios.vw_historico_curas 
WHERE treinador_id = 1 
ORDER BY data_cura DESC;
```

---

## Backup e Restore

### Backup Completo

```bash
# Gerar comando
psql -U postgres -d centro_pokemon -c "CALL centro.gerar_comando_backup_completo('/backup');"

# Executar backup
pg_dump -h localhost -U postgres -F c -b -v -f /backup/centro_pokemon_full.backup centro_pokemon
```

### Backup Incremental

```sql
-- Backup de dados modificados desde última data
CALL centro.backup_incremental('2025-11-01 00:00:00');
```

### Restore

```bash
# Restore completo (limpa e restaura)
pg_restore -h localhost -U postgres -d centro_pokemon -c -v /backup/centro_pokemon_full.backup

# Restore sem limpar
pg_restore -h localhost -U postgres -d centro_pokemon -v /backup/centro_pokemon_full.backup
```

### Backup Automático (Cron)

```bash
# Editar crontab
crontab -e

# Backup diário às 2h
0 2 * * * pg_dump -h localhost -U postgres -F c centro_pokemon > /backup/centro_pokemon_$(date +\%Y\%m\%d).backup

# Limpeza de backups antigos (30 dias)
0 4 * * * find /backup/centro_pokemon_*.backup -mtime +30 -delete
```

### Verificar Integridade

```sql
CALL centro.verificar_integridade(NULL, NULL);
```

---

## Exemplos de Uso

### Cenário 1: Cadastrar Novo Treinador e Pokémon

```sql
-- 1. Cadastrar treinador
INSERT INTO centro.treinador (nome, usuario, email, senha, telefone)
VALUES ('Ash Ketchum', 'ash', 'ash@pokemon.com', 'pikachu123', '47999999999');

-- 2. Cadastrar pokémon completo
CALL centro.cadastrar_pokemon_completo(
    1, -- treinador_id
    25, -- pikachu
    'Pikachu', 'Pikachu',
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png',
    5, -- nivel
    ARRAY[4], -- tipo elétrico
    ARRAY[1], -- habilidade
    NULL
);
```

### Cenário 2: Agendar e Concluir Consulta

```sql
-- 1. Agendar consulta
CALL centro.agendar_consulta(
    1, 1, 'CHECKUP',
    CURRENT_TIMESTAMP + INTERVAL '2 days',
    'Check-up de rotina',
    NULL
);

-- 2. Concluir consulta (cura automaticamente)
CALL centro.concluir_consulta(1, 'Pokémon saudável');
```

### Cenário 3: Batalha e Cura

```sql
-- 1. Aplicar dano
CALL centro.aplicar_dano_pokemon(1, 50);

-- 2. Verificar pokémon críticos
SELECT * FROM relatorios.vw_pokemon_criticos;

-- 3. Curar no centro
CALL centro.curar_pokemon(1, 'CENTRO_POKEMON');

-- 4. Ver histórico
SELECT * FROM relatorios.vw_historico_curas WHERE pokemon_id = 1;
```

### Cenário 4: Relatórios Gerenciais

```sql
-- Top 10 treinadores
SELECT * FROM relatorios.vw_ranking_treinadores LIMIT 10;

-- Estatísticas do dia
SELECT 
    (SELECT COUNT(*) FROM centro.consulta WHERE DATE(data_hora) = CURRENT_DATE) as consultas_hoje,
    (SELECT COUNT(*) FROM centro.historico_cura WHERE DATE(data_cura) = CURRENT_DATE) as curas_hoje,
    (SELECT COUNT(*) FROM centro.pokemon WHERE vida_atual < vida_maxima * 0.3) as pokemon_criticos;

-- Pokémon mais populares
SELECT * FROM relatorios.vw_pokemon_populares LIMIT 10;
```

---

## Consultas Úteis

### Verificar Estrutura

```sql
-- Listar todas as tabelas
SELECT schemaname, tablename 
FROM pg_tables 
WHERE schemaname IN ('centro', 'auditoria', 'relatorios')
ORDER BY schemaname, tablename;

-- Listar triggers
SELECT schemaname, tablename, triggername
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'centro' AND NOT t.tgisinternal;

-- Listar procedures
SELECT proname, pg_get_function_arguments(oid)
FROM pg_proc
WHERE pronamespace = 'centro'::regnamespace AND prokind = 'p';
```

### Auditoria

```sql
-- Ver últimas operações
SELECT * FROM auditoria.treinador_audit ORDER BY data_operacao DESC LIMIT 10;
SELECT * FROM auditoria.pokemon_audit ORDER BY data_operacao DESC LIMIT 10;

-- Ver acessos
SELECT * FROM auditoria.log_acesso ORDER BY data_acesso DESC LIMIT 10;
```

---

## Documentação Adicional

- **Diagramas UML**: `/diagrams/`
- **Documentação da API**: `/DOCUMENTATION.md`
- **Changelog**: `/CHANGELOG.md`
- **README Principal**: `/README.md`

---

## 👥 Equipe

Projeto desenvolvido como trabalho final de **Banco de Dados II** - Ciência da Computação, Unoesc.

**Desenvolvedores:**
- Alexandre Lampert
- Felipe Winter
- Gustavo Pigatto
- Mateus Stock
- Matheus Schvan

---

## Licença

Este projeto é acadêmico e foi desenvolvido para fins educacionais.

**Pokémon** e todos os nomes relacionados são marcas registradas da Nintendo, Game Freak e Creatures Inc.
