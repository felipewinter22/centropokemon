### Instalação em 3 Minutos
```bash
# 1. Executar script master
psql -U postgres -f 00_executar_todos.sql

# 2. Validar instalação
psql -U postgres -d centro_pokemon -f 08_testes_validacao.sql

# 3. Explorar
psql -U postgres -d centro_pokemon
SELECT * FROM relatorios.vw_estatisticas_treinador;
```

---

## Documentação

### Para Começar
- **[INSTALACAO_RAPIDA.md](INSTALACAO_RAPIDA.md)** 
- **[RESUMO_1_PAGINA.md](RESUMO_1_PAGINA.md)** 
- **[INDEX.md](INDEX.md)** 
### Documentação Completa
- **[README_BD.md](README_BD.md)** 
- **[MODELO_LOGICO_NORMALIZADO.md](MODELO_LOGICO_NORMALIZADO.md)**
- **[REQUISITOS_ATENDIDOS.md](REQUISITOS_ATENDIDOS.md)** 

## Scripts SQL

### Script Principal
- **[00_executar_todos.sql](00_executar_todos.sql)**

### Scripts Individuais
1. **[01_schema_completo.sql](01_schema_completo.sql)** 
2. **[02_dados_iniciais.sql](02_dados_iniciais.sql)**
3. **[03_triggers.sql](03_triggers.sql)** 
4. **[04_stored_procedures.sql](04_stored_procedures.sql)** 
5. **[05_views_relatorios.sql](05_views_relatorios.sql)** 
6. **[06_politicas_acesso.sql](06_politicas_acesso.sql)** 
7. **[07_backup_restore.sql](07_backup_restore.sql)** 
8. **[08_testes_validacao.sql](08_testes_validacao.sql)** 

---


## Exemplos de Uso

### Testar Triggers
```sql
-- Atualizar pokémon (trigger registra cura)
UPDATE centro.pokemon SET vida_atual = vida_maxima WHERE id = 1;

-- Ver histórico
SELECT * FROM centro.historico_cura ORDER BY data_cura DESC LIMIT 5;
```

### Testar Procedures
```sql
-- Curar pokémon
CALL centro.curar_pokemon(1, 'CENTRO_POKEMON');

-- Estatísticas
CALL centro.gerar_estatisticas_treinador(1, NULL, NULL, NULL, NULL, NULL);
```

### Testar Views
```sql
-- Ranking de treinadores
SELECT * FROM relatorios.vw_ranking_treinadores LIMIT 10;

-- Pokémon críticos
SELECT * FROM relatorios.vw_pokemon_criticos;
```

### Testar Segurança (RLS)
```sql
-- Definir treinador
SELECT centro.set_current_treinador(1);

-- Só verá seus pokémon
SELECT * FROM centro.pokemon;
```

---

## Usuários Criados

| Usuário | Senha | Role | Uso |
|---------|-------|------|-----|
| admin_master | Admin@2025! | admin | Administração |
| enfermeira_joy | Joy@2025! | enfermeira | Atendimento |
| enfermeira_chansey | Chansey@2025! | enfermeira | Atendimento |
| app_backend | AppBackend@2025! | app | Spring Boot |
| relatorio_bi | RelatBI@2025! | relatorio | Power BI |

---

## Estrutura de Arquivos

```
db/
├── Scripts SQL
│   ├── 00_executar_todos.sql          Script master
│   ├── 01_schema_completo.sql         Schema e tabelas
│   ├── 02_dados_iniciais.sql          Dados de teste
│   ├── 03_triggers.sql                10 triggers
│   ├── 04_stored_procedures.sql       10 procedures
│   ├── 05_views_relatorios.sql        10 views
│   ├── 06_politicas_acesso.sql        Segurança
│   ├── 07_backup_restore.sql          Backup
│   └── 08_testes_validacao.sql        Testes
│
├── Documentação Principal
│   ├── README.md                      Este arquivo
│   ├── INDEX.md                       Índice geral
│   ├── INSTALACAO_RAPIDA.md          Guia de 5 min
│   ├── README_BD.md                   Doc completa
│   └── MODELO_LOGICO_NORMALIZADO.md  Modelo
```

---

## Suporte

### Problemas Comuns
Ver: [INSTALACAO_RAPIDA.md#solução-de-problemas](INSTALACAO_RAPIDA.md#-solução-de-problemas)

### Comandos Úteis
```sql
-- Listar tabelas
\dt centro.*

-- Listar views
\dv relatorios.*

-- Listar procedures
\df centro.*

-- Descrever tabela
\d centro.pokemon
```

---

## Equipe

**Desenvolvedores:**
- Alexandre Lampert
- Felipe Winter
- Gustavo Pigatto
- Mateus Stock
- Matheus Schvan

**Disciplina:** Banco de Dados II  
**Curso:** Ciência da Computação  
**Instituição:** Unoesc  
**Data:** 24/11/2025
