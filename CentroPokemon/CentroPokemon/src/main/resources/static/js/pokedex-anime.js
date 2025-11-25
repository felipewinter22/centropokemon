/**
 * Centro Pokémon - Lógica da Pokédex
 * ===================================
 * @file        pokedex-anime.js
 * @author      Gustavo Pigatto, Matheus Schvann, Alexandre Lampert, Mateus Stock, Felipe Winter
 * @version     1.1
 * @date        23/11/2025
 * @summary     Lógica da Pokédex estilo anime
 * @description Controla busca, navegação, filtros, estado e integração com a API.
 * @api         GET /CentroPokemon/api/pokemons/{id|nome},
 *              GET /CentroPokemon/api/pokemons/random,
 *              GET /CentroPokemon/api/pokemons/type/{tipo}/random
 * @storage     pokedex_anime_stats, pokedex_anime_search_counts, pokedex_anime_recent
 */
const PokedexAnime = (() => {
    const config = {
        apiBaseUrl: '/api/pokemons',
        totalPokemon: 898,
        localStorageKey: 'pokedex_anime_stats',
        defaultPokemon: 25,
        searchCountsKey: 'pokedex_anime_search_counts',
        recentKey: 'pokedex_anime_recent',
        trainerApiBaseUrl: '/api/treinadores',
        trainerIdKey: 'treinador_id'
    };

    let state = {
        currentPokemon: null,
        currentPokemonId: config.defaultPokemon,
        viewedPokemon: new Set(),
        caughtPokemon: new Set(),
        activeTypeFilter: null,
        isLoading: false,
        searchCounts: {},
        recentViewed: []
    };

    const elements = {
        pokemonNumber: document.getElementById('pokemon-number'),
        pokemonName: document.getElementById('pokemon-name'),
        pokemonSprite: document.getElementById('pokemon-sprite'),
        pokemonTypes: document.getElementById('pokemon-types'),
        pokemonHeight: document.getElementById('pokemon-height'),
        pokemonWeight: document.getElementById('pokemon-weight'),
        pokemonAbility: document.getElementById('pokemon-ability'),
        pokemonDescription: document.getElementById('pokemon-description'),
        searchInput: document.getElementById('pokemon-search'),
        searchBtn: document.getElementById('search-btn'),
        prevBtn: document.getElementById('prev-btn'),
        nextBtn: document.getElementById('next-btn'),
        randomBtn: document.getElementById('random-btn'),
        clearBtn: document.getElementById('clear-btn'),
        registerBtn: document.getElementById('register-btn'),
        typeButtons: document.querySelectorAll('.type-btn, .type-chip'),
        totalPokemon: document.getElementById('total-pokemon'),
        viewedPokemon: document.getElementById('viewed-pokemon'),
        caughtPokemon: document.getElementById('caught-pokemon'),
        lights: document.querySelectorAll('.light'),
        popularList: document.getElementById('popular-list'),
        dailyList: document.getElementById('daily-list'),
        capturedGrid: document.getElementById('captured-grid'),
        tipCard: document.getElementById('tip-card')
    };

    /**
     * @function   init
     * @summary    Inicializa a Pokédex: stats, eventos, Pokémon padrão e sidebars
     */
    const init = async () => {
        loadStats();
        setupEventListeners();
        elements.totalPokemon && (elements.totalPokemon.textContent = config.totalPokemon);
        await loadPokemon(config.defaultPokemon);
        updateLightsAnimation();
        renderCapturedGrid();
        renderTip();
    };

    const setupEventListeners = () => {
        const on = (el, evt, handler) => { if (el) el.addEventListener(evt, handler); };
        on(elements.searchBtn, 'click', handleSearch);
        if (elements.searchInput) {
            elements.searchInput.addEventListener('keypress', (e) => {
                if (e.key === 'Enter') handleSearch();
            });
        }
        on(elements.prevBtn, 'click', () => navigatePokemon(-1));
        on(elements.nextBtn, 'click', () => navigatePokemon(1));
        on(elements.randomBtn, 'click', loadRandomPokemon);
        on(elements.clearBtn, 'click', clearCurrentPokemon);
        on(elements.registerBtn, 'click', registerPokemon);
        elements.typeButtons && elements.typeButtons.forEach(btn => {
            btn.addEventListener('click', () => handleTypeFilter(btn.dataset.type));
        });
    };

    const loadStats = () => {
        try {
            const savedStats = localStorage.getItem(config.localStorageKey);
            if (savedStats) {
                const stats = JSON.parse(savedStats);
                state.viewedPokemon = new Set(stats.viewed || []);
                state.caughtPokemon = new Set(stats.caught || []);
                updateStatsDisplay();
            }
            const savedCounts = localStorage.getItem(config.searchCountsKey);
            if (savedCounts) {
                state.searchCounts = JSON.parse(savedCounts) || {};
            }
            const savedRecent = localStorage.getItem(config.recentKey);
            if (savedRecent) {
                state.recentViewed = JSON.parse(savedRecent) || [];
            }
            updateSidebar();
        } catch {}
    };

    const saveStats = () => {
        try {
            const stats = {
                viewed: Array.from(state.viewedPokemon),
                caught: Array.from(state.caughtPokemon),
                lastUpdated: new Date().toISOString()
            };
            localStorage.setItem(config.localStorageKey, JSON.stringify(stats));
        } catch {}
    };

    const updateStatsDisplay = () => {
        if (elements.viewedPokemon) elements.viewedPokemon.textContent = state.viewedPokemon.size;
        if (elements.caughtPokemon) elements.caughtPokemon.textContent = state.caughtPokemon.size;
        if (elements.totalPokemon) elements.totalPokemon.textContent = config.totalPokemon;
    };

    const saveSearchCounts = () => {
        try { localStorage.setItem(config.searchCountsKey, JSON.stringify(state.searchCounts)); } catch {}
    };

    const saveRecent = () => {
        try { localStorage.setItem(config.recentKey, JSON.stringify(state.recentViewed)); } catch {}
    };

    const incrementSearchCount = (id, name) => {
        const key = String(id);
        const current = state.searchCounts[key] || { count: 0, name: '' };
        current.count += 1;
        if (name) current.name = name;
        state.searchCounts[key] = current;
        saveSearchCounts();
    };

    const addRecent = (pokemon) => {
        const id = pokemon.pokeApiId || pokemon.id;
        const name = (pokemon.nomePt || pokemon.nomeEn || '').toUpperCase();
        state.recentViewed = state.recentViewed.filter(r => r.id !== id);
        state.recentViewed.unshift({ id, name });
        state.recentViewed = state.recentViewed.slice(0, 10);
        saveRecent();
    };

    const updateSidebar = () => {
        console.log('[Pokedex] updateSidebar chamado');
        
        if (elements.popularList) {
            const entries = Object.entries(state.searchCounts)
                .map(([id, info]) => ({ id, name: info.name || `#${String(id).padStart(3,'0')}`, count: info.count }))
                .sort((a, b) => b.count - a.count)
                .slice(0, 10);
            elements.popularList.innerHTML = entries.map(e => `
                <li data-pokemon-id="${e.id}" class="clickable-pokemon">
                    <span>${e.name}</span>
                    <span class="count">${e.count}</span>
                </li>
            `).join('');
            
            // Adiciona event listeners para os itens clicáveis
            elements.popularList.querySelectorAll('.clickable-pokemon').forEach(item => {
                item.addEventListener('click', () => {
                    const pokemonId = item.dataset.pokemonId;
                    if (pokemonId) {
                        loadPokemon(pokemonId);
                    }
                });
            });
        }
    };
    const renderCapturedGrid = async () => {
        if (!elements.capturedGrid) return;
        const trainerId = localStorage.getItem(config.trainerIdKey);
        if (trainerId) {
            try {
                const res = await fetch(`${config.trainerApiBaseUrl}/${trainerId}/pokemons`);
                if (res.ok) {
                    const lista = await res.json();
                    const items = lista.slice(-12).reverse();
                    elements.capturedGrid.innerHTML = items.map((p) => {
                        const id = p.pokeApiId || p.id;
                        const sprite = p.spriteUrl || (id ? `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${id}.png` : '');
                        return `<div class="sprite-item clickable-pokemon" data-pokemon-id="${id}" title="Clique para ver">
                            <img src="${sprite}" alt="#${String(id||0).padStart(3,'0')}">
                        </div>`;
                    }).join('');
                    
                    // Adiciona event listeners para os sprites clicáveis
                    elements.capturedGrid.querySelectorAll('.clickable-pokemon').forEach(item => {
                        item.addEventListener('click', () => {
                            const pokemonId = item.dataset.pokemonId;
                            if (pokemonId) {
                                loadPokemon(pokemonId);
                            }
                        });
                    });
                    
                    state.caughtPokemon = new Set(lista.map(p => p.pokeApiId || p.id).filter(Boolean));
                    updateStatsDisplay();
                    return;
                }
            } catch {}
        }
        const ids = Array.from(state.caughtPokemon).slice(-12).reverse();
        elements.capturedGrid.innerHTML = ids.map((id) => {
            const url = `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${id}.png`;
            return `<div class="sprite-item clickable-pokemon" data-pokemon-id="${id}" title="Clique para ver">
                <img src="${url}" alt="#${String(id).padStart(3,'0')}">
            </div>`;
        }).join('');
        
        // Adiciona event listeners para os sprites clicáveis
        elements.capturedGrid.querySelectorAll('.clickable-pokemon').forEach(item => {
            item.addEventListener('click', () => {
                const pokemonId = item.dataset.pokemonId;
                if (pokemonId) {
                    loadPokemon(pokemonId);
                }
            });
        });
    };

    const handleSearch = async () => {
        const searchTerm = elements.searchInput.value.trim();
        if (!searchTerm) return;
        await loadPokemon(searchTerm);
    };

    const fetchJson = async (url) => {
        console.log('[Pokedex] Buscando:', url);
        const res = await fetch(url);
        console.log('[Pokedex] Status:', res.status, res.statusText);
        if (!res.ok) {
            console.error('[Pokedex] Erro na requisição:', res.status, res.statusText);
            throw new Error(`Erro na requisição: ${res.status}`);
        }
        const data = await res.json();
        console.log('[Pokedex] Dados recebidos:', data);
        return data;
    };

    const postJson = async (url, body) => {
        const res = await fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
        if (!res.ok) throw new Error('Erro na requisição');
        return res.json();
    };

    const loginTrainer = async (usuarioOuEmail, senha) => {
        const data = await postJson(`${config.trainerApiBaseUrl}/login`, { usuarioOuEmail, senha });
        return data;
    };

    const registerTrainer = async (nome, usuario, email, senha, telefone) => {
        const data = await postJson(`${config.trainerApiBaseUrl}/cadastrar`, { nome, usuario, email, senha, telefone });
        return data;
    };

    const ensureTrainerId = async () => {
        const cached = localStorage.getItem(config.trainerIdKey);
        if (cached) return parseInt(cached, 10);
        let usuarioOuEmail = window.prompt('Digite usuário ou e-mail do treinador:');
        let senha = window.prompt('Digite a senha:');
        if (!usuarioOuEmail || !senha) return null;
        try {
            const t = await loginTrainer(usuarioOuEmail, senha);
            if (t && t.id) {
                localStorage.setItem(config.trainerIdKey, String(t.id));
                showNotification('Login realizado');
                return t.id;
            }
        } catch {}
        const nome = window.prompt('Não encontrado. Informe seu nome para cadastrar:');
        const usuario = window.prompt('Escolha um nome de usuário:') || usuarioOuEmail;
        const email = window.prompt('Informe seu e-mail:') || usuarioOuEmail;
        if (!nome || !usuario || !email) return null;
        try {
            const t = await registerTrainer(nome, usuario, email, senha, null);
            if (t && t.id) {
                localStorage.setItem(config.trainerIdKey, String(t.id));
                showNotification('Cadastro realizado');
                return t.id;
            }
        } catch {}
        return null;
    };

    /**
     * @function   loadPokemon
     * @param      {number|string} identifier ID ou nome de Pokémon
     * @summary    Busca Pokémon na API e atualiza estado/UI
     */
    const loadPokemon = async (identifier) => {
        if (state.isLoading) return;
        state.isLoading = true;
        showLoadingState(true);
        
        const startTime = Date.now();
        const minLoadingTime = 1000; // 1 segundo
        
        try {
            const data = await fetchJson(`${config.apiBaseUrl}/${identifier}`);
            
            // Calcula quanto tempo falta para completar 1 segundo
            const elapsedTime = Date.now() - startTime;
            const remainingTime = Math.max(0, minLoadingTime - elapsedTime);
            
            // Aguarda o tempo restante antes de mostrar o resultado
            await new Promise(resolve => setTimeout(resolve, remainingTime));
            
            state.currentPokemon = data;
            state.currentPokemonId = data.pokeApiId || data.id || state.currentPokemonId;
            state.viewedPokemon.add(state.currentPokemonId);
            updatePokemonDisplay();
            updateStatsDisplay();
            saveStats();
            incrementSearchCount(state.currentPokemonId, (data.nomePt || data.nomeEn || '').toUpperCase());
            addRecent(data);
            updateSidebar();
            renderCapturedGrid();
        } catch (error) {
            // Log do erro para debug
            console.error('[Pokedex] Erro ao carregar Pokémon:', error);
            console.error('[Pokedex] Identifier:', identifier);
            
            // Aguarda o tempo mínimo mesmo em caso de erro
            const elapsedTime = Date.now() - startTime;
            const remainingTime = Math.max(0, minLoadingTime - elapsedTime);
            await new Promise(resolve => setTimeout(resolve, remainingTime));
            
            // Silencia erro visualmente - apenas limpa a tela
            clearCurrentPokemon();
        } finally {
            state.isLoading = false;
            showLoadingState(false);
        }
    };

    const getDescription = (pokemon) => {
        if (!pokemon || !pokemon.descricoes || !pokemon.descricoes.length) return null;
        const d = pokemon.descricoes[0];
        return d.descricaoPt || d.descricaoEn || null;
    };

    /**
     * @function   updatePokemonDisplay
     * @summary    Atualiza tela com dados do Pokémon atual
     */
    const updatePokemonDisplay = () => {
        if (!state.currentPokemon) return;
        const p = state.currentPokemon;
        const id = p.pokeApiId || p.id;
        const name = (p.nomePt || p.nomeEn || '').toUpperCase();
        const sprite = p.spriteUrl || '';
        const tipos = Array.isArray(p.tipos) ? p.tipos.map(t => (t.nomePt || t.nome || t.nomeEn || '').toUpperCase()) : [];
        
        // Toca o cry do Pokémon
        console.log('[Pokedex] Tentando tocar cry do Pokémon ID:', id);
        console.log('[Pokedex] audioManager existe?', !!window.audioManager);
        if (window.audioManager && id) {
            console.log('[Pokedex] Chamando playPokemonCry...');
            audioManager.playPokemonCry(id);
        } else {
            console.warn('[Pokedex] audioManager não disponível ou ID inválido');
        }

        elements.pokemonNumber.textContent = `#${String(id || 0).padStart(3, '0')}`;
        elements.pokemonName.textContent = name || '------';
        
        // Sistema de fallback para sprites com múltiplas fontes
        const tries = [];
        const idStr3 = String(id || 0).padStart(3, '0');
        const nomeLower = (p.nomeEn || '').toLowerCase();
        
        // Ordem de prioridade das fontes de imagem
        if (sprite && sprite.length && sprite.startsWith('http')) tries.push(sprite);
        tries.push(`https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${id}.png`);
        tries.push(`https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${id}.png`);
        if (nomeLower) tries.push(`https://img.pokemondb.net/artwork/large/${nomeLower}.jpg`);
        tries.push(`https://assets.pokemon.com/assets/cms2/img/pokedex/full/${idStr3}.png`);
        tries.push('/imagens/pokebola.png'); // Fallback final local
        
        let idx = 0;
        elements.pokemonSprite.onerror = () => {
            idx += 1;
            if (idx < tries.length) {
                elements.pokemonSprite.src = tries[idx];
            } else {
                // Fallback final: imagem padrão
                elements.pokemonSprite.onerror = null;
                elements.pokemonSprite.src = '/imagens/pokebola.png';
            }
        };
        elements.pokemonSprite.src = tries[0];
        elements.pokemonSprite.alt = name;

        elements.pokemonTypes.textContent = tipos.length ? tipos.join(' / ') : '------';
        elements.pokemonTypes.className = 'value';
        tipos.forEach(type => {
            elements.pokemonTypes.classList.add(`type-${type.toLowerCase()}`);
        });

        const stats = p.stats || {};
        const altura = (typeof p.altura === 'number' && !isNaN(p.altura)) ? `${p.altura.toFixed(1)}m` : 'N/D';
        const peso = (typeof p.peso === 'number' && !isNaN(p.peso)) ? `${p.peso.toFixed(1)}kg` : 'N/D';
        const habilidade = (Array.isArray(p.habilidades) && p.habilidades.length > 0) ? String(p.habilidades[0]).toUpperCase() : 'N/D';
        elements.pokemonHeight.textContent = altura;
        elements.pokemonWeight.textContent = peso;
        elements.pokemonAbility.textContent = habilidade;

        const desc = getDescription(p) || 'Descrição não disponível.';
        elements.pokemonDescription.textContent = desc;

        if (elements.searchInput) elements.searchInput.value = '';
        updateLightsAnimation();
        bumpMission('view_5', 1);
        const tiposLower = tipos.map(t => t.toLowerCase());
        if (tiposLower.includes('água') || tiposLower.includes('agua') || tiposLower.includes('water')) {
            bumpMission('type_water', 1);
        }
    };

    const navigatePokemon = (direction) => {
        if (window.audioManager) audioManager.play('btnClick2');
        const base = state.currentPokemonId || config.defaultPokemon;
        let newId = base + direction;
        if (newId < 1) newId = config.totalPokemon;
        if (newId > config.totalPokemon) newId = 1;
        loadPokemon(newId);
    };

    const loadRandomPokemon = async () => {
        if (state.isLoading) return;
        state.isLoading = true;
        showLoadingState(true);
        
        const startTime = Date.now();
        const minLoadingTime = 1000; // 1 segundo
        
        try {
            const data = await fetchJson(`${config.apiBaseUrl}/random`);
            
            // Calcula quanto tempo falta para completar 1 segundo
            const elapsedTime = Date.now() - startTime;
            const remainingTime = Math.max(0, minLoadingTime - elapsedTime);
            
            // Aguarda o tempo restante antes de mostrar o resultado
            await new Promise(resolve => setTimeout(resolve, remainingTime));
            
            state.currentPokemon = data;
            state.currentPokemonId = data.pokeApiId || data.id || state.currentPokemonId;
            state.viewedPokemon.add(state.currentPokemonId);
            updatePokemonDisplay();
            updateStatsDisplay();
            saveStats();
            incrementSearchCount(state.currentPokemonId, (data.nomePt || data.nomeEn || '').toUpperCase());
            addRecent(data);
            updateSidebar();
            renderCapturedGrid();
        } catch {
            // Aguarda o tempo mínimo mesmo em caso de erro
            const elapsedTime = Date.now() - startTime;
            const remainingTime = Math.max(0, minLoadingTime - elapsedTime);
            await new Promise(resolve => setTimeout(resolve, remainingTime));
            
            // Silencia erro - apenas limpa a tela
            clearCurrentPokemon();
        } finally {
            state.isLoading = false;
            showLoadingState(false);
        }
    };

    const clearCurrentPokemon = () => {
        state.currentPokemon = null;
        state.currentPokemonId = config.defaultPokemon;
        elements.pokemonNumber.textContent = '#000';
        elements.pokemonName.textContent = '------';
        elements.pokemonSprite.src = '';
        elements.pokemonSprite.alt = '';
        elements.pokemonTypes.textContent = '------';
        elements.pokemonTypes.className = 'value';
        elements.pokemonHeight.textContent = 'N/D';
        elements.pokemonWeight.textContent = 'N/D';
        elements.pokemonAbility.textContent = 'N/D';
        elements.pokemonDescription.textContent = 'Use a busca para encontrar um Pokémon.';
        updateLightsAnimation();
    };

    const registerPokemon = async () => {
        if (!state.currentPokemon) { showError('Nenhum Pokémon para cadastrar!'); return; }
        const trainerId = localStorage.getItem(config.trainerIdKey);
        if (!trainerId) { 
            showNotification('Faça login para cadastrar Pokémon!');
            setTimeout(() => { window.location.href = '/login.html'; }, 1500);
            return; 
        }
        
        // Toca som de captura
        if (window.audioManager) {
            audioManager.play('itemGet');
        }
        
        showLoadingState(true);
        
        try {
            const p = state.currentPokemon;
            const id = p.pokeApiId || p.id;
            
            console.log('[Register] Pokémon atual:', p);
            console.log('[Register] ID:', id);
            console.log('[Register] Sprite original:', p.spriteUrl);
            
            // Pega a imagem que está sendo exibida na Pokédex neste momento
            const displayedSprite = elements.pokemonSprite ? elements.pokemonSprite.src : '';
            console.log('[Register] Sprite exibido na tela:', displayedSprite);
            
            // Garante que a spriteUrl está correta - prioriza a que está sendo exibida
            let sprite = displayedSprite || p.spriteUrl || '';
            if (!sprite || !sprite.startsWith('http')) {
                sprite = `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${id}.png`;
            }
            
            console.log('[Register] Sprite final:', sprite);
            
            // Prepara os dados para cadastro usando HP real da Pokédex
            // Pega o HP dos stats ou usa 100 como padrão
            const vidaMaxima = (p.stats && p.stats.hp) ? p.stats.hp : 100;
            // Vida atual aleatória entre 50-100% do HP máximo
            const vidaAtual = Math.floor(Math.random() * (vidaMaxima * 0.5)) + Math.floor(vidaMaxima * 0.5);
            
            console.log('[Register] HP Máximo:', vidaMaxima, 'HP Atual:', vidaAtual);
            
            const body = {
                pokeApiId: id,
                nomePt: p.nomePt || p.nomeEn || '',
                nomeEn: p.nomeEn || p.nomePt || '',
                spriteUrl: sprite,
                vidaAtual: vidaAtual,
                vidaMaxima: vidaMaxima,
                nivel: 1,
                habilidades: Array.isArray(p.habilidades) ? p.habilidades : [],
                tipos: Array.isArray(p.tipos) ? p.tipos.map(t => t.nomeEn || t.nomePt || t.nome || '').filter(Boolean) : []
            };
            
            console.log('[Register] Body enviado:', body);
            
            // Cadastra direto no backend
            const response = await fetch(`${config.trainerApiBaseUrl}/${trainerId}/pokemons`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(body)
            });
            
            if (!response.ok) {
                if (response.status === 409) {
                    showNotification('Você já possui este Pokémon!');
                    return;
                }
                throw new Error('Erro ao cadastrar');
            }
            
            const result = await response.json();
            console.log('[Register] Resposta do servidor:', result);
            
            // Toca som de sucesso
            if (window.audioManager) {
                audioManager.play('perfect');
            }
            
            // Salva dados para a tela de sucesso - usa o sprite que veio do servidor
            const successData = {
                nome: result.nomePt || p.nomePt || p.nomeEn || '',
                sprite: result.spriteUrl || sprite,
                id: result.pokeApiId || id
            };
            
            console.log('[Register] Dados de sucesso:', successData);
            localStorage.setItem('pokedex_register_success', JSON.stringify(successData));
            
            // Atualiza estatísticas
            state.caughtPokemon.add(id);
            saveStats();
            
            // Redireciona para tela de sucesso
            document.body.classList.add('page-leave');
            document.body.classList.add('page-leave-active');
            setTimeout(() => { window.location.href = '/pokedex/cadastrar'; }, 200);
            
        } catch (error) {
            showNotification('Erro ao cadastrar Pokémon. Tente novamente.');
            console.error('Erro ao cadastrar:', error);
        } finally {
            showLoadingState(false);
        }
    };

    const handleTypeFilter = (type) => {
        if (state.activeTypeFilter === type) {
            state.activeTypeFilter = null;
            elements.typeButtons.forEach(btn => btn.classList.remove('active'));
            showNotification('Filtro removido');
        } else {
            state.activeTypeFilter = type;
            elements.typeButtons.forEach(btn => {
                btn.classList.toggle('active', btn.dataset.type === type);
            });
            // Toca som do tipo
            if (window.audioManager) {
                audioManager.playTypeSound(type);
            }
            showNotification(`Filtrando por: ${type.toUpperCase()}`);
            loadRandomPokemonByType(type);
        }
    };

    /**
     * @function   loadRandomPokemonByType
     * @param      {string} type Tipo Pokémon (ex.: 'fire')
     * @summary    Carrega Pokémon aleatório do tipo selecionado
     */
    const loadRandomPokemonByType = async (type) => {
        if (state.isLoading) return;
        state.isLoading = true;
        showLoadingState(true);
        
        const startTime = Date.now();
        const minLoadingTime = 2000; // 2 segundos
        
        try {
            const data = await fetchJson(`${config.apiBaseUrl}/type/${type}/random`);
            
            // Calcula quanto tempo falta para completar 2 segundos
            const elapsedTime = Date.now() - startTime;
            const remainingTime = Math.max(0, minLoadingTime - elapsedTime);
            
            // Aguarda o tempo restante antes de mostrar o resultado
            await new Promise(resolve => setTimeout(resolve, remainingTime));
            
            state.currentPokemon = data;
            state.currentPokemonId = data.pokeApiId || data.id || state.currentPokemonId;
            state.viewedPokemon.add(state.currentPokemonId);
            updatePokemonDisplay();
            updateStatsDisplay();
            saveStats();
            incrementSearchCount(state.currentPokemonId, (data.nomePt || data.nomeEn || '').toUpperCase());
            addRecent(data);
            updateSidebar();
            renderCapturedGrid();
        } catch {
            // Aguarda o tempo mínimo mesmo em caso de erro
            const elapsedTime = Date.now() - startTime;
            const remainingTime = Math.max(0, minLoadingTime - elapsedTime);
            await new Promise(resolve => setTimeout(resolve, remainingTime));
            
            // Silencia erro - apenas limpa a tela
            clearCurrentPokemon();
        } finally {
            state.isLoading = false;
            showLoadingState(false);
        }
    };

    const showLoadingState = (isLoading) => {
        const screen = document.querySelector('.pokedex-screen');
        if (!screen) return;
        
        if (isLoading) {
            screen.classList.add('loading');
            if (elements.searchBtn) elements.searchBtn.disabled = true;
            if (elements.randomBtn) elements.randomBtn.disabled = true;
            
            // Cria as Pokébolas de loading
            const loader = document.createElement('div');
            loader.className = 'pokeball-loader';
            loader.innerHTML = `
                <div class="pokeball"></div>
                <div class="pokeball"></div>
                <div class="pokeball"></div>
            `;
            screen.appendChild(loader);
            
            // Adiciona efeito de "escaneamento" nas luzes
            if (elements.lights && elements.lights.length > 0) {
                elements.lights.forEach((light, index) => {
                    setTimeout(() => {
                        light.classList.add('scanning');
                    }, index * 100);
                });
            }
        } else {
            screen.classList.remove('loading');
            if (elements.searchBtn) elements.searchBtn.disabled = false;
            if (elements.randomBtn) elements.randomBtn.disabled = false;
            
            // Remove as Pokébolas de loading
            const loader = screen.querySelector('.pokeball-loader');
            if (loader) loader.remove();
            
            // Remove efeito de escaneamento
            if (elements.lights && elements.lights.length > 0) {
                elements.lights.forEach(light => {
                    light.classList.remove('scanning');
                });
            }
        }
    };

    const updateLightsAnimation = () => {
        if (!elements.lights || elements.lights.length === 0) return;
        elements.lights.forEach(light => light.classList.remove('blinking'));
        if (state.currentPokemon) {
            if (elements.lights[0]) elements.lights[0].classList.add('blinking');
            if (state.caughtPokemon.has(state.currentPokemonId) && elements.lights[1]) {
                elements.lights[1].classList.add('blinking');
            }
        }
    };

    const showNotification = (message) => {
        const notification = document.createElement('div');
        notification.className = 'pokedex-notification';
        notification.textContent = message;
        document.body.appendChild(notification);
        setTimeout(() => { notification.remove(); }, 3000);
    };

    /**
     * Exibe mensagem de erro (uso interno apenas para erros críticos)
     * @param {string} message - Mensagem de erro
     */
    const showError = (message) => {
        // Silenciado - erros de sprite são tratados com fallback
        // Apenas registra no console para debug
        console.debug('Pokedex:', message);
    };

    const renderTip = () => {
        const el = document.getElementById('tip-card');
        if (!el) return;
        const tipMessages = [
            'Dica: use filtros por tipo para descobrir novos!',
            'Curiosidade: Pikachu é #025 na Pokédex.',
            'Dica: clique em Aleatório para explorar.',
            'Curiosidade: tipos água são ótimos contra fogo!',
            'Dica: cadastre para montar sua coleção.'
        ];
        const msg = tipMessages[Math.floor(Math.random() * tipMessages.length)];
        el.textContent = msg;
    };

    return {
        init,
        loadPokemon,
        loadRandomPokemon,
        clearCurrentPokemon,
        registerPokemon,
        showNotification
    };
})();

