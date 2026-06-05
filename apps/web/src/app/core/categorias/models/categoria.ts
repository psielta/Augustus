export type TipoCategoria =
  | 'DESPESA'
  | 'RECEITA'
  | 'PAGAMENTO_CARTAO'
  | 'TRANSFERENCIA';

export interface Categoria {
  id: string;
  nome: string;
  tipo: TipoCategoria;
  categoriaPaiId?: string | null;
  corHex?: string | null;
  icone?: string | null;
  ordem: number;
  ativo: boolean;
  criadaPorTemplate: boolean;
  templateCodigo?: string | null;
  criadoEm: string;
  atualizadoEm: string;
}

export interface CategoriaInput {
  nome: string;
  tipo: TipoCategoria;
  categoriaPaiId?: string | null;
  corHex?: string | null;
  icone?: string | null;
  ordem?: number | null;
  ativo?: boolean | null;
}

/** Cor padrão ao criar categoria (vermelho). */
export const COR_CATEGORIA_PADRAO = '#CC0000';

export const TIPOS_CATEGORIA: { valor: TipoCategoria; rotulo: string }[] = [
  { valor: 'DESPESA', rotulo: 'Despesa' },
  { valor: 'RECEITA', rotulo: 'Receita' },
  { valor: 'PAGAMENTO_CARTAO', rotulo: 'Pagamento de cartão' },
  { valor: 'TRANSFERENCIA', rotulo: 'Transferência' },
];