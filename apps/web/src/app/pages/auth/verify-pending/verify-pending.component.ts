import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import {
  BrButton,
  BrMessage,
} from '@govbr-ds/webcomponents-angular/standalone';
import { AuthService } from '../../../core/auth/auth.service';

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

  ngOnInit(): void {
    const e =
      this.route.snapshot.queryParamMap.get('email') ?? this.auth.emailEmVerificacao();
    this.email.set(e);
  }

  async reenviar(): Promise<void> {
    const e = this.email();
    if (!e) return;
    this.reenvioPendente.set(true);
    await this.auth.reenviarVerificacao(e);
    this.reenvioPendente.set(false);
    this.reenvioFeito.set(true);
  }
}
