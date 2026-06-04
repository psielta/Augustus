import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import {
  BrButton,
  BrMessage,
} from '@govbr-ds/webcomponents-angular/standalone';
import { AuthService } from '../../../core/auth/auth.service';
import {
  extrairTipoErro,
  mensagemAmigavel,
} from '../../../core/auth/models/problem-detail';

@Component({
  selector: 'app-verify-pending',
  standalone: true,
  imports: [CommonModule, RouterLink, BrButton, BrMessage],
  templateUrl: './verify-pending.component.html',
  styleUrls: ['./verify-pending.component.scss'],
})
export class VerifyPendingComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly auth = inject(AuthService);

  email = signal<string | null>(null);
  reenvioPendente = signal(false);
  reenvioFeito = signal(false);
  reenvioErro = signal<string | null>(null);

  ngOnInit(): void {
    const e =
      this.route.snapshot.queryParamMap.get('email') ?? this.auth.emailEmVerificacao();
    this.email.set(e);
  }

  async reenviar(): Promise<void> {
    const e = this.email();
    if (!e) return;
    this.reenvioPendente.set(true);
    this.reenvioFeito.set(false);
    this.reenvioErro.set(null);
    const r = await this.auth.reenviarVerificacao(e);
    this.reenvioPendente.set(false);
    if (r.ok) {
      this.reenvioFeito.set(true);
      return;
    }
    const tipo = extrairTipoErro(r.problem);
    this.reenvioErro.set(mensagemAmigavel(tipo, r.problem));
  }
}
