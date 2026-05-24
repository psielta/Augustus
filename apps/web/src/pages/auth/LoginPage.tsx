import { BrButton, BrInput, BrMessage } from "@govbr-ds/webcomponents-react";
import { useEffect, useState, type FormEvent } from "react";
import { Link, useNavigate, useSearchParams } from "react-router-dom";
import { useAuth } from "../../hooks/useAuth";
import {
  extrairTipoErro,
  mensagemAmigavel,
  type ProblemDetail,
  type TipoErroAuth,
} from "../../types/auth";

function destinoSeguroPosLogin(valor: string | null): string {
  if (!valor) return "/";
  // Path interno deve comecar com '/' e nao pode comecar com '//' nem '/\'
  // (URL//host vira protocol-relative; '/\\host' tambem e tratado como host
  // por alguns parsers). Bloqueia tambem ':' que indicaria protocolo.
  if (!valor.startsWith("/")) return "/";
  if (valor.startsWith("//") || valor.startsWith("/\\")) return "/";
  if (valor.includes(":")) return "/";
  return valor;
}

export default function LoginPage() {
  const auth = useAuth();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();

  const [email, setEmail] = useState("");
  const [senha, setSenha] = useState("");
  const [mostrarSenha, setMostrarSenha] = useState(false);
  const [erroEmail, setErroEmail] = useState<string | undefined>();
  const [erroSenha, setErroSenha] = useState<string | undefined>();
  const [enviando, setEnviando] = useState(false);
  const [problem, setProblem] = useState<ProblemDetail | null>(null);
  const [tipoErro, setTipoErro] = useState<TipoErroAuth | null>(null);
  const [flashSucesso, setFlashSucesso] = useState<string | null>(null);
  const [reenvioPendente, setReenvioPendente] = useState(false);
  const [reenvioFeito, setReenvioFeito] = useState(false);
  const [reenvioErro, setReenvioErro] = useState<string | null>(null);

  useEffect(() => {
    if (searchParams.get("verificado") === "1") {
      setFlashSucesso("Email verificado. Faça login para continuar.");
    } else if (searchParams.get("logout") === "1") {
      setFlashSucesso("Você saiu com segurança.");
    }
  }, [searchParams]);

  function validarEmail(): boolean {
    if (!email.trim()) {
      setErroEmail("Informe seu email");
      return false;
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim())) {
      setErroEmail("Email inválido");
      return false;
    }
    setErroEmail(undefined);
    return true;
  }

  function validarSenha(): boolean {
    if (!senha) {
      setErroSenha("Informe sua senha");
      return false;
    }
    if (senha.length < 8) {
      setErroSenha("A senha tem no mínimo 8 caracteres");
      return false;
    }
    setErroSenha(undefined);
    return true;
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    const okEmail = validarEmail();
    const okSenha = validarSenha();
    if (!okEmail || !okSenha) return;

    setEnviando(true);
    setProblem(null);
    setTipoErro(null);
    setReenvioFeito(false);
    setReenvioErro(null);

    const r = await auth.login(email.trim(), senha);
    setEnviando(false);

    if (r.ok) {
      const redirect = destinoSeguroPosLogin(searchParams.get("redirect"));
      navigate(redirect, { replace: true });
      return;
    }
    setProblem(r.problem);
    setTipoErro(extrairTipoErro(r.problem));
  }

  async function handleReenviar() {
    const e = email.trim();
    if (!e) return;
    setReenvioPendente(true);
    setReenvioFeito(false);
    setReenvioErro(null);
    const r = await auth.reenviarVerificacao(e);
    setReenvioPendente(false);
    if (r.ok) {
      setReenvioFeito(true);
      return;
    }
    const tipo = extrairTipoErro(r.problem);
    setReenvioErro(mensagemAmigavel(tipo, r.problem));
  }

  const mensagemErroSubmit =
    tipoErro && problem ? mensagemAmigavel(tipoErro, problem) : null;

  return (
    <section className="auth-shell">
      <div className="br-card auth-card">
        <div className="card-header">
          <h1>Entrar no Augustus</h1>
          <p className="text-base">Controlador de finanças pessoais</p>
        </div>
        <div className="card-content">
          {flashSucesso && (
            <BrMessage
              state="success"
              message={flashSucesso}
              show-icon
              className="mb-3"
            />
          )}
          {mensagemErroSubmit && (
            <BrMessage
              state="danger"
              message={mensagemErroSubmit}
              show-icon
              className="mb-3"
            />
          )}

          <form onSubmit={handleSubmit} noValidate>
            <div className="mb-3">
              <BrInput
                label="Email"
                id="email"
                type="email"
                value={email}
                state={erroEmail ? "danger" : undefined}
                {...({ autocomplete: "username" } as Record<string, string>)}
                onInput={(e) =>
                  setEmail((e.target as HTMLInputElement).value)
                }
                onBlur={validarEmail}
              />
              {erroEmail && (
                <BrMessage
                  state="danger"
                  is-feedback
                  message={erroEmail}
                  show-icon
                  aria-label={erroEmail}
                />
              )}
            </div>

            <div className="mb-3">
              <BrInput
                label="Senha"
                id="senha"
                type={mostrarSenha ? "text" : "password"}
                value={senha}
                state={erroSenha ? "danger" : undefined}
                {...({ autocomplete: "current-password" } as Record<string, string>)}
                onInput={(e) =>
                  setSenha((e.target as HTMLInputElement).value)
                }
                onBlur={validarSenha}
              >
                <BrButton
                  type="button"
                  onClick={() => setMostrarSenha((s) => !s)}
                  aria-label={mostrarSenha ? "Ocultar senha" : "Mostrar senha"}
                >
                  {mostrarSenha ? "Ocultar" : "Exibir"}
                </BrButton>
              </BrInput>
              {erroSenha && (
                <BrMessage
                  state="danger"
                  is-feedback
                  message={erroSenha}
                  show-icon
                  aria-label={erroSenha}
                />
              )}
            </div>

            {tipoErro === "EMAIL_NAO_VERIFICADO" && (
              <div className="mb-3">
                <BrButton
                  type="button"
                  emphasis="secondary"
                  disabled={reenvioPendente}
                  onClick={handleReenviar}
                >
                  {reenvioPendente
                    ? "Reenviando..."
                    : "Reenviar email de verificação"}
                </BrButton>
                {reenvioFeito && !reenvioErro && (
                  <BrMessage
                    state="info"
                    is-feedback
                    message="Se sua conta existir, enviamos um novo email. Aguarde alguns minutos."
                    show-icon
                    className="mt-2"
                  />
                )}
                {reenvioErro && (
                  <BrMessage
                    state="danger"
                    is-feedback
                    message={reenvioErro}
                    show-icon
                    className="mt-2"
                  />
                )}
              </div>
            )}

            <div className="d-flex flex-wrap align-items-center gap-2">
              <BrButton
                type="submit"
                emphasis="primary"
                disabled={enviando}
              >
                {enviando ? "Entrando..." : "Entrar"}
              </BrButton>
              <Link className="br-button" to="/auth/register">
                Criar conta
              </Link>
            </div>
          </form>
        </div>
      </div>
    </section>
  );
}
