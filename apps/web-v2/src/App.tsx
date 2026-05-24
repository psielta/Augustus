import { useEffect, useState } from "react";
import { Route, BrowserRouter as Router, Routes } from "react-router-dom";
import { Header, Menu } from "./components";
import Breadcrumb from "./components/Breadcrumb/Breadcrumb";
import Footer from "./components/Footer/Footer";
import RedirectIfAuthenticated from "./components/RedirectIfAuthenticated";

import Colors from "./pages/Colors";
import Home from "./pages/Home";
import Formulario from "./pages/Formulario";
import LoginPage from "./pages/auth/LoginPage";
import RegisterPage from "./pages/auth/RegisterPage";
import VerifyEmailPage from "./pages/auth/VerifyEmailPage";
import VerifyPendingPage from "./pages/auth/VerifyPendingPage";

import styles from "./App.module.css";

function App() {
  const [isMenuVisible, setIsMenuVisible] = useState(true);

  useEffect(() => {
    const handleToggleMenu = (event: Event) => {
      const open = (event as CustomEvent<{ open: boolean }>).detail.open;
      setIsMenuVisible(open);
    };
    window.addEventListener("toggleMenu", handleToggleMenu);
    return () => {
      window.removeEventListener("toggleMenu", handleToggleMenu);
    };
  }, []);

  return (
    <Router>
      <Header />
      <main className="d-flex flex-fill mb-5" id="main">
        <div className="container-fluid d-flex">
          <div className="row">
            {isMenuVisible && <Menu />}
            <div className="col mb-5">
              <Breadcrumb />
              <div
                className={`${styles.mainContent} pl-sm-3 mt-4`}
                id="main-content"
              >
                <Routes>
                  <Route path="/" element={<Home />} />
                  <Route path="/formulario" element={<Formulario />} />
                  <Route path="/cores" element={<Colors />} />
                  <Route
                    path="/auth/login"
                    element={
                      <RedirectIfAuthenticated>
                        <LoginPage />
                      </RedirectIfAuthenticated>
                    }
                  />
                  <Route
                    path="/auth/register"
                    element={
                      <RedirectIfAuthenticated>
                        <RegisterPage />
                      </RedirectIfAuthenticated>
                    }
                  />
                  <Route
                    path="/auth/verify-pending"
                    element={<VerifyPendingPage />}
                  />
                  <Route
                    path="/auth/verify-email"
                    element={<VerifyEmailPage />}
                  />
                </Routes>
              </div>
            </div>
          </div>
        </div>
      </main>
      <Footer />
    </Router>
  );
}

export default App;
