**Novo no projeto?** Comece aqui:
1. [INSTALACAO_RAPIDA.md](INSTALACAO_RAPIDA.md)
2. Execute: `psql -U postgres -f 00_executar_todos.sql`
3. Valide: `psql -U postgres -d centro_pokemon -f 08_testes_validacao.sql`

---

## Estrutura de Documentação

### Documentos Principais

| Documento | Descrição | Páginas |
|-----------|-----------|---------|------------|
| [INSTALACAO_RAPIDA.md](INSTALACAO_RAPIDA.md) | Guia de instalação em 5 minutos | 10 |
| [README_BD.md](README_BD.md) | Documentação completa do banco | 100+ |
| [MODELO_LOGICO_NORMALIZADO.md](MODELO_LOGICO_NORMALIZADO.md) | Modelo detalhado e normalização | 50+ |
| [INDEX.md](INDEX.md) | Este arquivo | 5 |

### Scripts SQL

| Script | Descrição | Ordem | Tempo |
|--------|-----------|-------|-------|
| [00_executar_todos.sql](00_executar_todos.sql) | Script master (executa tudo) | 0 | 3 min |
| [01_schema_completo.sql](01_schema_completo.sql) | Schema, tabelas, constraints, índices | 1 | 1 min |
| [02_dados_iniciais.sql](02_dados_iniciais.sql) | Dados de teste | 2 | 30s |
| [03_triggers.sql](03_triggers.sql) | 10 triggers | 3 | 30s |
| [04_stored_procedures.sql](04_stored_procedures.sql) | 10 procedures | 4 | 30s |
| [05_views_relatorios.sql](05_views_relatorios.sql) | 10 views | 5 | 30s |
| [06_politicas_acesso.sql](06_politicas_acesso.sql) | Usuários e permissões | 6 | 30s |
| [07_backup_restore.sql](07_backup_restore.sql) | Sistema de backup | 7 | 30s |
| [08_testes_validacao.sql](08_testes_validacao.sql) | Suite de testes | - | 2 min |

---

## Navegação por Tópico

### 1. Instalação e Configuração

**Iniciante:**
- [INSTALACAO_RAPIDA.md](INSTALACAO_RAPIDA.md) 
- [00_executar_todos.sql](00_executar_todos.sql) 

