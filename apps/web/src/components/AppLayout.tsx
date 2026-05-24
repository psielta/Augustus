import { useState } from "react";
import { Outlet } from "react-router-dom";
import Breadcrumb from "./Breadcrumb/Breadcrumb";
import Footer from "./Footer/Footer";
import Header from "./Header/Header";
import Menu from "./Menu/Menu";
import styles from "../App.module.css";

/**
 * Layout das rotas privadas/admin (`/`, `/formulario`, `/cores`, ...).
 * Composto por Header (com saudacao + Sair), Menu lateral (drawer no
 * mobile, push no desktop), Breadcrumb e Footer. As paginas vao no
 * `<Outlet />`.
 */
export default function AppLayout() {
  const [menuOpen, setMenuOpen] = useState(false);

  return (
    <>
      <Header onToggleMenu={() => setMenuOpen((v) => !v)} />
      <main className="d-flex flex-fill mb-5" id="main">
        <div className="container-fluid d-flex">
          <div className="row">
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
    </>
  );
}
