import {
  createContext,
  useCallback,
  useEffect,
  useMemo,
  useReducer,
  type ReactNode,
} from "react";
import * as authService from "../services/authService";
import type { ProblemDetail, Registro, Usuario } from "../types/auth";
import type { Resultado } from "../services/apiClient";

export type AuthStatus = "inicializando" | "anonimo" | "autenticado";

interface AuthState {
  status: AuthStatus;
  usuario: Usuario | null;
  precisaVerificarEmail: boolean;
  emailEmVerificacao: string | null;
}

type Action =
  | { type: "INICIALIZAR_OK"; usuario: Usuario | null }
  | { type: "LOGIN_OK"; usuario: Usuario }
  | { type: "PRECISA_VERIFICAR"; email: string | null }
  | { type: "LOGOUT" }
  | { type: "LIMPAR_FLASH" };

const initialState: AuthState = {
  status: "inicializando",
  usuario: null,
  precisaVerificarEmail: false,
  emailEmVerificacao: null,
};

function reducer(state: AuthState, action: Action): AuthState {
  switch (action.type) {
    case "INICIALIZAR_OK":
      return {
        ...state,
        status: action.usuario ? "autenticado" : "anonimo",
        usuario: action.usuario,
        precisaVerificarEmail: false,
        emailEmVerificacao: null,
      };
    case "LOGIN_OK":
      return {
        ...state,
        status: "autenticado",
        usuario: action.usuario,
        precisaVerificarEmail: false,
        emailEmVerificacao: null,
      };
    case "PRECISA_VERIFICAR":
      return {
        ...state,
        status: "anonimo",
        usuario: null,
        precisaVerificarEmail: true,
        emailEmVerificacao: action.email,
      };
    case "LOGOUT":
      return {
        status: "anonimo",
        usuario: null,
        precisaVerificarEmail: false,
        emailEmVerificacao: null,
      };
    case "LIMPAR_FLASH":
      return { ...state, precisaVerificarEmail: false, emailEmVerificacao: null };
    default:
      return state;
  }
}

export interface AuthContextValue extends AuthState {
  isAutenticado: boolean;
  registrar: (input: {
    nome: string;
    email: string;
    senha: string;
  }) => Promise<Resultado<Registro>>;
  login: (email: string, senha: string) => Promise<Resultado<Usuario>>;
  logout: () => Promise<void>;
  verificarEmailComToken: (token: string) => Promise<Resultado<null>>;
  reenviarVerificacao: (email: string) => Promise<Resultado<null>>;
}

export const AuthContext = createContext<AuthContextValue | null>(null);

interface AuthProviderProps {
  children: ReactNode;
}

export function AuthProvider({ children }: AuthProviderProps) {
  const [state, dispatch] = useReducer(reducer, initialState);

  // Bootstrap: roda uma vez. Substitui o provideAppInitializer do Angular.
  useEffect(() => {
    let cancelled = false;
    (async () => {
      const usuario = await authService.restaurarSessao();
      if (!cancelled) dispatch({ type: "INICIALIZAR_OK", usuario });
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  const registrar = useCallback<AuthContextValue["registrar"]>(
    async (input) => {
      const r = await authService.registrar(input);
      if (r.ok) {
        dispatch({ type: "PRECISA_VERIFICAR", email: r.data.usuario.email });
      }
      return r;
    },
    []
  );

  const login = useCallback<AuthContextValue["login"]>(async (email, senha) => {
    const r = await authService.login(email, senha);
    if (!r.ok) {
      const slug = (r.problem as ProblemDetail).type?.split("/").pop();
      if (slug === "email-nao-verificado") {
        dispatch({ type: "PRECISA_VERIFICAR", email });
      }
      return { ok: false, problem: r.problem };
    }
    const me = await authService.carregarMe();
    if (!me.ok) {
      return { ok: false, problem: me.problem };
    }
    dispatch({ type: "LOGIN_OK", usuario: me.data });
    return { ok: true, data: me.data };
  }, []);

  const logout = useCallback<AuthContextValue["logout"]>(async () => {
    await authService.logout();
    dispatch({ type: "LOGOUT" });
  }, []);

  const verificarEmailComToken = useCallback<
    AuthContextValue["verificarEmailComToken"]
  >(async (token) => {
    const r = await authService.verificarEmail(token);
    if (r.ok) {
      dispatch({ type: "LIMPAR_FLASH" });
    }
    return r;
  }, []);

  const reenviarVerificacao = useCallback<
    AuthContextValue["reenviarVerificacao"]
  >(async (email) => authService.reenviarVerificacao(email), []);

  const value = useMemo<AuthContextValue>(
    () => ({
      ...state,
      isAutenticado: state.status === "autenticado",
      registrar,
      login,
      logout,
      verificarEmailComToken,
      reenviarVerificacao,
    }),
    [state, registrar, login, logout, verificarEmailComToken, reenviarVerificacao]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}
