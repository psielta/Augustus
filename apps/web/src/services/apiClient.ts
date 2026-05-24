import type { ProblemDetail, TokenPair } from "../types/auth";
import { tokenStorage } from "./tokenStorage";

export type Resultado<T> =
  | { ok: true; data: T }
  | { ok: false; problem: ProblemDetail };

const SKIP_AUTH_PATHS = [
  "/api/auth/login",
  "/api/auth/register",
  "/api/auth/refresh",
  "/api/auth/verify-email",
  "/api/auth/resend-verification",
];

function isPublicAuthPath(path: string): boolean {
  return SKIP_AUTH_PATHS.some((p) => path.includes(p));
}

// Lê body de forma resiliente:
// - 204 No Content (logout, verify-email POST, resend-verification) -> null
// - content-length: 0 -> null
// - content-type sem application/json (ex: text/plain do GET verify-email) -> null
// - JSON vazio -> null
async function lerBody<T>(response: Response): Promise<T | null> {
  if (response.status === 204) return null;
  const contentLength = response.headers.get("content-length");
  if (contentLength === "0") return null;
  const contentType = response.headers.get("content-type") ?? "";
  if (!contentType.includes("application/json")) return null;
  const text = await response.text();
  if (!text) return null;
  try {
    return JSON.parse(text) as T;
  } catch {
    return null;
  }
}

function isRefreshDefinitivelyInvalido(
  status: number,
  problem: ProblemDetail | null
): boolean {
  if (status !== 401 && status !== 400) return false;
  if (problem) {
    const slug = problem.type?.split("/").pop()?.toLowerCase();
    if (slug === "refresh-token-invalido" || slug === "nao-autenticado") {
      return true;
    }
    if (status === 400) return false;
  }
  return status === 401;
}

// Single-flight: chamadas concorrentes a refreshTokens() compartilham a mesma Promise.
let inflightRefresh: Promise<boolean> | null = null;

export function refreshTokens(): Promise<boolean> {
  if (inflightRefresh) return inflightRefresh;
  const refreshToken = tokenStorage.lerRefresh();
  if (!refreshToken) return Promise.resolve(false);

  inflightRefresh = (async () => {
    try {
      const response = await fetch("/api/auth/refresh", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
        },
        body: JSON.stringify({ refreshToken }),
      });
      if (response.ok) {
        const tokens = await lerBody<TokenPair>(response);
        if (tokens) {
          tokenStorage.salvar(tokens);
          return true;
        }
        return false;
      }
      const problem = await lerBody<ProblemDetail>(response);
      // Erro transitório (timeout/5xx) NÃO apaga sessão; só 401 definitivo.
      if (isRefreshDefinitivelyInvalido(response.status, problem)) {
        tokenStorage.limpar();
      }
      return false;
    } catch {
      // Erro de rede — preserva storage (caller pode tentar novamente depois).
      return false;
    } finally {
      inflightRefresh = null;
    }
  })();

  return inflightRefresh;
}

export interface ApiFetchOptions extends Omit<RequestInit, "headers"> {
  headers?: HeadersInit;
  skipAuth?: boolean;
}

function buildHeaders(init: ApiFetchOptions, skipAuth: boolean): Headers {
  const headers = new Headers(init.headers);
  if (init.body && !headers.has("Content-Type")) {
    headers.set("Content-Type", "application/json");
  }
  if (!headers.has("Accept")) headers.set("Accept", "application/json");
  if (!skipAuth) {
    const token = tokenStorage.lerAccess();
    if (token) headers.set("Authorization", `Bearer ${token}`);
  }
  return headers;
}

function networkProblem(e: unknown): ProblemDetail {
  const msg = e instanceof Error ? e.message : String(e);
  return { title: "Erro de rede", detail: msg };
}

export async function apiFetch<T = unknown>(
  path: string,
  init: ApiFetchOptions = {}
): Promise<Resultado<T>> {
  const { skipAuth = false, ...rest } = init;
  const skip = skipAuth || isPublicAuthPath(path);

  let response: Response;
  try {
    response = await fetch(path, {
      ...rest,
      headers: buildHeaders(init, skip),
    });
  } catch (e) {
    return { ok: false, problem: networkProblem(e) };
  }

  // 401 fora de paths públicos → tenta refresh single-flight e retenta.
  if (response.status === 401 && !skip) {
    const ok = await refreshTokens();
    if (ok) {
      try {
        response = await fetch(path, {
          ...rest,
          headers: buildHeaders(init, false), // re-injeta novo Bearer
        });
      } catch (e) {
        return { ok: false, problem: networkProblem(e) };
      }
    }
  }

  if (response.ok) {
    const data = await lerBody<T>(response);
    return { ok: true, data: data as T };
  }

  const problem =
    (await lerBody<ProblemDetail>(response)) ?? {
      status: response.status,
      title: response.statusText || "Erro no servidor",
    };
  return { ok: false, problem };
}
