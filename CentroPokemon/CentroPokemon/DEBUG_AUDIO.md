# Debug do Sistema de Áudio

## Problema: Cries dos Pokémon não estão tocando

### Como Testar

1. **Abra a página de teste:**
   ```
   http://localhost:8080/test-audio.html
   ```

2. **Abra o Console do Navegador:**
   - Chrome/Edge: F12 → Console
   - Firefox: F12 → Console
   - Safari: Cmd+Option+C

3. **Teste na Pokédex:**
   - Abra: `http://localhost:8080/pokedex`
   - Busque um Pokémon (ex: Pikachu)
   - Veja os logs no console

### O que Verificar

#### 1. Logs no Console
Procure por mensagens como:
```
[AudioManager] Tentando tocar cry do Pokémon: 25
[AudioManager] Tentando fonte 1/4: /sons/cries/25.ogg
[AudioManager] Erro ao carregar de /sons/cries/25.ogg: ...
[AudioManager] Tentando fonte 2/4: ...
```

#### 2. Possíveis Problemas

**A. CORS (Cross-Origin Resource Sharing)**
- Sintoma: Erro "CORS policy" no console
- Causa: GitHub/API bloqueando requisições do localhost
- Solução: Usar arquivos locais

**B. Formato de Áudio**
- Sintoma: Erro "Format not supported"
- Causa: Navegador não suporta .ogg
- Solução: Converter para .mp3

**C. URL Incorreta**
- Sintoma: Erro 404
- Causa: ID do Pokémon incorreto ou URL mudou
- Solução: Verificar URL manualmente

**D. Autoplay Bloqueado**
- Sintoma: "play() failed because the user didn't interact"
- Causa: Política de autoplay do navegador
- Solução: Usuário precisa interagir primeiro (já implementado)

### Testes Manuais

#### Teste 1: URL Direta
Abra no navegador:
```
https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/25.ogg
```
- ✅ Se baixar/tocar: API funciona
- ❌ Se der erro: Problema na API

#### Teste 2: Console do Navegador
Cole no console:
```javascript
const audio = new Audio('https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/25.ogg');
audio.play();
```
- ✅ Se tocar: Sistema funciona
- ❌ Se der erro: Veja a mensagem

#### Teste 3: Verificar Rede
1. Abra DevTools → Network
2. Busque um Pokémon
3. Procure por requisições para `.ogg` ou `.mp3`
4. Veja o status (200 = OK, 404 = não encontrado, etc)

### Soluções

#### Solução 1: Usar Arquivos Locais (Recomendado)

1. **Baixe os cries:**
   - Repositório: https://github.com/PokeAPI/cries
   - Ou use: https://veekun.com/dex/downloads

2. **Extraia para:**
   ```
   /sons/cries/
   ├── 1.ogg (Bulbasaur)
   ├── 2.ogg (Ivysaur)
   ├── 25.ogg (Pikachu)
   └── ...
   ```

3. **O sistema já está configurado** para tentar local primeiro!

#### Solução 2: Usar Proxy

Se quiser continuar usando a API, configure um proxy no backend:

```java
@GetMapping("/api/pokemon-cry/{id}")
public ResponseEntity<byte[]> getPokemonCry(@PathVariable int id) {
    String url = "https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/" + id + ".ogg";
    // Fazer requisição e retornar bytes
}
```

#### Solução 3: Desabilitar Cries Temporariamente

No `audio-manager.js`, comente a linha:
```javascript
// audioManager.playPokemonCry(id);
```

### Checklist de Debug

- [ ] Abri o console do navegador
- [ ] Testei a URL direta no navegador
- [ ] Verifiquei os logs do AudioManager
- [ ] Testei com diferentes Pokémon
- [ ] Verifiquei a aba Network
- [ ] Testei em navegador diferente
- [ ] Verifiquei se outros sons funcionam
- [ ] Li as mensagens de erro completas

### Informações Úteis

**URLs de Teste:**
- GitHub: `https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/25.ogg`
- Showdown: `https://play.pokemonshowdown.com/audio/cries/pikachu.mp3`
- Veekun: `https://veekun.com/dex/media/pokemon/cries/25.ogg`

**IDs de Pokémon Comuns:**
- 1: Bulbasaur
- 4: Charmander
- 7: Squirtle
- 25: Pikachu
- 150: Mewtwo

### Próximos Passos

1. Execute os testes acima
2. Anote os erros específicos que aparecem
3. Compartilhe os logs para análise
4. Considere baixar os cries localmente (mais confiável)
