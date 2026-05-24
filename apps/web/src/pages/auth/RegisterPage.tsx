import { BrButton, BrInput, BrMessage } from "@govbr-ds/webcomponents-react";
import { useState, type FormEvent } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../../hooks/useAuth";
import {
  extrairTipoErro,
  mensagemAmigavel,
  type ProblemDetail,
  type TipoErroAuth,
} from "../../types/auth";

export default function RegisterPage() {
  const auth = useAuth();
  const navigate = useNavigate();

  const [nome, setNome] = useState("");
  const [email, setEmail] = useState("");
  const [senha, setSenha] = useState("");
  const [mostrarSenha, setMostrarSenha] = useState(false);
  const [erroNome, setErroNome] = useState<string | undefined>();
  const [erroEmail, setErroEmail] = useState<string | undefined>();
  const [erroSenha, setErroSenha] = useState<string | undefined>();
  const [enviando, setEnviando] = useState(false);
  const [problem, setProblem] = useState<ProblemDetail | null>(null);
  const [tipoErro, setTipoErro] = useState<TipoErroAuth | null>(null);

  function validarNome(): boolean {
    const v = nome.trim();
    if (!v) {
      setErroNome("Informe seu nome");
      return false;
    }
    if (v.length > 120) {
      setErroNome("Máximo 120 caracteres");
      return false;
    }
    setErroNome(undefined);
    return true;
  }
  function validarEmail(): boolean {
    const v = email.trim();
    if (!v) {
      setErroEmail("Informe seu email");
      return false;
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v)) {
      setErroEmail("Email inválido");
      return false;
    }
    if (v.length > 254) {
      setErroEmail("Email muito longo");
      return false;
    }
    setErroEmail(undefined);
    return true;
  }
  function validarSenha(): boolean {
    if (!senha) {
      setErroSenha("Informe uma senha");
      return false;
    }
    if (senha.length < 8) {
      setErroSenha("Mínimo 8 caracteres");
      return false;
    }
    if (senha.length > 128) {
      setErroSenha("Máximo 128 caracteres");
      return false;
    }
    setErroSenha(undefined);
    return true;
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    const ok = [validarNome(), validarEmail(), validarSenha()].every(Boolean);
    if (!ok) return;

    setEnviando(true);
    setProblem(null);
    setTipoErro(null);

    const r = await auth.registrar({
      nome: nome.trim(),
      email: email.trim(),
      senha,
    });
    setEnviando(false);

    if (r.ok) {
      navigate(
        `/auth/verify-pending?email=${encodeURIComponent(r.data.usuario.email)}`,
        { replace: true }
      );
      return;
    }
    setProblem(r.problem);
    setTipoErro(extrairTipoErro(r.problem));
  }

  const mensagemErroSubmit =
    tipoErro && problem ? mensagemAmigavel(tipoErro, problem) : null;

  return (
    <div className="br-card auth-card">
        <div className="card-header">
          <h1>Criar conta no Augustus</h1>
          <p className="text-base">Controlador de finanças pessoais</p>
        </div>
        <div className="card-content">
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
                label="Nome completo"
                id="nome"
                type="text"
                value={nome}
                state={erroNome ? "danger" : undefined}
                {...({ autocomplete: "name" } as Record<string, string>)}
                onInput={(e) =>
                  setNome((e.target as HTMLInputElement).value)
                }
                onBlur={validarNome}
              />
              {erroNome && (
                <BrMessage
                  state="danger"
                  is-feedback
                  message={erroNome}
                  show-icon
                  aria-label={erroNome}
                />
              )}
            </div>

            <div className="mb-3">
              <BrInput
                label="Email"
                id="email"
                type="email"
                value={email}
                state={erroEmail ? "danger" : undefined}
                {...({ autocomplete: "email" } as Record<string, string>)}
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
                {...({ autocomplete: "new-password" } as Record<string, string>)}
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

            <div className="d-flex flex-wrap align-items-center gap-2">
              <BrButton
                type="submit"
                emphasis="primary"
                disabled={enviando}
              >
                {enviando ? "Criando..." : "Criar conta"}
              </BrButton>
              <Link className="br-button" to="/auth/login">
                Já tenho conta
              </Link>
            </div>
          </form>
        </div>
    </div>
  );
}
