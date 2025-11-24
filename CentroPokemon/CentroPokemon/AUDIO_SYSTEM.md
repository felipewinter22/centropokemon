# Sistema de Áudio - Centro Pokémon

## Visão Geral

Sistema de gerenciamento de áudio integrado ao site do Centro Pokémon, com sons de interface e cries dos Pokémon.

## Arquivos

### JavaScript
- `/js/audio-manager.js` - Gerenciador central de áudio

### CSS
- `/css/audio-controls.css` - Estilos do botão de controle

### Sons
- `/sons/Pokémon Tick-Tock Walk/` - Sons de interface do jogo

## Sons Disponíveis

### Interface
- `btnClick` / `btnClick2` - Cliques em botões
- `hover` - Hover sobre elementos
- `open` - Abrir modais/telas
- `itemGet` - Capturar/obter item
- `clear` - Limpar/resetar
- `perfect` - Ação perfeita/sucesso
- `start` - Iniciar ação
- `pointGet` - Ganhar pontos

### Tipos de Pokémon
- `fire` - Som de tipo Fogo
- `water` - Som de tipo Água
- `grass` - Som de tipo Planta

### Cries dos Pokémon
Os sons dos Pokémon são carregados diretamente da PokéAPI:
```
https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/{ID}.ogg
```

## Uso

### Básico
```javascript
// Tocar som de interface
audioManager.play('btnClick');

// Tocar cry de Pokémon (por ID)
audioManager.playPokemonCry(25); // Pikachu

// Tocar som de tipo
audioManager.playTypeSound('fire');
```

### Controle de Volume
```javascript
// Ajustar volume (0.0 a 1.0)
audioManager.setVolume(0.5);

// Mutar/desmutar
audioManager.toggleMute();
```

### Integração Automática
O sistema adiciona automaticamente:
- Sons de hover em botões e cards
- Sons de click em botões
- Botão de controle de áudio (canto inferior direito)

## Implementação nas Páginas

### Pokédex (`pokedex-anime.html`)
- **Cry do Pokémon**: Toca quando um Pokémon é carregado
- **Som de tipo**: Toca ao filtrar por tipo
- **Som de captura**: Toca ao cadastrar Pokémon
- **Som de sucesso**: Toca quando cadastro é bem-sucedido

### Outras Páginas
- **Hover**: Todos os botões e cards
- **Click**: Todos os botões

## Controle de Áudio

Um botão flutuante aparece no canto inferior direito de todas as páginas:
- 🔊 - Som ligado
- 🔇 - Som desligado

## Personalização

### Adicionar Novos Sons
1. Adicione o arquivo na pasta `/sons/Pokémon Tick-Tock Walk/`
2. Registre no `audio-manager.js`:
```javascript
this.sounds = {
    // ... sons existentes
    meuSom: new Audio(this.basePath + 'meu-som.mp3')
};
```

### Usar em Código Customizado
```javascript
// Certifique-se que o audioManager está disponível
if (window.audioManager) {
    audioManager.play('meuSom');
}
```

## Notas Técnicas

- Volume padrão: 30% (0.3)
- Sons são pré-carregados na inicialização
- Cries dos Pokémon são carregados sob demanda
- Erros de áudio são silenciados (não quebram a aplicação)
- Estado de mute não é persistido (reseta ao recarregar)

## Melhorias Futuras

- [ ] Persistir estado de mute no localStorage
- [ ] Controle de volume deslizante
- [ ] Música de fundo (tema do Centro Pokémon)
- [ ] Sons específicos para cada tipo de Pokémon
- [ ] Efeitos sonoros para animações
- [ ] Preload dos cries mais populares
