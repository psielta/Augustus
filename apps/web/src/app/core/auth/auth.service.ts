import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Injectable, computed, inject, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { ProblemDetail } from './models/problem-detail';
import { Registro } from './models/registro';
import { TokenPair } from './models/token-pair';
import { Usuario } from './models/usuario';
import { TokenStorage } from './token-storage';

export type StatusAuth = 'inicializando' | 'anonimo' | 'autenticado';

export type Resultado<T> =
  | { ok: true; data: T }
  | { ok: false; problem: ProblemDetail };

export interface RegistrarInput {
  nome: string;
  email: string;
  senha: string;
}

const API_BASE = '/api/auth';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly http = inject(HttpClient);
  private readonly tokenStorage = inject(TokenStorage);

  private readonly _usuario = signal<Usuario | null>(null);
  private readonly _status = signal<StatusAuth>('inicializando');
  private readonly _precisaVerificarEmail = signal(false);
  private readonly _emailEmVerificacao = signal<string | null>(null);

  readonly usuario = this._usuario.asReadonly();
  readonly status = this._status.asReadonly();
  readonly precisaVerificarEmail = this._precisaVerificarEmail.asReadonly();
  readonly emailEmVerificacao = this._emailEmVerificacao.asReadonly();
  readonly isAutenticado = computed(() => this._status() === 'autenticado');

  private refreshEmAndamento: Promise<boolean> | null = null;

  async registrar(input: RegistrarInput): Promise<Resultado<Registro>> {
    try {
      const data = await firstValueFrom(
        this.http.post<Registro>(`${API_BASE}/register`, input),
      );
      this._emailEmVerificacao.set(input.email);
      this._precisaVerificarEmail.set(true);
      return { ok: true, data };
    } catch (err) {
      return { ok: false, problem: this.toProblem(err) };
    }
  }

  async login(email: string, senha: string): Promise<Resultado<Usuario>> {
    try {
      const tokens = await firstValueFrom(
        this.http.post<TokenPair>(`${API_BASE}/login`, { email, senha }),
      );
      this.tokenStorage.salvar(tokens);
      this._precisaVerificarEmail.set(false);
      this._emailEmVerificacao.set(null);
      return await this.carregarMe();
    } catch (err) {
      const problem = this.toProblem(err);
      const slug = problem.type?.split('/').pop();
      if (slug === 'email-nao-verificado') {
        this._precisaVerificarEmail.set(true);
        this._emailEmVerificacao.set(email);
      }
      return { ok: false, problem };
    }
  }

  async verificarEmailComToken(token: string): Promise<Resultado<void>> {
    try {
      await firstValueFrom(
        this.http.post<void>(`${API_BASE}/verify-email`, { token }),
      );
      this._precisaVerificarEmail.set(false);
      return { ok: true, data: undefined };
    } catch (err) {
      return { ok: false, problem: this.toProblem(err) };
    }
  }

  async reenviarVerificacao(email: string): Promise<Resultado<void>> {
    try {
      await firstValueFrom(
        this.http.post<void>(`${API_BASE}/resend-verification`, { email }),
      );
      return { ok: true, data: undefined };
    } catch (err) {
      return { ok: false, problem: this.toProblem(err) };
    }
  }

  async carregarMe(): Promise<Resultado<Usuario>> {
    try {
      const usuario = await firstValueFrom(
        this.http.get<Usuario>(`${API_BASE}/me`),
      );
      this._usuario.set(usuario);
      this._status.set('autenticado');
      return { ok: true, data: usuario };
    } catch (err) {
      this._usuario.set(null);
      this._status.set('anonimo');
      return { ok: false, problem: this.toProblem(err) };
    }
  }

  async logout(): Promise<void> {
    try {
      await firstValueFrom(this.http.post<void>(`${API_BASE}/logout`, {}));
    } catch {
      // Logout local sempre, mesmo se o servidor falhar.
    } finally {
      this.tokenStorage.limpar();
      this._usuario.set(null);
      this._status.set('anonimo');
      this._precisaVerificarEmail.set(false);
      this._emailEmVerificacao.set(null);
    }
  }

  /**
   * Single-flight refresh: chamadas concorrentes compartilham a mesma promise.
   * Retorna true se obteve novo par de tokens.
   */
  refresh(): Promise<boolean> {
    if (this.refreshEmAndamento) {
      return this.refreshEmAndamento;
    }
    const refreshToken = this.tokenStorage.lerRefresh();
    if (!refreshToken) {
      return Promise.resolve(false);
    }
    this.refreshEmAndamento = (async () => {
      try {
        const tokens = await firstValueFrom(
          this.http.post<TokenPair>(`${API_BASE}/refresh`, { refreshToken }),
        );
        this.tokenStorage.salvar(tokens);
        return true;
      } catch {
        this.tokenStorage.limpar();
        return false;
      } finally {
        this.refreshEmAndamento = null;
      }
    })();
    return this.refreshEmAndamento;
  }

  async restaurarSessao(): Promise<void> {
    const refresh = this.tokenStorage.lerRefresh();
    if (!refresh) {
      this._status.set('anonimo');
      return;
    }
    const ok = await this.refresh();
    if (!ok) {
      this._usuario.set(null);
      this._status.set('anonimo');
      return;
    }
    await this.carregarMe();
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
