import {
  BrButton,
  BrCheckbox,
  BrInput,
  BrMessage,
} from "@govbr-ds/webcomponents-react";
import type { FormEvent } from "react";
import React, { useState } from "react";

interface CadastroData {
  nome: string;
  email: string;
  cpf: string;
  telefone: string;
  genero: string;
  senha: string;
  confirmarSenha: string;
  termos: boolean;
}

interface ErrosCadastro {
  nome?: string;
  email?: string;
  cpf?: string;
  telefone?: string;
  genero?: string;
  senha?: string;
  confirmarSenha?: string;
  termos?: string;
}

const initialForm: CadastroData = {
  nome: "",
  email: "",
  cpf: "",
  telefone: "",
  genero: "",
  senha: "",
  confirmarSenha: "",
  termos: false,
};

const Formulario: React.FC = () => {
  // Estados de cadastro e erros
  const [form, setForm] = useState<CadastroData>({ ...initialForm });
  const [errosCad, setErrosCad] = useState<ErrosCadastro>({});

  // Mostrar/ocultar senha
  const [mostrarSenha, setMostrarSenha] = useState(false);
  const [mostrarConfirmSenha, setMostrarConfirmSenha] = useState(false);

  // Handlers genéricos
  const handleChangeCad = (
    field: keyof CadastroData,
    value: string | boolean
  ) => {
    setForm((f) => ({ ...f, [field]: value }));
  };

  // Validações de cadastro
  const validaCampoCad = (field: keyof CadastroData) => {
    const e = { ...errosCad };
    const v = form[field];
    switch (field) {
      case "nome":
        e.nome =
          !v || (v as string).trim().length < 3
            ? "Nome deve ter ao menos 3 caracteres"
            : undefined;
        break;
      case "email":
        e.email = !v
          ? "E-mail obrigatório"
          : !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v as string)
          ? "Digite um e-mail válido"
          : undefined;
        break;
      case "cpf":
        e.cpf = !v
          ? "CPF obrigatório"
          : !/^\d{3}\.\d{3}\.\d{3}-\d{2}$/.test(v as string)
          ? "Formato: 000.000.000-00"
          : undefined;
        break;
      case "telefone":
        e.telefone = !v
          ? "Telefone obrigatório"
          : !/^\(\d{2}\) \d{5}-\d{4}$/.test(v as string)
          ? "Formato: (00) 00000-0000"
          : undefined;
        break;
      case "senha":
        e.senha = !v
          ? "Senha obrigatória"
          : (v as string).length < 8
          ? "Ao menos 8 caracteres"
          : undefined;
        break;
      case "confirmarSenha":
        e.confirmarSenha =
          (v as string) !== form.senha ? "As senhas não coincidem" : undefined;
        break;
      case "termos":
        e.termos = form.termos ? undefined : "Você precisa aceitar os termos";
        break;
    }
    setErrosCad(e);
  };

  // Submit cadastro
  const handleSubmitCad = (e: FormEvent) => {
    e.preventDefault();
    (Object.keys(form) as (keyof CadastroData)[]).forEach(validaCampoCad);
    if (!Object.values(errosCad).some((x) => x)) {
      alert("Formulário de cadastro enviado com sucesso!");
      setForm({ ...initialForm });
      setErrosCad({});
    }
  };

  return (
    <>
      <h1 className="mb-4">Formulário</h1>
      <p className="mb-4">
        O exemplo abaixo mostra como implementar validações em tempo real,
        feedback visual e mensagens de erro.
      </p>

      <div className="br-card">
        <div className="card-header">
          <h2>Cadastro de Usuário</h2>
        </div>
        <div className="card-content">
          <form onSubmit={handleSubmitCad} noValidate>
            <div className="row">
              <div className="col-md-6 mb-3">
                <BrInput
                  label="Nome Completo: (Obrigatório)"
                  id="nome"
                  density="medium"
                  custom-id="input-nome"
                  color-mode="light"
                  disabled={false}
                  is-active={false}
                  type="text"
                  value={form.nome}
                  state={errosCad.nome ? "danger" : undefined}
                  placeholder="Digite seu nome"
                  onInput={(e) =>
                    handleChangeCad(
                      "nome",
                      (e.target as HTMLInputElement).value
                    )
                  }
                  onBlur={() => validaCampoCad("nome")}
                >
                  {errosCad.nome && (
                    <BrMessage
                      slot="feedback"
                      state="danger"
                      is-feedback
                      message={errosCad.nome}
                      show-icon
                      aria-label={errosCad.nome}
                    />
                  )}
                </BrInput>
              </div>
              <div className="col-md-6 mb-3">
                <BrInput
                  label="E-mail: (Obrigatório)"
                  id="email"
                  value={form.email}
                  state={errosCad.email ? "danger" : undefined}
                  placeholder="seu.email@exemplo.com"
                  type="email"
                  onInput={(e) =>
                    handleChangeCad(
                      "email",
                      (e.target as HTMLInputElement).value
                    )
                  }
                  onBlur={() => validaCampoCad("email")}
                />
                {errosCad.email && (
                  <BrMessage
                    state="danger"
                    is-feedback
                    message={errosCad.email}
                    show-icon
                    aria-label={errosCad.email}
                  />
                )}
              </div>
            </div>
            <div className="row">
              <div className="col-md-6 mb-3">
                <BrInput
                  label="CPF: (Obrigatório)"
                  id="cpf"
                  value={form.cpf}
                  state={errosCad.cpf ? "danger" : undefined}
                  placeholder="000.000.000-00"
                  type="text"
                  onInput={(e) =>
                    handleChangeCad("cpf", (e.target as HTMLInputElement).value)
                  }
                  onBlur={() => validaCampoCad("cpf")}
                />
                {errosCad.cpf && (
                  <BrMessage
                    state="danger"
                    is-feedback
                    message={errosCad.cpf}
                    show-icon
                    aria-label={errosCad.cpf}
                  />
                )}
              </div>
              <div className="col-md-6 mb-3">
                <BrInput
                  label="Telefone: (Obrigatório)"
                  id="telefone"
                  value={form.telefone}
                  state={errosCad.telefone ? "danger" : undefined}
                  placeholder="(00) 00000-0000"
                  type="text"
                  onInput={(e) =>
                    handleChangeCad(
                      "telefone",
                      (e.target as HTMLInputElement).value
                    )
                  }
                  onBlur={() => validaCampoCad("telefone")}
                />
                {errosCad.telefone && (
                  <BrMessage
                    state="danger"
                    is-feedback
                    message={errosCad.telefone}
                    show-icon
                    aria-label={errosCad.telefone}
                  />
                )}
              </div>
            </div>
            <div className="row">
              <div className="col-md-6 mb-3">
                <BrInput
                  label="Senha: (Obrigatório)"
                  id="senha"
                  value={form.senha}
                  state={errosCad.senha ? "danger" : undefined}
                  placeholder="Digite sua senha"
                  type={mostrarSenha ? "text" : "password"}
                  onInput={(e) =>
                    handleChangeCad(
                      "senha",
                      (e.target as HTMLInputElement).value
                    )
                  }
                  onBlur={() => validaCampoCad("senha")}
                >
                  <BrButton
                    className="br-button"
                    type="button"
                    onClick={() => setMostrarSenha((s) => !s)}
                    aria-label="Exibir senha"
                  >
                    {mostrarSenha ? "Ocultar" : "Exibir"}
                  </BrButton>
                </BrInput>
                {errosCad.senha && (
                  <BrMessage
                    state="danger"
                    is-feedback
                    message={errosCad.senha}
                    show-icon
                    aria-label={errosCad.senha}
                  />
                )}
                {!errosCad.senha && form.senha && (
                  <div className="form-text">
                    A senha deve ter pelo menos 8 caracteres.
                  </div>
                )}
              </div>
              <div className="col-md-6 mb-3">
                <BrInput
                  label="Confirmar Senha: (Obrigatório)"
                  id="confirmarSenha"
                  value={form.confirmarSenha}
                  state={errosCad.confirmarSenha ? "danger" : undefined}
                  placeholder="Confirme sua senha"
                  type={mostrarConfirmSenha ? "text" : "password"}
                  onInput={(e) =>
                    handleChangeCad(
                      "confirmarSenha",
                      (e.target as HTMLInputElement).value
                    )
                  }
                  onBlur={() => validaCampoCad("confirmarSenha")}
                >
                  <BrButton
                    className="br-button"
                    type="button"
                    onClick={() => setMostrarConfirmSenha((s) => !s)}
                    aria-label="Exibir senha"
                  >
                    {mostrarConfirmSenha ? "Ocultar" : "Exibir"}
                  </BrButton>
                </BrInput>
                {errosCad.confirmarSenha && (
                  <BrMessage
                    state="danger"
                    is-feedback
                    message={errosCad.confirmarSenha}
                    show-icon
                    aria-label={errosCad.confirmarSenha}
                  />
                )}
              </div>
            </div>
            <div className="row">
              <div className="col-md-12 mb-3">
                <BrCheckbox
                  id="termos"
                  name="termos"
                  checked={form.termos}
                  onChange={(e) =>
                    handleChangeCad(
                      "termos",
                      (e.target as HTMLInputElement).checked
                    )
                  }
                  label="Li e concordo com os termos de uso e política de privacidade (Obrigatório)"
                />
                {errosCad.termos && (
                  <BrMessage
                    state="danger"
                    is-feedback
                    message={errosCad.termos}
                    show-icon
                    aria-label={errosCad.termos}
                  />
                )}
              </div>
            </div>

            <BrButton
              className="mr-2"
              type="button"
              emphasis="secondary"
              style={{ display: "inline-block" }}
              onClick={() => {
                setForm({ ...initialForm });
                setErrosCad({});
              }}
            >
              Limpar
            </BrButton>
            <BrButton
              type="submit"
              style={{ display: "inline-block" }}
              emphasis="primary"
            >
              Cadastrar
            </BrButton>
          </form>
        </div>
      </div>
    </>
  );
};

export default Formulario;
