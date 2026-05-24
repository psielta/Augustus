import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  FormsModule,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
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
  selector: 'app-register',
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
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.scss'],
})
export class RegisterComponent implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  formulario!: FormGroup;
  mostrarSenha = false;

  enviando = signal(false);
  erro = signal<ProblemDetail | null>(null);
  tipoErro = signal<TipoErroAuth | null>(null);

  ngOnInit(): void {
    this.formulario = this.fb.group({
      nome: ['', [Validators.required, Validators.maxLength(120)]],
      email: ['', [Validators.required, Validators.email, Validators.maxLength(254)]],
      senha: [
        '',
        [Validators.required, Validators.minLength(8), Validators.maxLength(128)],
      ],
    });
  }

  async onSubmit(): Promise<void> {
    if (this.formulario.invalid) {
      this.formulario.markAllAsTouched();
      return;
    }
    this.enviando.set(true);
    this.erro.set(null);
    this.tipoErro.set(null);

    const { nome, email, senha } = this.formulario.value as {
      nome: string;
      email: string;
      senha: string;
    };

    const r = await this.auth.registrar({
      nome: nome.trim(),
      email: email.trim(),
      senha,
    });
    this.enviando.set(false);

    if (r.ok) {
      await this.router.navigate(['/auth/verify-pending'], {
        queryParams: { email: r.data.usuario.email },
      });
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
}
