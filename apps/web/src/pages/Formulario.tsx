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

function validaCampo(
  data: CadastroData,
  field: keyof CadastroData
): string | undefined {
  const v = data[field];
  switch (field) {
    case "nome":
      return !v || (v as string).trim().length < 3
        ? "Nome deve ter ao menos 3 caracteres"
        : undefined;
    case "email":
      if (!v) return "E-mail obrigatório";
      return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v as string)
        ? undefined
        : "Digite um e-mail válido";
    case "cpf":
      if (!v) return "CPF obrigatório";
      return /^\d{3}\.\d{3}\.\d{3}-\d{2}$/.test(v as string)
        ? undefined
        : "Formato: 000.000.000-00";
    case "telefone":
      if (!v) return "Telefone obrigatório";
      return /^\(\d{2}\) \d{5}-\d{4}$/.test(v as string)
        ? undefined
        : "Formato: (00) 00000-0000";
    case "senha":
      if (!v) return "Senha obrigatória";
      return (v as string).length < 8 ? "Ao menos 8 caracteres" : undefined;
    case "confirmarSenha":
      if (!v) return "Confirme sua senha";
      return (v as string) !== data.senha
        ? "As senhas não coincidem"
        : undefined;
    case "termos":
      return data.termos ? undefined : "Você precisa aceitar os termos";
    default:
      return undefined;
  }
}

function validaTodos(data: CadastroData): ErrosCadastro {
  const erros: ErrosCadastro = {};
  (Object.keys(data) as (keyof CadastroData)[]).forEach((field) => {
    if (field === "genero") return;
    const erro = validaCampo(data, field);
    if (erro) erros[field] = erro;
  });
  return erros;
}

const Formulario: React.FC = () => {
  const [form, setForm] = useState<CadastroData>({ ...initialForm });
  const [errosCad, setErrosCad] = useState<ErrosCadastro>({});

  const [mostrarSenha, setMostrarSenha] = useState(false);
  const [mostrarConfirmSenha, setMostrarConfirmSenha] = useState(false);

  const handleChangeCad = (
    field: keyof CadastroData,
    value: string | boolean
  ) => {
    setForm((f) => ({ ...f, [field]: value }));
  };

  const handleBlurCad = (field: keyof CadastroData) => {
    setErrosCad((prev) => ({ ...prev, [field]: validaCampo(form, field) }));
  };

  const handleSubmitCad = (e: FormEvent) => {
    e.preventDefault();
    const nextErrors = validaTodos(form);
    setErrosCad(nextErrors);
    if (Object.values(nextErrors).some((x) => x)) return;
    alert("Formulário de cadastro enviado com sucesso!");
    setForm({ ...initialForm });
    setErrosCad({});
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
                  {...({ autocomplete: "name" } as Record<string, string>)}
                  onInput={(e) =>
                    handleChangeCad(
                      "nome",
                      (e.target as HTMLInputElement).value
                    )
                  }
                  onBlur={() => handleBlurCad("nome")}
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
                  {...({ autocomplete: "email" } as Record<string, string>)}
                  onInput={(e) =>
                    handleChangeCad(
                      "email",
                      (e.target as HTMLInputElement).value
                    )
                  }
                  onBlur={() => handleBlurCad("email")}
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
                  {...({ autocomplete: "off" } as Record<string, string>)}
                  onInput={(e) =>
                    handleChangeCad("cpf", (e.target as HTMLInputElement).value)
                  }
                  onBlur={() => handleBlurCad("cpf")}
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
                  {...({ autocomplete: "tel-national" } as Record<string, string>)}
                  onInput={(e) =>
                    handleChangeCad(
                      "telefone",
                      (e.target as HTMLInputElement).value
                    )
                  }
                  onBlur={() => handleBlurCad("telefone")}
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
                  {...({ autocomplete: "new-password" } as Record<string, string>)}
                  onInput={(e) =>
                    handleChangeCad(
                      "senha",
                      (e.target as HTMLInputElement).value
                    )
                  }
                  onBlur={() => handleBlurCad("senha")}
                >
                  <BrButton
                    className="br-button"
                    type="button"
                    onClick={() => setMostrarSenha((s) => !s)}
                    aria-label={mostrarSenha ? "Ocultar senha" : "Mostrar senha"}
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
                  {...({ autocomplete: "new-password" } as Record<string, string>)}
                  onInput={(e) =>
                    handleChangeCad(
                      "confirmarSenha",
                      (e.target as HTMLInputElement).value
                    )
                  }
                  onBlur={() => handleBlurCad("confirmarSenha")}
                >
                  <BrButton
                    className="br-button"
                    type="button"
                    onClick={() => setMostrarConfirmSenha((s) => !s)}
                    aria-label={
                      mostrarConfirmSenha ? "Ocultar senha" : "Mostrar senha"
                    }
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
                      (e.target as unknown as HTMLInputElement).checked
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
