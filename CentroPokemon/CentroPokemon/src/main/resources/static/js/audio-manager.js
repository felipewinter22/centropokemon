// Sistema de gerenciamento de áudio para o Centro Pokémon
class AudioManager {
    constructor() {
        this.sounds = {};
        this.volume = 0.3;
        this.muted = false;
        this.basePath = '/sons/Pokémon Tick-Tock Walk/';
        this.initSounds();
    }

    initSounds() {
        // Sons de interface
        this.sounds = {
            // Básicos (já funcionam)
            btnClick: new Audio(this.basePath + 'btnClick01.mp3'),
            btnClick2: new Audio(this.basePath + 'btnClick02.mp3'),
            hover: new Audio(this.basePath + 'rollOver03.mp3'),
            open: new Audio(this.basePath + 'open.mp3'),
            itemGet: new Audio(this.basePath + 'itemGet.mp3'),
            clear: new Audio(this.basePath + 'clear.mp3'),
            perfect: new Audio(this.basePath + 'perfect.mp3'),
            start: new Audio(this.basePath + 'start.mp3'),
            pointGet: new Audio(this.basePath + 'pointGet.mp3'),
            
            // Tipos principais
            fire: new Audio(this.basePath + 'fire.mp3'),
            water: new Audio(this.basePath + 'water.mp3'),
            grass: new Audio(this.basePath + 'grass.mp3'),
            
            // Sons para outros tipos
            jump: new Audio(this.basePath + 'jump.mp3'),
            warp: new Audio(this.basePath + 'warp.mp3'),
            timeUp: new Audio(this.basePath + 'timeUp.mp3'),
            timeDown: new Audio(this.basePath + 'timeDown.mp3'),
            highscore: new Audio(this.basePath + 'highscore.mp3'),
            hurry: new Audio(this.basePath + 'hurry.mp3'),
            hintOpen: new Audio(this.basePath + 'hintOpen.mp3'),
            hintOver: new Audio(this.basePath + 'hintOver.mp3'),
            rollOver04: new Audio(this.basePath + 'rollOver04.mp3'),
            blockCatch: new Audio(this.basePath + 'blockCatch.mp3'),
            key: new Audio(this.basePath + 'key.mp3')
        };

        // Configurar volume inicial
        Object.values(this.sounds).forEach(sound => {
            sound.volume = this.volume;
        });
        
        // Ajustar volume específico do som de abertura (mais baixo)
        if (this.sounds.open) {
            this.sounds.open.volume = this.volume * 0.5; // 50% do volume padrão
        }
    }

    play(soundName) {
        if (this.muted || !this.sounds[soundName]) return;
        
        const sound = this.sounds[soundName];
        sound.currentTime = 0;
        sound.play().catch(e => console.log('Erro ao tocar som:', e));
    }

    playPokemonCry(pokemonId) {
        if (this.muted) return;
        
        // Formata o ID com zeros à esquerda (ex: 25 -> 025)
        const idFormatted = String(pokemonId).padStart(3, '0');
        
        // Tenta diferentes fontes de cries (cada pasta tem sua geração correspondente)
        const sources = [
            `/sons/cries/cries/Generation 1/SE_PV${idFormatted}.wav`,
            `/sons/cries/cries (2)/Generation 2/SE_PV${idFormatted}.wav`,
            `/sons/cries/cries (3)/Generation 3/SE_PV${idFormatted}.wav`,
            `/sons/cries/cries (4)/Generation 4/SE_PV${idFormatted}.wav`,
            `/sons/cries/cries (5)/Generation 5/SE_PV${idFormatted}.wav`,
            `/sons/cries/cries (6)/Generation 6/SE_PV${idFormatted}.wav`,
            `/sons/cries/cries (7)/Generation 7/SE_PV${idFormatted}.wav`,
            `/sons/cries/cries (8)/Generation 8/SE_PV${idFormatted}.wav`,
            `/sons/cries/cries (9)/Generation 9/SE_PV${idFormatted}.wav`,
            `/sons/cries/cries (10)/Generation 10/SE_PV${idFormatted}.wav`,
            `/sons/cries/cries (11)/Generation 11/SE_PV${idFormatted}.wav`,
            `/sons/cries/cries (12)/Generation 12/SE_PV${idFormatted}.wav`,
            `/sons/cries/cries (13)/Generation 13/SE_PV${idFormatted}.wav`
        ];
        
        const tryNextSource = (index) => {
            if (index >= sources.length) {
                console.log(`Cry do Pokémon ${pokemonId} não encontrado`);
                return;
            }
            
            const cry = new Audio(sources[index]);
            cry.volume = this.volume;
            
            cry.addEventListener('error', () => {
                tryNextSource(index + 1);
            });
            
            cry.play().catch(() => {
                tryNextSource(index + 1);
            });
        };
        
        tryNextSource(0);
    }