document.addEventListener('DOMContentLoaded', () => { 
    try { generateDailyMissions(); } catch {} 
    PokedexAnime.init(); 
});

try {
    const success = JSON.parse(localStorage.getItem('pokedex_register_success') || 'null');
    if (success && success.name) {
        localStorage.removeItem('pokedex_register_success');
        setTimeout(() => { try { PokedexAnime && PokedexAnime.showNotification && PokedexAnime.showNotification(`🎉 ${success.name} cadastrado!`); } catch {} }, 300);
    }
} catch {}

const style = document.createElement('style');
style.textContent = `
    .pokedex-notification {
        position: fixed;
        top: 20px;
        left: 50%;
        transform: translateX(-50%);
        background: var(--pokedex-screen-border);
        color: white;
        padding: 10px 20px;
        border-radius: 5px;
        font-family: 'Press Start 2P', monospace;
        font-size: 10px;
        z-index: 1000;
        animation: slideDown 0.3s ease;
    }
    .pokedex-error {
        position: fixed;
        top: 20px;
        left: 50%;
        transform: translateX(-50%);
        background: var(--pokedex-button-red);
        color: white;
        padding: 10px 20px;
        border-radius: 5px;
        font-family: 'Press Start 2P', monospace;
        font-size: 10px;
        z-index: 1000;
        animation: slideDown 0.3s ease;
    }
    .pokedex-screen.loading { opacity: 0.7; pointer-events: none; position: relative; }
    .pokedex-screen.loading::after {
        content: 'CARREGANDO...';
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        font-family: 'Press Start 2P', monospace;
        font-size: 12px;
        color: white;
    }
    .type-btn.active { transform: scale(1.1); box-shadow: 0 0 10px currentColor; }
    @keyframes slideDown { from { transform: translate(-50%, -100%); opacity: 0; } to { transform: translate(-50%, 0); opacity: 1; } }
`;
document.head.appendChild(style);
    const daily = {
        key: 'pokedex_anime_daily',
        data: null,
    };

    const generateDailyMissions = () => {
        const today = new Date().toISOString().slice(0,10);
        const saved = JSON.parse(localStorage.getItem(daily.key) || 'null');
        if (!saved || saved.date !== today) {
            daily.data = {
                date: today,
                missions: [
                    { id: 'view_5', label: 'Ver 5 Pokémon hoje', progress: 0, target: 5 },
                    { id: 'type_water', label: 'Encontrar um Pokémon do tipo Água', progress: 0, target: 1 },
                    { id: 'register_1', label: 'Cadastrar 1 Pokémon', progress: 0, target: 1 }
                ]
            };
            localStorage.setItem(daily.key, JSON.stringify(daily.data));
        } else {
            daily.data = saved;
        }
        renderDailyMissions();
    };

    const saveDaily = () => { try { localStorage.setItem(daily.key, JSON.stringify(daily.data)); } catch {} };

    const renderDailyMissions = () => {
        const dailyList = document.getElementById('daily-list');
        if (!dailyList || !daily.data) return;
        dailyList.innerHTML = daily.data.missions.map(m => {
            const pct = Math.min(100, Math.round((m.progress / m.target) * 100));
            return `<li>
                <div>${m.label} (${m.progress}/${m.target})</div>
                <div class="daily-progress"><span style="width:${pct}%;"></span></div>
            </li>`;
        }).join('');
    };

    const bumpMission = (id, inc = 1) => {
        if (!daily.data) return;
        const mission = daily.data.missions.find(m => m.id === id);
        if (mission) {
            mission.progress = Math.min(mission.target, mission.progress + inc);
            saveDaily();
            renderDailyMissions();
        }
    };
