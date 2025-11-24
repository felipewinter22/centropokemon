/**
 * Script para gerenciar autenticação no header
 * Mostra/esconde botões de Login/Cadastro/Sair baseado no estado de login
 */
(function() {
    const TRAINER_ID_KEY = 'treinador_id';
    const trainerId = localStorage.getItem(TRAINER_ID_KEY);
    
    // Função de logout
    window.logout = function() {
        if (confirm('Deseja realmente sair?')) {
            localStorage.removeItem(TRAINER_ID_KEY);
            alert('Você saiu com sucesso!');
            window.location.href = '/Pokemon.html';
        }
    };
    
    // Atualizar header quando a página carregar
    document.addEventListener('DOMContentLoaded', function() {
        const authLinks = document.querySelector('.auth-links');
        if (!authLinks) return;
        
        if (trainerId) {
            // Usuário logado - mostrar apenas botão Sair
            authLinks.innerHTML = `
                <span style="margin-right: 1rem; color: #666;">ID: ${trainerId}</span>
                <a href="#" onclick="logout(); return false;" style="color: #FF0000; font-weight: bold;">Sair</a>
            `;
        } else {
            // Usuário não logado - mostrar Cadastro e Login
            const currentPage = window.location.pathname;
            authLinks.innerHTML = `
                <a href="/cadastro.html" ${currentPage.includes('cadastro') ? 'class="active"' : ''}>Cadastro</a>
                <a href="/login.html" ${currentPage.includes('login') ? 'class="active"' : ''}>Login</a>
            `;
        }
    });
})();