**Avançado:**
- [README_BD.md#instalação](README_BD.md#instalação) 

### 2. Modelo de Dados

**Conceitual:**
- [MODELO_LOGICO_NORMALIZADO.md](MODELO_LOGICO_NORMALIZADO.md) 
- [../diagrams/Class Diagram1.png](../diagrams/Class%20Diagram1.png)

**Implementação:**
- [01_schema_completo.sql](01_schema_completo.sql) 
- [README_BD.md#estrutura-do-banco](README_BD.md#estrutura-do-banco) 

### 3. Triggers

**Documentação:**
- [README_BD.md#triggers](README_BD.md#triggers) 

**Implementação:**
- [03_triggers.sql](03_triggers.sql) 

**Testes:**
- [08_testes_validacao.sql](08_testes_validacao.sql) 

### 4. Stored Procedures

**Documentação:**
- [README_BD.md#stored-procedures](README_BD.md#stored-procedures) 

**Implementação:**
- [04_stored_procedures.sql](04_stored_procedures.sql) 

**Testes:**
- [08_testes_validacao.sql](08_testes_validacao.sql) 

### 5. Views e Relatórios

**Documentação:**
- [README_BD.md#views-e-relatórios](README_BD.md#views-e-relatórios) 

**Implementação:**
- [05_views_relatorios.sql](05_views_relatorios.sql) 

**Testes:**
- [08_testes_validacao.sql](08_testes_validacao.sql) 

### 6. Segurança e Acesso

**Documentação:**
- [README_BD.md#usuários-e-permissões](README_BD.md#usuários-e-permissões) 

**Implementação:**
- [06_politicas_acesso.sql](06_politicas_acesso.sql) 

**Testes:**
- [08_testes_validacao.sql](08_testes_validacao.sql) 
### 7. Backup e Restore

**Documentação:**
- [README_BD.md#backup-e-restore](README_BD.md#backup-e-restore) 
**Implementação:**
- [07_backup_restore.sql](07_backup_restore.sql) 

**Comandos:**
- [INSTALACAO_RAPIDA.md#backup](INSTALACAO_RAPIDA.md#-configurar-backup-automático) 

### 8. Testes e Validação

**Suite de Testes:**
- [08_testes_validacao.sql](08_testes_validacao.sql) 

**Documentação:**
- [README_BD.md#testes](README_BD.md#testes) 
- [INSTALACAO_RAPIDA.md#validacao](INSTALACAO_RAPIDA.md#-validação-da-instalação)

---

## Casos de Uso

### Caso 1: Primeira Instalação
1. Leia: [INSTALACAO_RAPIDA.md](INSTALACAO_RAPIDA.md)
2. Execute: `psql -U postgres -f 00_executar_todos.sql`
3. Valide: `psql -U postgres -d centro_pokemon -f 08_testes_validacao.sql`
4. Configure: [../src/main/resources/application.properties](../CentroPokemon/src/main/resources/application.properties)

### Caso 2: Entender o Modelo
1. Leia: [MODELO_LOGICO_NORMALIZADO.md](MODELO_LOGICO_NORMALIZADO.md)
2. Veja: [../diagrams/Class Diagram1.png](../diagrams/Class%20Diagram1.png)
3. Explore: [01_schema_completo.sql](01_schema_completo.sql)

### Caso 3: Implementar Triggers
1. Estude: [README_BD.md#triggers](README_BD.md#triggers)
2. Veja código: [03_triggers.sql](03_triggers.sql)
3. Teste: [08_testes_validacao.sql](08_testes_validacao.sql) - Seção 1

### Caso 4: Criar Relatórios
1. Veja exemplos: [README_BD.md#views-e-relatórios](README_BD.md#views-e-relatórios)
2. Estude código: [05_views_relatorios.sql](05_views_relatorios.sql)
3. Execute: `SELECT * FROM relatorios.vw_estatisticas_treinador;`

### Caso 5: Configurar Backup
1. Leia: [README_BD.md#backup-e-restore](README_BD.md#backup-e-restore)
2. Execute: [07_backup_restore.sql](07_backup_restore.sql)
3. Configure cron: [INSTALACAO_RAPIDA.md#backup](INSTALACAO_RAPIDA.md#-configurar-backup-automático)

### Caso 6: Validar Requisitos
1. Verifique cada seção
2. Execute testes: [08_testes_validacao.sql](08_testes_validacao.sql)

---

## Busca Rápida

### Por Palavra-Chave

**Normalização:**
- [MODELO_LOGICO_NORMALIZADO.md#normalização](MODELO_LOGICO_NORMALIZADO.md#normalização)

**Triggers:**
- [03_triggers.sql](03_triggers.sql)
- [README_BD.md#triggers](README_BD.md#triggers)

**Procedures:**
- [04_stored_procedures.sql](04_stored_procedures.sql)
- [README_BD.md#stored-procedures](README_BD.md#stored-procedures)

**Views:**
- [05_views_relatorios.sql](05_views_relatorios.sql)
- [README_BD.md#views-e-relatórios](README_BD.md#views-e-relatórios)

**Segurança:**
- [06_politicas_acesso.sql](06_politicas_acesso.sql)
- [README_BD.md#usuários-e-permissões](README_BD.md#usuários-e-permissões)

**Backup:**
- [07_backup_restore.sql](07_backup_restore.sql)
- [README_BD.md#backup-e-restore](README_BD.md#backup-e-restore)

**Testes:**
- [08_testes_validacao.sql](08_testes_validacao.sql)

---

## Para Professores/Avaliadores

### Checklist de Avaliação
1. [MODELO_LOGICO_NORMALIZADO.md](MODELO_LOGICO_NORMALIZADO.md) 
2. [08_testes_validacao.sql](08_testes_validacao.sql) 

### Demonstração Rápida
```bash
# 1. Instalar (3 minutos)
psql -U postgres -f 00_executar_todos.sql

# 2. Testar (2 minutos)
psql -U postgres -d centro_pokemon -f 08_testes_validacao.sql

# 3. Explorar
psql -U postgres -d centro_pokemon
\dt centro.*
\dv relatorios.*
SELECT * FROM relatorios.vw_estatisticas_treinador;
```

### Documentação para Avaliação
- **Modelo:** [MODELO_LOGICO_NORMALIZADO.md](MODELO_LOGICO_NORMALIZADO.md)
- **Implementação:** [README_BD.md](README_BD.md)

---

## Suporte

### Problemas Comuns
- [INSTALACAO_RAPIDA.md#solução-de-problemas](INSTALACAO_RAPIDA.md#-solução-de-problemas)

### Comandos Úteis
- [INSTALACAO_RAPIDA.md#comandos-úteis](INSTALACAO_RAPIDA.md#comandos-úteis)

### Logs
```bash
# PostgreSQL
sudo tail -f /var/log/postgresql/postgresql-*.log

# Aplicação
tail -f ../CentroPokemon/logs/spring.log
```

---

## Links Externos

### Documentação Geral
- [README.md](../README.md) - Documentação do projeto completo
- [DOCUMENTATION.md](../DOCUMENTATION.md) - Documentação técnica
- [CHANGELOG.md](../CHANGELOG.md) - Histórico de mudanças

### Diagramas
- [Class Diagram](../diagrams/Class%20Diagram1.png)
- [Use Case Diagram](../diagrams/Use%20Case%20Diagram1.png)
- [Sequence Diagram](../diagrams/Sequence%20Diagram1.png)

### Código Fonte
- [Spring Boot Application](../CentroPokemon/src/main/java/com/centropokemon/)
- [Frontend](../CentroPokemon/src/main/resources/static/)

---

## Informações do Projeto

**Disciplina:** Banco de Dados II  
**Curso:** Ciência da Computação  
**Instituição:** Unoesc  
**Data:** 24/11/2025  
**Versão:** 2.0

**Equipe:**
- Alexandre Lampert
- Felipe Winter
- Gustavo Pigatto
- Mateus Stock
- Matheus Schvan

---
**Última atualização:** 24/11/2025  
**Versão do índice:** 1.0
