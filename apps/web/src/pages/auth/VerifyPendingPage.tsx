import { BrButton, BrMessage } from "@govbr-ds/webcomponents-react";
import { useMemo, useState } from "react";
import { Link, useSearchParams } from "react-router-dom";
import { useAuth } from "../../hooks/useAuth";
import { extrairTipoErro, mensagemAmigavel } from "../../types/auth";

export default function VerifyPendingPage() {
  const auth = useAuth();
  const [searchParams] = useSearchParams();
  const email = useMemo(
    () => searchParams.get("email") ?? auth.emailEmVerificacao,
    [searchParams, auth.emailEmVerificacao]
  );

  const [reenvioPendente, setReenvioPendente] = useState(false);
  const [reenvioFeito, setReenvioFeito] = useState(false);
  const [reenvioErro, setReenvioErro] = useState<string | null>(null);

  async function handleReenviar() {
    if (!email) return;
    setReenvioPendente(true);
    setReenvioFeito(false);
    setReenvioErro(null);
    const r = await auth.reenviarVerificacao(email);
    setReenvioPendente(false);
    if (r.ok) {
      setReenvioFeito(true);
      return;
    }
    const tipo = extrairTipoErro(r.problem);
    setReenvioErro(mensagemAmigavel(tipo, r.problem));
  }

  return (
    <section className="auth-shell">
      <div className="br-card auth-card">
        <div className="card-header">
          <h1>Verifique seu email</h1>
        </div>
        <div className="card-content">
          {email ? (
            <p className="mb-3">
              Enviamos um link de verificação para <strong>{email}</strong>.
            </p>
          ) : (
            <p className="mb-3">
              Enviamos um link de verificação para o email cadastrado.
            </p>
          )}
          <p className="mb-4">
            Abra a mensagem e clique no link para liberar o login. O link expira
            em 24 horas.
          </p>

          {reenvioFeito && !reenvioErro && (
            <BrMessage
              state="info"
              message="Se sua conta existir, enviamos um novo email. Aguarde alguns minutos antes de tentar novamente."
              show-icon
              className="mb-3"
            />
          )}
          {reenvioErro && (
            <BrMessage
              state="danger"
              message={reenvioErro}
              show-icon
              className="mb-3"
            />
          )}

          <div className="d-flex flex-wrap align-items-center gap-2">
            <BrButton
              type="button"
              emphasis="secondary"
              disabled={!email || reenvioPendente}
              onClick={handleReenviar}
            >
              {reenvioPendente ? "Reenviando..." : "Reenviar email"}
            </BrButton>
            <Link className="br-button" to="/auth/login">
              Já verifiquei, entrar
            </Link>
          </div>
        </div>
      </div>
    </section>
  );
}
