import { Link, Outlet } from "react-router-dom";

/**
 * Layout das rotas publicas de autenticacao (`/auth/*`). Nao usa
 * Header/Menu/Breadcrumb/Footer do admin — apenas uma faixa superior
 * com a marca e um `<main>` que centraliza o card de auth.
 */
export default function AuthLayout() {
  return (
    <div className="auth-layout">
      <header className="auth-layout__top">
        <Link to="/auth/login" className="auth-layout__brand">
          <img
            src="/brand/augustus-symbol.svg"
            alt="Augustus"
            width={48}
            height={48}
            style={{ width: 48, height: 48 }}
          />
          <span className="auth-layout__brand-text">
            <strong>Augustus</strong>
            <small>Controlador de finanças pessoais</small>
          </span>
        </Link>
      </header>
      <main className="auth-layout__main">
        <Outlet />
      </main>
    </div>
  );
}
