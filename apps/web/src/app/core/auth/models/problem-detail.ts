export interface ProblemDetail {
  type?: string;
  title?: string;
  status?: number;
  detail?: string;
  instance?: string;
  timestamp?: string;
  [property: string]: unknown;
}

export type TipoErroAuth =
  | 'EMAIL_JA_CADASTRADO'
  | 'EMAIL_NAO_VERIFICADO'
  | 'CREDENCIAIS_INVALIDAS'
  | 'USUARIO_BLOQUEADO'
  | 'REFRESH_TOKEN_INVALIDO'
  | 'TOKEN_VERIFICACAO_INVALIDO'
  | 'NAO_AUTENTICADO'
  | 'ENVIO_EMAIL_FALHOU'
  | 'CAMPO_INVALIDO'
  | 'DESCONHECIDO';

const SLUG_PARA_TIPO: Record<string, TipoErroAuth> = {
  'email-ja-cadastrado': 'EMAIL_JA_CADASTRADO',
  'email-nao-verificado': 'EMAIL_NAO_VERIFICADO',
  'credenciais-invalidas': 'CREDENCIAIS_INVALIDAS',
  'usuario-bloqueado': 'USUARIO_BLOQUEADO',
  'refresh-token-invalido': 'REFRESH_TOKEN_INVALIDO',
  'token-verificacao-invalido': 'TOKEN_VERIFICACAO_INVALIDO',
  'nao-autenticado': 'NAO_AUTENTICADO',
  'envio-email-falhou': 'ENVIO_EMAIL_FALHOU',
};

const PREFIXO_PARA_TIPO: Record<string, TipoErroAuth> = {
  EMAIL_JA_CADASTRADO: 'EMAIL_JA_CADASTRADO',
  EMAIL_NAO_VERIFICADO: 'EMAIL_NAO_VERIFICADO',
  CREDENCIAIS_INVALIDAS: 'CREDENCIAIS_INVALIDAS',
  USUARIO_BLOQUEADO: 'USUARIO_BLOQUEADO',
  REFRESH_TOKEN_INVALIDO: 'REFRESH_TOKEN_INVALIDO',
  TOKEN_VERIFICACAO_INVALIDO: 'TOKEN_VERIFICACAO_INVALIDO',
  NAO_AUTENTICADO: 'NAO_AUTENTICADO',
  ENVIO_EMAIL_FALHOU: 'ENVIO_EMAIL_FALHOU',
};

export function extrairTipoErro(problem: ProblemDetail | undefined | null): TipoErroAuth {
  if (!problem) {
    return 'DESCONHECIDO';
  }

  if (problem.type) {
    const slug = problem.type.split('/').pop()?.toLowerCase() ?? '';
    const porSlug = SLUG_PARA_TIPO[slug];
    if (porSlug) {
      return porSlug;
    }
  }

  if (problem.detail) {
    const prefixo = problem.detail.split(':', 1)[0]?.trim();
    if (prefixo) {
      const porPrefixo = PREFIXO_PARA_TIPO[prefixo];
      if (porPrefixo) {
        return porPrefixo;
      }
    }
  }

  if (problem.status === 400 && problem.title?.toLowerCase().includes('campo')) {
    return 'CAMPO_INVALIDO';
  }

  if (problem.status === 401) {
    return 'NAO_AUTENTICADO';
  }

  return 'DESCONHECIDO';
}

export function mensagemAmigavel(tipo: TipoErroAuth, problem?: ProblemDetail | null): string {
  switch (tipo) {
    case 'EMAIL_JA_CADASTRADO':
      return 'Este email já está cadastrado. Tente fazer login.';
    case 'EMAIL_NAO_VERIFICADO':
      return 'Verifique seu email antes de fazer login. Cheque sua caixa de entrada.';
    case 'CREDENCIAIS_INVALIDAS':
      return 'Email ou senha inválidos.';
    case 'USUARIO_BLOQUEADO':
      return 'Conta bloqueada temporariamente após várias tentativas. Aguarde alguns minutos.';
    case 'REFRESH_TOKEN_INVALIDO':
    case 'NAO_AUTENTICADO':
      return 'Sua sessão expirou. Faça login novamente.';
    case 'TOKEN_VERIFICACAO_INVALIDO':
      return 'Token inválido, expirado ou já utilizado.';
    case 'ENVIO_EMAIL_FALHOU':
      return 'Não foi possível enviar o email agora. Tente novamente em alguns minutos.';
    case 'CAMPO_INVALIDO':
      return problem?.detail ?? 'Há campos inválidos no formulário.';
    default:
      return problem?.detail ?? problem?.title ?? 'Ocorreu um erro. Tente novamente.';
  }
}