    playTypeSound(type) {
        const typeMap = {
            // Tipos com sons específicos
            'fire': 'fire',
            'fogo': 'fire',
            'water': 'water',
            'água': 'water',
            'grass': 'grass',
            'planta': 'grass',
            
            // Outros tipos mapeados para sons existentes
            'electric': 'timeUp',
            'elétrico': 'timeUp',
            'normal': 'open',
            'fighting': 'blockCatch',
            'lutador': 'blockCatch',
            'poison': 'hurry',
            'veneno': 'hurry',
            'ground': 'timeDown',
            'terra': 'timeDown',
            'flying': 'warp',
            'voador': 'warp',
            'psychic': 'hintOpen',
            'psíquico': 'hintOpen',
            'bug': 'rollOver04',
            'inseto': 'rollOver04',
            'rock': 'blockCatch',
            'pedra': 'blockCatch',
            'ghost': 'hintOver',
            'fantasma': 'hintOver',
            'dragon': 'highscore',
            'dragão': 'highscore',
            'dark': 'timeDown',
            'trevas': 'timeDown',
            'steel': 'key',
            'metal': 'key',
            'fairy': 'perfect',
            'fada': 'perfect',
            'ice': 'clear',
            'gelo': 'clear'
        };
        
        const soundName = typeMap[type.toLowerCase()];
        if (soundName) {
            this.play(soundName);
        }
    }

    setVolume(value) {
        this.volume = Math.max(0, Math.min(1, value));
        Object.values(this.sounds).forEach(sound => {
            sound.volume = this.volume;
        });
    }

    toggleMute() {
        this.muted = !this.muted;
        return this.muted;
    }

    // Adicionar sons de hover aos botões
    addHoverSounds() {
        document.querySelectorAll('button, .btn, .pokemon-card').forEach(element => {
            element.addEventListener('mouseenter', () => this.play('hover'));
        });
    }

    // Adicionar sons de click aos botões
    addClickSounds() {
        document.querySelectorAll('button, .btn').forEach(element => {
            element.addEventListener('click', () => this.play('btnClick'));
        });
    }

    // Criar botão de controle de áudio
    createAudioControl() {
        const control = document.createElement('div');
        control.className = 'audio-control';
        control.innerHTML = `
            <div class="audio-panel">
                <input type="range" class="volume-slider" min="0" max="100" value="30" title="Volume">
                <button class="audio-toggle" data-tooltip="Som Ligado">
                    🔊
                </button>
            </div>
        `;
        document.body.appendChild(control);

        const button = control.querySelector('.audio-toggle');
        const slider = control.querySelector('.volume-slider');

        // Controle de mute
        button.addEventListener('click', () => {
            const isMuted = this.toggleMute();
            button.textContent = isMuted ? '🔇' : '🔊';
            button.setAttribute('data-tooltip', isMuted ? 'Som Desligado' : 'Som Ligado');
            button.classList.toggle('muted', isMuted);
            
            // Feedback visual
            button.classList.add('playing');
            setTimeout(() => button.classList.remove('playing'), 300);
        });

        // Controle de volume
        slider.addEventListener('input', (e) => {
            const volume = e.target.value / 100;
            const percent = e.target.value;
            this.setVolume(volume);
            
            // Atualiza o gradiente do slider
            slider.style.background = `linear-gradient(to right, #FF0000 0%, #FF0000 ${percent}%, #444 ${percent}%, #444 100%)`;
        });
    }
}

// Instância global
console.log('[AudioManager] Criando instância global...');
const audioManager = new AudioManager();
window.audioManager = audioManager; // Garante que está no escopo global
console.log('[AudioManager] Instância criada:', audioManager);

// Inicializar sons quando o DOM carregar
document.addEventListener('DOMContentLoaded', () => {
    console.log('[AudioManager] DOM carregado, inicializando sons...');
    audioManager.addHoverSounds();
    audioManager.addClickSounds();
    audioManager.createAudioControl();
    console.log('[AudioManager] Sistema de áudio pronto!');
});
