import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Injectable, inject, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { ProblemDetail } from '../auth/models/problem-detail';
import { Categoria, CategoriaInput } from './models/categoria';

export type Resultado<T> =
  | { ok: true; data: T }
  | { ok: false; problem: ProblemDetail };

const API_BASE = '/api/categorias';

@Injectable({ providedIn: 'root' })
export class CategoriaService {
  private readonly http = inject(HttpClient);

  private readonly _categorias = signal<Categoria[]>([]);
  private readonly _carregando = signal(false);

  readonly categorias = this._categorias.asReadonly();
  readonly carregando = this._carregando.asReadonly();

  async listar(): Promise<Resultado<Categoria[]>> {
    this._carregando.set(true);
    try {
      const data = await firstValueFrom(
        this.http.get<Categoria[]>(API_BASE),
      );
      this._categorias.set(data);
      return { ok: true, data };
    } catch (err) {
      return { ok: false, problem: this.toProblem(err) };
    } finally {
      this._carregando.set(false);
    }
  }

  async buscarPorId(id: string): Promise<Resultado<Categoria>> {
    try {
      const data = await firstValueFrom(
        this.http.get<Categoria>(`${API_BASE}/${id}`),
      );
      return { ok: true, data };
    } catch (err) {
      return { ok: false, problem: this.toProblem(err) };
    }
  }

  async criar(input: CategoriaInput): Promise<Resultado<Categoria>> {
    try {
      const data = await firstValueFrom(
        this.http.post<Categoria>(API_BASE, input),
      );
      return { ok: true, data };
    } catch (err) {
      return { ok: false, problem: this.toProblem(err) };
    }
  }

  async atualizar(id: string, input: CategoriaInput): Promise<Resultado<Categoria>> {
    try {
      const data = await firstValueFrom(
        this.http.put<Categoria>(`${API_BASE}/${id}`, input),
      );
      return { ok: true, data };
    } catch (err) {
      return { ok: false, problem: this.toProblem(err) };
    }
  }

  async excluir(id: string): Promise<Resultado<void>> {
    try {
      await firstValueFrom(this.http.delete<void>(`${API_BASE}/${id}`));
      return { ok: true, data: undefined };
    } catch (err) {
      return { ok: false, problem: this.toProblem(err) };
    }
  }

  async semearPadrao(): Promise<Resultado<Categoria[]>> {
    try {
      const data = await firstValueFrom(
        this.http.post<Categoria[]>(`${API_BASE}/semear-padrao`, null),
      );
      return { ok: true, data };
    } catch (err) {
      return { ok: false, problem: this.toProblem(err) };
    }
  }

  private toProblem(err: unknown): ProblemDetail {
    if (err instanceof HttpErrorResponse) {
      if (err.error && typeof err.error === 'object') {
        return err.error as ProblemDetail;
      }
      return {
        status: err.status,
        title: err.statusText || 'Erro de rede',
        detail: typeof err.error === 'string' ? err.error : err.message,
      };
    }
    return {
      title: 'Erro desconhecido',
      detail: err instanceof Error ? err.message : String(err),
    };
  }
}