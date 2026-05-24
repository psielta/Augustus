import { useEffect, useState } from "react";
import { Outlet } from "react-router-dom";
import Breadcrumb from "./Breadcrumb/Breadcrumb";
import Footer from "./Footer/Footer";
import Header from "./Header/Header";
import Menu from "./Menu/Menu";
import styles from "../App.module.css";

const MENU_STORAGE_KEY = "augustus.ui.menuOpen";
const MOBILE_QUERY = "(max-width: 768px)";

/**
 * Le o estado inicial da sidebar do localStorage. Se nao houver valor
 * gravado, escolhe um default razoavel pelo viewport: aberto em desktop
 * (push tradicional cabe), fechado em mobile (drawer overlay).
 */
function lerMenuInicial(): boolean {
  try {
    const stored = window.localStorage.getItem(MENU_STORAGE_KEY);
    if (stored === "true") return true;
    if (stored === "false") return false;
  } catch {
    // localStorage indisponivel — cai no default por viewport
  }
  try {
    return !window.matchMedia(MOBILE_QUERY).matches;
  } catch {
    return false;
  }
}

/**
 * Layout das rotas privadas/admin (`/`, `/formulario`, `/cores`, ...).
 * Composto por Header (com saudacao + Sair), Menu lateral (drawer no
 * mobile, push no desktop), Breadcrumb e Footer. As paginas vao no
 * `<Outlet />`.
 *
 * O shell e flex-column com `min-height: 100vh` (sticky footer) — o
 * Footer fica grudado no fim da viewport mesmo quando a pagina renderiza
 * pouco conteudo, em vez de aparecer no meio da tela.
 *
 * O estado aberto/fechado da sidebar e persistido em
 * `augustus.ui.menuOpen` para sobreviver a refresh / navegacao SPA /
 * nova aba — preferencia do usuario sempre vence o default.
 */
export default function AppLayout() {
  const [menuOpen, setMenuOpen] = useState<boolean>(lerMenuInicial);

  useEffect(() => {
    try {
      window.localStorage.setItem(MENU_STORAGE_KEY, String(menuOpen));
    } catch {
      // sem storage o estado continua funcionando, so nao persiste
    }
  }, [menuOpen]);

  return (
    <div className={styles.shell}>
      <Header onToggleMenu={() => setMenuOpen((v) => !v)} />
      <main className={`${styles.main} mb-5`} id="main">
        <div className="container-fluid d-flex">
          <div className="row flex-fill">
            {menuOpen && (
              <>
                <div
                  className="menu-backdrop"
                  onClick={() => setMenuOpen(false)}
                  aria-hidden="true"
                />
                <Menu onClose={() => setMenuOpen(false)} />
              </>
            )}
            <div className="col mb-5">
              <Breadcrumb />
              <div
                className={`${styles.mainContent} pl-sm-3 mt-4`}
                id="main-content"
              >
                <Outlet />
              </div>
            </div>
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}
