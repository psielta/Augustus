import {
  Navigate,
  Route,
  BrowserRouter as Router,
  Routes,
} from "react-router-dom";
import {
  AppLayout,
  AuthLayout,
  RedirectIfAuthenticated,
  RequireAuth,
} from "./components";

import Colors from "./pages/Colors";
import Formulario from "./pages/Formulario";
import Home from "./pages/Home";
import LoginPage from "./pages/auth/LoginPage";
import RegisterPage from "./pages/auth/RegisterPage";
import VerifyEmailPage from "./pages/auth/VerifyEmailPage";
import VerifyPendingPage from "./pages/auth/VerifyPendingPage";

function App() {
  return (
    <Router>
      <Routes>
        {/* Area publica de autenticacao */}
        <Route element={<AuthLayout />}>
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
          <Route path="/auth/verify-email" element={<VerifyEmailPage />} />
        </Route>

        {/* Area autenticada (admin layout) */}
        <Route
          element={
            <RequireAuth>
              <AppLayout />
            </RequireAuth>
          }
        >
          <Route path="/" element={<Home />} />
          <Route path="/formulario" element={<Formulario />} />
          <Route path="/cores" element={<Colors />} />
        </Route>

        {/* Fallback: qualquer rota desconhecida vai para a home (que por
            sua vez exige auth) */}
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Router>
  );
}

export default App;
