import { BrMessage } from "@govbr-ds/webcomponents-react";
import { useEffect, useRef, useState } from "react";
import { Link, useNavigate, useSearchParams } from "react-router-dom";
import { useAuth } from "../../hooks/useAuth";
import {
  extrairTipoErro,
  mensagemAmigavel,
  type TipoErroAuth,
} from "../../types/auth";

type Status = "processando" | "sucesso" | "erro" | "sem-token";

export default function VerifyEmailPage() {
  const auth = useAuth();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();

  const [status, setStatus] = useState<Status>("processando");
  const [mensagem, setMensagem] = useState<string>("");
  const [, setTipoErro] = useState<TipoErroAuth | null>(null);
  // Guarda o ultimo token processado (string), nao apenas um booleano:
  // protege contra a re-execucao do StrictMode no mesmo token, mas
  // ainda permite reprocessar quando o usuario abre `?token=` diferente
  // na mesma instancia da SPA.
  const tokenProcessadoRef = useRef<string | null>(null);

  useEffect(() => {
    const token = searchParams.get("token");
    if (!token) {
      setStatus("sem-token");
      return;
    }
    if (tokenProcessadoRef.current === token) return;
    tokenProcessadoRef.current = token;
    setStatus("processando");

    (async () => {
      const r = await auth.verificarEmailComToken(token);
      if (r.ok) {
        setStatus("sucesso");
        setMensagem("Email verificado. Redirecionando para o login...");
        window.setTimeout(() => {
          navigate("/auth/login?verificado=1", { replace: true });
        }, 1500);
        return;
      }
      const tipo = extrairTipoErro(r.problem);
      setTipoErro(tipo);
      setStatus("erro");
      setMensagem(mensagemAmigavel(tipo, r.problem));
    })();
  }, [auth, navigate, searchParams]);

  return (
    <section className="auth-shell">
      <div className="br-card auth-card">
        <div className="card-header">
          <h1>Verificação de email</h1>
        </div>
        <div className="card-content">
          {status === "processando" && <p>Verificando seu email, aguarde...</p>}

          {status === "sucesso" && (
            <BrMessage state="success" message={mensagem} show-icon />
          )}
          {status === "erro" && (
            <BrMessage state="danger" message={mensagem} show-icon />
          )}
          {status === "sem-token" && (
            <BrMessage
              state="warning"
              message="Nenhum token informado. Abra o link enviado por email."
              show-icon
            />
          )}

          {status !== "processando" && (
            <div className="d-flex flex-wrap align-items-center gap-2 mt-3">
              <Link className="br-button" to="/auth/login">
                Ir para o login
              </Link>
              <Link className="br-button" to="/auth/verify-pending">
                Reenviar email
              </Link>
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
