import type { TokenPair } from "../types/auth";

const ACCESS_KEY = "augustus.auth.access";
const REFRESH_KEY = "augustus.auth.refresh";
const ACCESS_EXPIRA_KEY = "augustus.auth.accessExpiraEm";
const REFRESH_EXPIRA_KEY = "augustus.auth.refreshExpiraEm";

export const tokenStorage = {
  salvar(par: TokenPair): void {
    localStorage.setItem(ACCESS_KEY, par.accessToken);
    localStorage.setItem(REFRESH_KEY, par.refreshToken);
    localStorage.setItem(ACCESS_EXPIRA_KEY, par.accessTokenExpiraEm);
    localStorage.setItem(REFRESH_EXPIRA_KEY, par.refreshTokenExpiraEm);
  },

  lerAccess(): string | null {
    return localStorage.getItem(ACCESS_KEY);
  },

  lerRefresh(): string | null {
    return localStorage.getItem(REFRESH_KEY);
  },

  lerAccessExpiraEm(): string | null {
    return localStorage.getItem(ACCESS_EXPIRA_KEY);
  },

  limpar(): void {
    localStorage.removeItem(ACCESS_KEY);
    localStorage.removeItem(REFRESH_KEY);
    localStorage.removeItem(ACCESS_EXPIRA_KEY);
    localStorage.removeItem(REFRESH_EXPIRA_KEY);
  },
};
