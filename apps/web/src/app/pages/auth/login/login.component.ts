import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  FormsModule,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import {
  BrButton,
  BrInput,
  BrMessage,
} from '@govbr-ds/webcomponents-angular/standalone';
import { AuthService } from '../../../core/auth/auth.service';
import {
  ProblemDetail,
  TipoErroAuth,
  extrairTipoErro,
  mensagemAmigavel,
} from '../../../core/auth/models/problem-detail';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    RouterLink,
    BrInput,
    BrButton,
    BrMessage,
  ],
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss'],
})
export class LoginComponent implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);
  private readonly route = inject(ActivatedRoute);

  formulario!: FormGroup;
  mostrarSenha = false;

  enviando = signal(false);
  erro = signal<ProblemDetail | null>(null);
  tipoErro = signal<TipoErroAuth | null>(null);
  flashSucesso = signal<string | null>(null);
  reenvioPendente = signal(false);
  reenvioFeito = signal(false);
  reenvioErro = signal<string | null>(null);

  ngOnInit(): void {
    this.formulario = this.fb.group({
      email: ['', [Validators.required, Validators.email, Validators.maxLength(254)]],
      senha: ['', [Validators.required, Validators.minLength(8), Validators.maxLength(128)]],
    });

    const qp = this.route.snapshot.queryParamMap;
    if (qp.get('verificado') === '1') {
      this.flashSucesso.set('Email verificado. Faça login para continuar.');
    } else if (qp.get('logout') === '1') {
      this.flashSucesso.set('Você saiu com segurança.');
    }
  }

  async onSubmit(): Promise<void> {
    if (this.formulario.invalid) {
      this.formulario.markAllAsTouched();
      return;
    }
    this.enviando.set(true);
    this.erro.set(null);
    this.tipoErro.set(null);
    this.reenvioFeito.set(false);

    const { email, senha } = this.formulario.value as { email: string; senha: string };
    const r = await this.auth.login(email.trim(), senha);
    this.enviando.set(false);

    if (r.ok) {
      const redirect = this.route.snapshot.queryParamMap.get('redirect') ?? '/';
      await this.router.navigateByUrl(redirect);
      return;
    }
    this.erro.set(r.problem);
    this.tipoErro.set(extrairTipoErro(r.problem));
  }

  mensagemErro(): string {
    const tipo = this.tipoErro();
    if (!tipo) return '';
    return mensagemAmigavel(tipo, this.erro());
  }

  async reenviarVerificacao(): Promise<void> {
    const email = (this.formulario.value.email as string | undefined)?.trim();
    if (!email) {
      return;
    }
    this.reenvioPendente.set(true);
    this.reenvioFeito.set(false);
    this.reenvioErro.set(null);
    const r = await this.auth.reenviarVerificacao(email);
    this.reenvioPendente.set(false);
    if (r.ok) {
      this.reenvioFeito.set(true);
      return;
    }
    const tipo = extrairTipoErro(r.problem);
    this.reenvioErro.set(mensagemAmigavel(tipo, r.problem));
  }
}
