import React from "react";

const ANO_ATUAL = new Date().getFullYear();

/**
 * Footer enxuto do Augustus.
 *
 * Substitui o `BrFooter` do GovBR-DS porque o web component vinha
 * renderizando placeholders (redes sociais, categorias) mesmo quando os
 * slots eram passados vazios. Aqui temos controle total: marca,
 * descricao curta do produto e linha de copyright. Sem redes sociais,
 * sem parceiros, sem categorias inventadas.
 *
 * Visual: faixa escura no fim da pagina (constraste com conteudo
 * light-mode), padrao admin. NAO e dark mode global.
 */
const Footer: React.FC = () => {
  return (
    <footer className="augustus-footer">
      <div className="augustus-footer__content">
        <div className="augustus-footer__brand">
          <img
            src="/brand/augustus-symbol.svg"
            alt="Augustus"
            width={48}
            height={48}
            style={{ width: 48, height: 48 }}
          />
          <div className="augustus-footer__copy">
            <strong className="augustus-footer__title">Augustus</strong>
            <p className="augustus-footer__desc">
              Controlador de finanças pessoais. Cadastre contas, cartões e
              orçamentos, acompanhe lançamentos e parcelamentos, e visualize o
              estado do seu dinheiro em um só lugar.
            </p>
          </div>
        </div>
        <div className="augustus-footer__legal">
          © {ANO_ATUAL} Augustus &middot; Controlador de finanças pessoais.
        </div>
      </div>
    </footer>
  );
};

export default Footer;
