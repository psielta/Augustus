import { BrButton } from "@govbr-ds/webcomponents-react";
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../hooks/useAuth";

const Header = () => {
  const [menuOpen, setMenuOpen] = useState(true);
  const { isAutenticado, usuario, logout } = useAuth();
  const navigate = useNavigate();

  const onToggleMenu = () => {
    const newValue = !menuOpen;
    setMenuOpen(newValue);
    const event = new CustomEvent("toggleMenu", { detail: { open: newValue } });
    window.dispatchEvent(event);
  };

  const onSair = async () => {
    await logout();
    navigate("/auth/login?logout=1");
  };

  return (
    <header className="br-header mb-4" id="header" data-sticky="data-sticky">
      <div className="container-fluid">
        <div className="header-top">
          <div className="header-logo">
            <a href="/">
              <img src="/img-template.png" alt="logo" />
            </a>
            <span className="br-divider vertical"></span>
            <div className="header-sign">
              Augustus - Controlador de finanças pessoais
            </div>
          </div>
          {isAutenticado && usuario && (
            <div className="header-actions d-flex align-items-center gap-2">
              <span className="text-base">Olá, {usuario.nome}</span>
              <BrButton type="button" emphasis="secondary" onClick={onSair}>
                Sair
              </BrButton>
            </div>
          )}
        </div>
        <div className="header-bottom">
          <div className="header-menu">
            <div className="header-menu-trigger" id="header-navigation">
              <button
                className="br-button small circle"
                type="button"
                aria-label="Menu"
                onClick={onToggleMenu}
                data-toggle="menu"
                data-target="#main-navigation"
                id="navigation"
              >
                <i className="fas fa-bars" aria-hidden="true"></i>
              </button>
            </div>
            <div className="header-info">
              <div className="header-title">Augustus</div>
            </div>
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;
