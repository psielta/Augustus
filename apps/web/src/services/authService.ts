import type {
  Registro,
  TokenPair,
  Usuario,
} from "../types/auth";
import { apiFetch, refreshTokens, type Resultado } from "./apiClient";
import { tokenStorage } from "./tokenStorage";

const API = "/api/auth";

export interface RegistrarInput {
  nome: string;
  email: string;
  senha: string;
}

export async function registrar(
  input: RegistrarInput
): Promise<Resultado<Registro>> {
  return apiFetch<Registro>(`${API}/register`, {
    method: "POST",
    body: JSON.stringify(input),
  });
}

export async function login(
  email: string,
  senha: string
): Promise<Resultado<TokenPair>> {
  const r = await apiFetch<TokenPair>(`${API}/login`, {
    method: "POST",
    body: JSON.stringify({ email, senha }),
  });
  if (r.ok && r.data) {
    tokenStorage.salvar(r.data);
  }
  return r;
}

export async function logout(): Promise<Resultado<null>> {
  try {
    const r = await apiFetch<null>(`${API}/logout`, { method: "POST" });
    return r;
  } finally {
    tokenStorage.limpar();
  }
}

export async function carregarMe(): Promise<Resultado<Usuario>> {
  return apiFetch<Usuario>(`${API}/me`, { method: "GET" });
}

export async function verificarEmail(
  token: string
): Promise<Resultado<null>> {
  return apiFetch<null>(`${API}/verify-email`, {
    method: "POST",
    body: JSON.stringify({ token }),
  });
}

export async function reenviarVerificacao(
  email: string
): Promise<Resultado<null>> {
  return apiFetch<null>(`${API}/resend-verification`, {
    method: "POST",
    body: JSON.stringify({ email }),
  });
}

/**
 * Bootstrap: se não há refresh em storage, retorna `null` (anônimo).
 * Caso contrário, tenta refresh + me. Se o refresh falhar com 401
 * definitivo, o storage já é limpo pelo apiClient.
 */
export async function restaurarSessao(): Promise<Usuario | null> {
  if (!tokenStorage.lerRefresh()) return null;
  const refreshed = await refreshTokens();
  if (!refreshed) return null;
  const me = await carregarMe();
  return me.ok ? me.data : null;
}
