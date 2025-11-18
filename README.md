# Centro Pokémon

Bem-vindo ao repositório do **Centro Pokémon**, um projeto desenvolvido em **Java** utilizando **Maven**, com modelagem feita no **Visual Paradigm**, banco de dados gerenciado no **DBeaver**, e desenvolvimento realizado no **Eclipse** e **VS Code**.

Este README serve como guia completo do projeto, contendo visão geral, estrutura, execução, diagramas, arquitetura e links úteis.

---

## 📌 Sobre o Projeto

O **Centro Pokémon** é uma aplicação construída para gerenciar treinadores, Pokémons e suas relações, seguindo boas práticas de desenvolvimento orientado a objetos e padrões de projeto. O objetivo principal é criar um sistema modular, escalável e bem documentado.

---

## 🧰 Tecnologias Utilizadas

### **Backend**

* **Java 17+**
* **Maven** (gerenciador de dependências)
* **JPA / Hibernate** (mapeamento objeto-relacional)
* **Jakarta Persistence**

### **Banco de Dados**

* **PostgreSQL**
* **DBeaver** para administração e consultas

### **Modelagem UML**

* **Visual Paradigm (.vpp)**

  * Diagramas presentes no repositório

### **Ambiente de Desenvolvimento**

* **Eclipse IDE**
* **Visual Studio Code**

---

## 📂 Estrutura do Projeto

```
/centro-pokemon
├── src/main/java
│   ├── com.centropokemon.model
│   ├── com.centropokemon.repository
│   ├── com.centropokemon.service
│   └── com.centropokemon.controller
├── src/main/resources
│   └── application.properties
├── diagramas/
│   └── centro_pokemon.vpp
├── pom.xml
└── README.md
```

---

## ⚙️ Configuração e Execução

### **1. Clonar o Repositório**

```bash
git clone https://github.com/felipewinter22/pokemonprojeto.git
cd centro-pokemon
```

### **2. Importar no Eclipse ou VS Code**

* Abrir a pasta do projeto
* Eclipse: *File > Import > Maven > Existing Maven Project*
* VS Code: basta abrir a pasta com a extensão Java instalada

### **3. Configurar Banco de Dados no PostgreSQL**

Crie o banco:

```sql
CREATE DATABASE centro_pokemon;
```

Edite `application.properties`:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/centro_pokemon
spring.datasource.username=seu_usuario
spring.datasource.password=sua_senha
spring.jpa.hibernate.ddl-auto=update
```

### **4. Executar o Projeto**

No Eclipse ou VS Code:

* Executar a classe principal
  ou

```bash
mvn spring-boot:run
```

---

## 🗂️ Diagramas (VPP)

No diretório `diagramas/` você encontrará:

* **Diagrama de Classes**
* **Diagrama ER**
* **Diagrama de Casos de Uso**
* **Diagrama de Sequência**
* Arquivo completo `centro_pokemon.vpp` para edição no Visual Paradigm

---

## 🧱 Arquitetura

O projeto segue uma arquitetura separada em camadas:

### **Model**

Contém entidades JPA como:

* `Treinador`
* `Pokemon`
  

### **Repository**

Interfaces JPA usadas para persistência.

### **Service**

Regras de negócio e validações.

### **Controller**

API endpoints.

---

## 📌 Funcionalidades

* Cadastro de Treinadores
* Cadastro de Pokémon
* Associação Treinador ↔ Pokémon
* Listagens, buscas e filtros

---

## 🔗 Links Úteis

* Visual Paradigm: [https://www.visual-paradigm](https://www.visual-paradigm)
