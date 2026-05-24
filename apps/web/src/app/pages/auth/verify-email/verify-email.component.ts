import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { BrMessage } from '@govbr-ds/webcomponents-angular/standalone';
import { AuthService } from '../../../core/auth/auth.service';
import {
  ProblemDetail,
  TipoErroAuth,
  extrairTipoErro,
  mensagemAmigavel,
} from '../../../core/auth/models/problem-detail';

type Status = 'processando' | 'sucesso' | 'erro' | 'sem-token';

@Component({
  selector: 'app-verify-email',
  standalone: true,
  imports: [CommonModule, RouterLink, BrMessage],
  templateUrl: './verify-email.component.html',
  styleUrls: ['./verify-email.component.scss'],
})
export class VerifyEmailComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly auth = inject(AuthService);

  status = signal<Status>('processando');
  mensagem = signal<string>('');
  tipoErro = signal<TipoErroAuth | null>(null);

  async ngOnInit(): Promise<void> {
    const token = this.route.snapshot.queryParamMap.get('token');
    if (!token) {
      this.status.set('sem-token');
      return;
    }
    const r = await this.auth.verificarEmailComToken(token);
    if (r.ok) {
      this.status.set('sucesso');
      this.mensagem.set('Email verificado. Redirecionando para o login...');
      setTimeout(() => {
        this.router.navigate(['/auth/login'], { queryParams: { verificado: 1 } });
      }, 1500);
      return;
    }
    this.status.set('erro');
    const tipo = extrairTipoErro(r.problem);
    this.tipoErro.set(tipo);
    this.mensagem.set(mensagemAmigavel(tipo, r.problem));
  }
}
