import { CommonModule } from '@angular/common';
import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { BrButton, BrMessage } from '@govbr-ds/webcomponents-angular/standalone';
import { CategoriaService } from '../../../core/categorias/categoria.service';
import {
  Categoria,
  COR_CATEGORIA_PADRAO,
} from '../../../core/categorias/models/categoria';
import { ProblemDetail } from '../../../core/auth/models/problem-detail';

@Component({
  selector: 'app-categorias-list',
  standalone: true,
  imports: [CommonModule, RouterLink, BrButton, BrMessage],
  templateUrl: './categorias-list.component.html',
  styleUrls: ['./categorias-list.component.scss'],
})
export class CategoriasListComponent implements OnInit {
  private readonly categoriaService = inject(CategoriaService);

  readonly categorias = this.categoriaService.categorias;
  readonly carregando = this.categoriaService.carregando;

  erro = signal<ProblemDetail | null>(null);
  sucesso = signal<string | null>(null);
  confirmandoId = signal<string | null>(null);
  excluindo = signal(false);
  semeando = signal(false);

  readonly categoriasExibicao = computed(() => {
    const lista = this.categorias();
    const pais = lista.filter((c) => !c.categoriaPaiId);
    const filhasPorPai = new Map<string, Categoria[]>();
    for (const c of lista) {
      if (c.categoriaPaiId) {
        const arr = filhasPorPai.get(c.categoriaPaiId) ?? [];
        arr.push(c);
        filhasPorPai.set(c.categoriaPaiId, arr);
      }
    }
    const resultado: { categoria: Categoria; indent: boolean }[] = [];
    for (const pai of pais) {
      resultado.push({ categoria: pai, indent: false });
      const filhas = filhasPorPai.get(pai.id) ?? [];
      for (const filha of filhas) {
        resultado.push({ categoria: filha, indent: true });
      }
    }
    const orfas = lista.filter(
      (c) => c.categoriaPaiId && !pais.some((p) => p.id === c.categoriaPaiId),
    );
    for (const orfa of orfas) {
      resultado.push({ categoria: orfa, indent: true });
    }
    return resultado;
  });

  ngOnInit(): void {
    void this.recarregar();
  }

  async recarregar(): Promise<void> {
    this.erro.set(null);
    const resultado = await this.categoriaService.listar();
    if (!resultado.ok) {
      this.erro.set(resultado.problem);
    }
  }

  async semearPadrao(): Promise<void> {
    this.erro.set(null);
    this.sucesso.set(null);
    this.semeando.set(true);
    const resultado = await this.categoriaService.semearPadrao();
    this.semeando.set(false);
    if (!resultado.ok) {
      this.erro.set(resultado.problem);
      return;
    }
    const qtd = resultado.data.length;
    this.sucesso.set(
      qtd > 0
        ? `${qtd} categoria(s) padrão criada(s).`
        : 'Categorias padrão já estavam criadas.',
    );
    await this.recarregar();
  }

  iniciarExclusao(id: string): void {
    this.confirmandoId.set(id);
  }

  cancelarExclusao(): void {
    this.confirmandoId.set(null);
  }

  async confirmarExclusao(id: string): Promise<void> {
    this.erro.set(null);
    this.sucesso.set(null);
    this.excluindo.set(true);
    const resultado = await this.categoriaService.excluir(id);
    this.excluindo.set(false);
    this.confirmandoId.set(null);
    if (!resultado.ok) {
      this.erro.set(resultado.problem);
      return;
    }
    this.sucesso.set('Categoria excluída.');
    await this.recarregar();
  }

  corExibicao(corHex: string | null | undefined): string {
    if (!corHex) return COR_CATEGORIA_PADRAO;
    return corHex.startsWith('#') ? corHex : `#${corHex}`;
  }

  rotuloTipo(tipo: string): string {
    const mapa: Record<string, string> = {
      DESPESA: 'Despesa',
      RECEITA: 'Receita',
      PAGAMENTO_CARTAO: 'Pag. cartão',
      TRANSFERENCIA: 'Transferência',
    };
    return mapa[tipo] ?? tipo;
  }
}