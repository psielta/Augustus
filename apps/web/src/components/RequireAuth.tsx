import type { ReactNode } from "react";
import { Navigate, useLocation } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";

interface Props {
  children: ReactNode;
}

/**
 * Wrapper para rotas privadas (area logada): se o usuario nao estiver
 * autenticado, redireciona para `/auth/login` preservando o destino
 * pretendido em `?redirect=...`. O `LoginPage` sanitiza esse parametro
 * via `destinoSeguroPosLogin` antes de usar.
 *
 * Enquanto a sessao esta sendo restaurada no bootstrap (`status ===
 * 'inicializando'`), nao redireciona — espera o `AuthProvider` resolver.
 */
export function RequireAuth({ children }: Props) {
  const { status, isAutenticado } = useAuth();
  const location = useLocation();

  if (status === "inicializando") return null;
  if (!isAutenticado) {
    const destino = `${location.pathname}${location.search}`;
    const sufixo =
      destino === "/" ? "" : `?redirect=${encodeURIComponent(destino)}`;
    return <Navigate to={`/auth/login${sufixo}`} replace />;
  }
  return <>{children}</>;
}

export default RequireAuth;
