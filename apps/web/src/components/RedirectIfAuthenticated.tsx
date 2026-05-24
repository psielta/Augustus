import type { ReactNode } from "react";
import { Navigate } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";

interface Props {
  children: ReactNode;
}

/**
 * Wrapper para rotas publicas de auth (login/register): se o usuario ja
 * estiver autenticado, redireciona para a home. Substitui o
 * `naoAutenticadoGuard` (`CanMatchFn`) do Angular.
 *
 * Enquanto a sessao esta sendo restaurada no bootstrap (`status ===
 * 'inicializando'`), nao redireciona — espera o `AuthProvider` resolver.
 */
export function RedirectIfAuthenticated({ children }: Props) {
  const { status, isAutenticado } = useAuth();
  if (status === "inicializando") return null;
  if (isAutenticado) return <Navigate to="/" replace />;
  return <>{children}</>;
}

export default RedirectIfAuthenticated;
