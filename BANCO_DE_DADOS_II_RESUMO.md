## Estrutura de Arquivos

```
CentroPokemon/
├── db/                                   
│   ├── 00_executar_todos.sql           
│   ├── 01_schema_completo.sql          
│   ├── 02_dados_iniciais.sql            
│   ├── 03_triggers.sql                 
│   ├── 04_stored_procedures.sql         
│   ├── 05_views_relatorios.sql        
│   ├── 06_politicas_acesso.sql         
│   ├── 07_backup_restore.sql            
│   ├── 08_testes_validacao.sql         
│   ├── README_BD.md                    
│   ├── MODELO_LOGICO_NORMALIZADO.md     
│   ├── REQUISITOS_ATENDIDOS.md           
│   └── INSTALACAO_RAPIDA.md              
├── diagrams/                              
├── README.md                              
└── DOCUMENTATION.md                       
```

---

## Instalação em 3 Passos

### 1. Executar Script Master
```bash
cd CentroPokemon/db
psql -U postgres -f 00_executar_todos.sql
```

### 2. Configurar Aplicação
```properties
# application.properties
spring.datasource.username=app_backend
spring.datasource.password=AppBackend@2025!
spring.jpa.hibernate.ddl-auto=validate
```

### 3. Executar Aplicação
```bash
cd CentroPokemon/CentroPokemon
./mvnw spring-boot:run
```
### 2. Triggers Inteligentes
```sql

CREATE TRIGGER trg_pokemon_auditoria
    AFTER INSERT OR UPDATE OR DELETE ON pokemon
    FOR EACH ROW
    EXECUTE FUNCTION auditar_pokemon();
```

### 3. Procedures Complexas
```sql

CALL centro.agendar_consulta(
    1, 1, 'CHECKUP',
    CURRENT_TIMESTAMP + INTERVAL '2 days',
    'Check-up de rotina',
    NULL -- OUT consulta_id
);
```

### 4. Views com Múltiplas Junções
```sql
SELECT * FROM relatorios.vw_estatisticas_treinador;
```

### 5. Row Level Security (RLS)
```sql
-- Treinadores só veem seus próprios dados
CREATE POLICY pokemon_treinador_policy ON pokemon
    USING (treinador_id = current_setting('app.current_treinador_id')::BIGINT);
```

## Segurança Implementada

### Níveis de Acesso

**Administrador (admin_master)**
- Acesso total ao sistema
- Gerenciamento de usuários
- Backup e restore

**Enfermeira (enfermeira_joy)**
- Visualizar todos os pokémon
- Realizar consultas e curas
- Acessar relatórios

**Treinador (via app)**
- Apenas seus próprios dados (RLS)
- Agendar consultas
- Ver histórico de curas

**Aplicação (app_backend)**
- CRUD completo
- Executar procedures
- Acessar views

**Relatórios (relatorio_bi)**
- Somente leitura
- Todas as views
- Dados de auditoria

---

## Relatórios Disponíveis

### 1. Estatísticas de Treinadores
```sql
SELECT * FROM relatorios.vw_estatisticas_treinador;
```
- Total de pokémon
- Nível médio
- Consultas realizadas
- Curas efetuadas

### 2. Ranking de Treinadores
```sql
SELECT * FROM relatorios.vw_ranking_treinadores LIMIT 10;
```
- Posição no ranking
- Pontuação calculada
- Soma de níveis

### 3. Pokémon Mais Populares
```sql
SELECT * FROM relatorios.vw_pokemon_populares;
```
- Total de capturas
- Nível médio
- Treinadores que possuem

### 4. Agenda do Dia
```sql
SELECT * FROM relatorios.vw_agenda_dia;
```
- Consultas agendadas
- Status atual
- Tempo até consulta

### 5. Pokémon Críticos
```sql
SELECT * FROM relatorios.vw_pokemon_criticos;
```
- Pokémon com vida baixa
- Última cura
- Próxima consulta

---

## Sistema de Backup

### Backup Automático
```bash
# Cron configurado para backup diário às 2h
0 2 * * * pg_dump -F c centro_pokemon > /backup/centro_pokemon_$(date +\%Y\%m\%d).backup
```
## Testes Implementados

### Suite de Testes Completa
```bash
psql -U postgres -d centro_pokemon -f 08_testes_validacao.sql
```

## Documentação

### Documentos Principais

1. **README_BD.md** (100+ páginas)
   - Documentação completa do banco
   - Exemplos de uso
   - Guias de instalação

2. **MODELO_LOGICO_NORMALIZADO.md** (50+ páginas)
   - Modelo detalhado
   - Dependências funcionais
   - Formas normais

3. **REQUISITOS_ATENDIDOS.md** (40+ páginas)
   - Checklist completo
   - Evidências de implementação
   - Exemplos práticos

4. **INSTALACAO_RAPIDA.md** (10+ páginas)
   - Guia de 5 minutos
   - Solução de problemas
   - Comandos úteis

**Total:** 200+ páginas de documentação

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
## Links Rápidos

- [Instalação Rápida](db/INSTALACAO_RAPIDA.md)
- [Documentação Completa](db/README_BD.md)
- [Modelo Normalizado](db/MODELO_LOGICO_NORMALIZADO.md)
- [Requisitos Atendidos](db/REQUISITOS_ATENDIDOS.md)
- [README Principal](README.md)
