export type StatusUsuario =
  | 'ATIVO'
  | 'PENDENTE_VERIFICACAO'
  | 'BLOQUEADO'
  | 'DESATIVADO';

export type PapelSistema = 'USUARIO' | 'ADMIN';

export interface Usuario {
  id: string;
  nome: string;
  email: string;
  status: StatusUsuario;
  papelSistema: PapelSistema;
  emailVerificado: boolean;
  criadoEm: string;
}
