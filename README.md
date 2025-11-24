# 🏥 Centro Pokémon — Aplicação Web com Pokédex e Centro de Cura

![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=java&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-F2F4F9?style=for-the-badge&logo=spring-boot)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Visual Paradigm](https://img.shields.io/badge/Visual_Paradigm-FF6F00?style=for-the-badge&logo=visual-paradigm&logoColor=white)

Um projeto Spring Boot com páginas estáticas e API REST para gerenciar treinadores, seus Pokémon e consultas médicas. Interface inspirada no anime, com Pokédex interativa e uma página inicial com “TV da Sala de Espera”.

## 🔗 Acesse localmente

- Home: http://localhost:8081/Pokemon.html
- Pokédex (anime): http://localhost:8081/pokedex-anime.html
- Pokédex (rota resumida): http://localhost:8081/pokedex
- Cadastro de Treinador: http://localhost:8081/cadastro.html
- Login: http://localhost:8081/login.html

## ✨ Funcionalidades Principais

### 🎮 Pokédex Interativa (Estilo Anime)
- **Busca Avançada**: Por nome, ID ou tipo
- **Navegação**: Anterior/Próximo, Aleatório
- **Filtros por Tipo**: 18 tipos Pokémon com busca aleatória
- **Animações Premium**: 
  - Loading com Pokébolas girando (1s)
  - Entrada 3D da Pokédex
  - Hover effects em todos elementos
  - Transições suaves
- **Sidebars Inteligentes**:
  - Esquerda: Coleção capturada (clicável), Missões diárias, Dicas
  - Direita: Mais pesquisados (clicável), Tipos, Estatísticas
- **Integração PokeAPI v2**: Dados em tempo real

### 🏥 Centro de Cura
- **Cura Rápida**: 
  - Clique na barra de HP para curar
  - Animações de partículas verdes
  - Notificação "+100 HP"
  - Atualização individual (sem reload)
  - Transição suave da barra (1.5s)
- **Agendamento de Consultas**:
  - Formulário completo
  - Tipos: Consulta, Vacinação, Check-up
  - Cards grandes com sprites
  - Validação de horários
- **Layout Otimizado**: 2 colunas responsivas

### 👤 Sistema de Autenticação
- **Cadastro**: Com escolha de Pokémon inicial (Bulbasaur, Charmander, Squirtle)
- **Login**: Autenticação por usuário ou e-mail
- **Persistência**: LocalStorage + PostgreSQL

### 🎨 Interface Premium
- **Design Retrô**: Inspirado no anime clássico
- **Animações Suaves**: Cubic-bezier em todas transições
- **Responsivo**: Mobile-first design
- **Splash Screen**: "Iniciando Aventura Pokémon" (2s)

## 🗺️ Estrutura de Páginas

### Páginas Principais
- **Pokemon.html**: Landing page com estatísticas, atalhos rápidos e vídeo da sala de espera
- **pokedex-anime.html** (`/pokedex`): Pokédex completa estilo anime com 3 colunas
- **cadastro.html**: Cadastro de treinadores com preview em tempo real
- **login.html**: Autenticação com fundo azul temático

### Seções da Home
- **#inicio**: Hero section com Pikachu animado
- **#centro**: Centro de Cura (Agendamento + Cura Rápida)
- **#sobre**: Informações do projeto e equipe

### Assets Estáticos
Localização: `src/main/resources/static/`

**CSS:**
- `/css/novo-style.css`: Estilos globais + splash screen
- `/css/pokedex-anime.css`: Pokédex + animações
- `/css/centro-cura.css`: Centro de Cura + animações de cura

**JavaScript:**
- `/js/pokedex-anime.js`: Lógica da Pokédex (750+ linhas)
- `/js/animacoes.js`: Navegação e efeitos
- `/js/auth-header.js`: Header de autenticação

**Imagens:**
- Pokémon: `bulbasauro.png`, `charmander.png`, `squirtle.png`, `pikachu-pokedex.png`
- UI: `pokebola.png`, `Bag_Master_Ball_SV_Sprite.png`, `rare-candy.png`

**Vídeos:**
- `/videos/EP 001 - Pokémon Eu Escolho Você!.mkv`

## 🧰 Tecnologias

- Java 21, Spring Boot 3.3.x
- Spring Web, Spring Data JPA, Validation
- Banco de dados: PostgreSQL
- Maven Wrapper (mvnw / mvnw.cmd)

## 🚀 Como Rodar

### Pré-requisitos
- Java 21+
- PostgreSQL 12+
- Maven 3.8+ (ou use o wrapper incluído)

### 1. Configurar Banco de Dados

Crie o banco no PostgreSQL:
```sql
CREATE DATABASE centro_pokemon;
```

Configure em `src/main/resources/application.properties`:
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/centro_pokemon
spring.datasource.username=seu_usuario
spring.datasource.password=sua_senha
spring.jpa.hibernate.ddl-auto=update
server.port=8081
```

### 2. Executar a Aplicação

**Opção A - Maven Wrapper (Recomendado)**
```bash
# Windows
./mvnw.cmd spring-boot:run

# Linux/Mac
./mvnw spring-boot:run
```

**Opção B - JAR**
```bash
mvn clean package -DskipTests
java -jar target/CentroPokemon-0.0.1-SNAPSHOT.jar
```

### 3. Acessar
Abra o navegador em: **http://localhost:8081/Pokemon.html**


## 📡 API REST

**Base URL**: `/api`

### 👤 Treinadores (`/treinadores`)
```http
POST /cadastrar
Body: { nome, usuario, email, senha, telefone?, starterId?, starterName?, starterSpriteUrl? }
Response: { id, nome, usuario, email, ... }

POST /login
Body: { usuarioOuEmail, senha }
Response: { id, nome, usuario, email, ... }
```

### 🎮 Pokémon do Treinador (`/treinadores/{id}/pokemons`)
```http
POST /
Body: { pokeApiId, nomePt, nomeEn, spriteUrl, vidaAtual, vidaMaxima, nivel, habilidades[], tipos[] }
Response: Pokemon cadastrado

GET /
Response: Lista de Pokémon do treinador

POST /{pokemonId}/curar
Response: Pokemon com HP atualizado

DELETE /{pokemonId}
Response: 204 No Content
```

### 📅 Consultas (`/treinadores/{id}/consultas`)
```http
POST /
Body: { pokemonId, tipo, dataHora, observacoes? }
Response: Consulta agendada

GET /
Response: Lista de consultas do treinador
```

### 📖 Pokédex (`/pokemons`)
```http
GET /{nomeOuId}
Response: Dados completos do Pokémon (PokeAPI v2)

GET /random
Response: Pokémon aleatório (1-898)

GET /type/{tipo}/random
Response: Pokémon aleatório do tipo especificado
```

**Tipos disponíveis**: normal, fire, water, electric, grass, ice, fighting, poison, ground, flying, psychic, bug, rock, ghost, dragon, dark, steel, fairy

## 🖼️ Diagramas

- [Use Case](diagrams/Use%20Case%20Diagram1.png)
- [Sequence](diagrams/Sequence%20Diagram1.png)
- [Class](diagrams/Class%20Diagram1.png)
- [Activity](diagrams/Activity%20Diagram1.png)
- [Estados de saúde do Pokémon](diagrams/Estados%20de%20sa%C3%BAde%20do%20Pok%C3%A9mon.png)

Projeto visual original: [sources/CentroPokemon.vpp](sources/CentroPokemon.vpp)

## 🎯 Arquitetura do Projeto

### Backend (Spring Boot)
```
src/main/java/com/centropokemon/
├── controller/          # REST Controllers
│   ├── BaseRestController.java
│   ├── CentroController.java
│   ├── ConsultaController.java
│   └── PokedexController.java
├── model/              # Entidades JPA
│   ├── Pokemon.java
│   ├── Treinador.java
│   ├── Consulta.java
│   └── Descricao.java
├── repository/         # Repositórios JPA
├── service/           # Lógica de negócio
└── CentroPokemonApplication.java
```

### Frontend (HTML/CSS/JS)
```
src/main/resources/static/
├── css/
│   ├── novo-style.css        # 800+ linhas (global + splash)
│   ├── pokedex-anime.css     # 1200+ linhas (pokédex + animações)
│   └── centro-cura.css       # 900+ linhas (centro + cura)
├── js/
│   ├── pokedex-anime.js      # 750+ linhas (lógica pokédex)
│   ├── animacoes.js          # Navegação
│   └── auth-header.js        # Autenticação
├── imagens/                  # Assets visuais
├── videos/                   # Mídia
├── Pokemon.html              # Landing page
├── pokedex-anime.html        # Pokédex
├── cadastro.html             # Cadastro
└── login.html                # Login
```

## 🎨 Destaques Técnicos

### Animações CSS
- **Entrada 3D**: `rotateY(-15deg)` → `rotateY(0deg)`
- **Loading Pokébolas**: Bounce + rotação 360° + fade out
- **Partículas de Cura**: 15 partículas com movimento vertical
- **Transições**: Cubic-bezier `(0.34, 1.56, 0.64, 1)` para bounce natural

### Performance
- **Atualização Individual**: Cura sem recarregar todos os Pokémon
- **LocalStorage**: Cache de estatísticas e pesquisas
- **Lazy Loading**: Sprites carregados sob demanda
- **Fallback System**: Múltiplas fontes para sprites

### Responsividade
- **Mobile-first**: Breakpoints em 480px, 768px, 1024px, 1200px
- **Grid Adaptativo**: 3 colunas → 1 coluna em mobile
- **Touch-friendly**: Botões com min-height 44px

## 📚 Documentação Adicional

- **JavaDoc**: Gerado em `target/site/apidocs/`
- **Diagramas UML**: Pasta `diagrams/`
- **Changelog**: `CHANGELOG.md`
- **Projeto Visual Paradigm**: `sources/CentroPokemon.vpp`

## 👥 Equipe

Projeto desenvolvido como trabalho final das disciplinas de **Programação**, **Engenharia de Software** e **Banco de Dados** - Ciência da Computação, Unoesc.

**Desenvolvedores:**
- Alexandre Lampert
- Felipe Winter
- Gustavo Pigatto
- Mateus Stock
- Matheus Schvan

## 📄 Licença

Este projeto é acadêmico e foi desenvolvido para fins educacionais.

---

**Pokémon** e todos os nomes relacionados são marcas registradas da Nintendo, Game Freak e Creatures Inc.
