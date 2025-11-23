# 🏥 CentroPokemon - Sistema de Gestão de Saúde Pokémon

![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=java&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-F2F4F9?style=for-the-badge&logo=spring-boot)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Visual Paradigm](https://img.shields.io/badge/Visual_Paradigm-FF6F00?style=for-the-badge&logo=visual-paradigm&logoColor=white)

Sistema completo para gestão de centros de saúde Pokémon, desenvolvido em Java com Spring Boot.

## 📊 Diagramas do Sistema

### 📁 Estrutura de Diagramas
diagrams/
├── Activity Diagram1.png # Fluxo de atividades do sistema
├── Class Diagram1.png # Diagrama de classes UML
├── Sequence Diagram1.png # Diagrama de sequência
├── Use Case Diagram1.png # Casos de uso
└── Estados de saúde do Pokémon.png # Diagrama de estados

text

### 🗂️ Arquivos Originais
sources/
└── CentroPokemon.vpp # Projeto original Visual Paradigm

text

## 🚀 Funcionalidades

- **Gestão de Pokémon** - Cadastro e controle de Pokémon pacientes
- **Sistema de Saúde** - Acompanhamento de estados de saúde
- **Tratamento Automatizado** - Fluxos de cura e recuperação
- **API REST** - Endpoints para integração
- **Banco de Dados** - Persistência com MySQL

## 🏗️ Arquitetura

### Tecnologias Utilizadas
- **Backend**: Java + Spring Boot
- **Banco de Dados**: MySQL
- **ORM**: Spring Data JPA
- **Documentação**: Diagramas UML com Visual Paradigm
- **Controle de Versão**: Git + GitHub

### Estrutura do Projeto
CentroPokemon/
├── src/
│ └── main/java/ # Código fonte Java
├── db/
│ └── schema.sql # Esquema do banco de dados
├── diagrams/ # Documentação UML
├── sources/ # Arquivos originais
└── docs/ # Documentação adicional

text

## 📋 Pré-requisitos

- Java 17 ou superior
- MySQL 8.0+
- Maven 3.6+
- Visual Paradigm (para edição dos diagramas)

## 🔧 Instalação e Configuração

1. **Clone o repositório**
```bash
git clone https://github.com/felipewinter22/centropokemon.git
cd centropokemon
Configure o banco de dados

bash
# Execute o script schema.sql no MySQL
mysql -u root -p < db/schema.sql
Configure as variáveis de ambiente

properties
# application.properties
spring.datasource.url=jdbc:mysql://localhost:3306/centropokemon
spring.datasource.username=seu_usuario
spring.datasource.password=sua_senha
Execute a aplicação

bash
mvn spring-boot:run
🎯 Endpoints Principais
Método	Endpoint	Descrição
GET	/api/pokemons	Lista todos os Pokémon
POST	/api/pokemons	Cadastra novo Pokémon
PUT	/api/pokemons/{id}/tratar	Aplica tratamento
GET	/api/pokemons/{id}/estado	Consulta estado de saúde
📊 Modelo de Dados
Entidades Principais
Pokemon: Dados básicos do Pokémon

Tratamento: Histórico de tratamentos

EstadoSaude: Controle de estados de saúde

Centro: Informações do centro Pokémon

🗺️ Fluxo do Sistema
Cadastro → Pokémon é registrado no sistema

Avaliação → Estado de saúde é diagnosticado

Tratamento → Fluxo de cura é aplicado

Monitoramento → Evolução é acompanhada

Alta → Pokémon é liberado quando curado

👥 Desenvolvimento
Equipe
Desenvolvedor: Matheus Schvan

Diagramação: Visual Paradigm Community Edition

Metodologia
Desenvolvimento Ágil

Versionamento com Git

Documentação com UML

Code Review

📝 Licença
Este projeto é para fins educacionais e não comerciais, desenvolvido com Visual Paradigm Community Edition.

🤝 Contribuições
Contribuições são bem-vindas! Por favor:

Fork o projeto

Crie uma branch para sua feature

Commit suas mudanças

Push para a branch

Abra um Pull Request

📞 Contato
GitHub: felipewinter22

Repositório: CentroPokemon

Desenvolvido com ❤️ para a comunidade Pokémon

text

### **4. Commit Corretamente:**
- **Mensagem do commit:** `"docs: adiciona README profissional completo"`
- **Clique:** `"Commit new file"`

## 🎯 **Dicas para Não Dar Erro:**
- **Copie TODO o texto acima** de uma vez
- **Cole TODO de uma vez** no GitHub
- **Não edite** - já está formatado corretamente
- **Use exatamente este conteúdo**

