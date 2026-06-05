import { CommonModule } from '@angular/common';
import { Component, OnInit, computed, inject, signal } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  FormsModule,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import {
  BrCheckbox,
  BrInput,
  BrMessage,
} from '@govbr-ds/webcomponents-angular/standalone';
import { ProblemDetail } from '../../../core/auth/models/problem-detail';
import { CategoriaService } from '../../../core/categorias/categoria.service';
import {
  Categoria,
  CategoriaInput,
  COR_CATEGORIA_PADRAO,
  TipoCategoria,
} from '../../../core/categorias/models/categoria';

@Component({
  selector: 'app-categorias-form',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    RouterLink,
    BrInput,
    BrCheckbox,
    BrMessage,
  ],
  templateUrl: './categorias-form.component.html',
  styleUrls: ['./categorias-form.component.scss'],
})
export class CategoriasFormComponent implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly categoriaService = inject(CategoriaService);
  private readonly router = inject(Router);
  private readonly route = inject(ActivatedRoute);

  formulario!: FormGroup;
  modoEdicao = signal(false);
  categoriaId = signal<string | null>(null);
  carregando = signal(false);
  enviando = signal(false);
  erro = signal<ProblemDetail | null>(null);

  private readonly todasCategorias = signal<Categoria[]>([]);
  private readonly tipoAtual = signal<TipoCategoria>('DESPESA');
  readonly corPicker = signal(COR_CATEGORIA_PADRAO);

  readonly titulo = computed(() =>
    this.modoEdicao() ? 'Editar categoria' : 'Nova categoria',
  );

  readonly paisDisponiveis = computed(() => {
    const tipo = this.tipoAtual();
    const idAtual = this.categoriaId();
    return this.todasCategorias().filter(
      (c) =>
        c.tipo === tipo &&
        !c.categoriaPaiId &&
        c.id !== idAtual,
    );
  });

  ngOnInit(): void {
    this.formulario = this.fb.group({
      nome: ['', [Validators.required, Validators.maxLength(80)]],
      tipo: ['DESPESA' as TipoCategoria, Validators.required],
      categoriaPaiId: [''],
      corHex: [COR_CATEGORIA_PADRAO, [Validators.pattern(/^#?[0-9A-Fa-f]{6}$/)]],
      icone: ['', Validators.maxLength(60)],
      ordem: [0, [Validators.min(0)]],
      ativo: [true],
    });

    this.tipoAtual.set(this.formulario.get('tipo')!.value as TipoCategoria);
    this.corPicker.set(this.normalizarCor(this.formulario.get('corHex')!.value));

    this.formulario.get('tipo')?.valueChanges.subscribe((tipo: TipoCategoria) => {
      this.tipoAtual.set(tipo);
      this.formulario.patchValue({ categoriaPaiId: '' }, { emitEvent: false });
    });

    this.formulario.get('corHex')?.valueChanges.subscribe((valor: string) => {
      this.corPicker.set(this.normalizarCor(valor));
    });

    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.modoEdicao.set(true);
      this.categoriaId.set(id);
      void this.carregarEdicao(id);
    } else {
      void this.carregarPais();
    }
  }

  private async carregarPais(): Promise<void> {
    const resultado = await this.categoriaService.listar();
    if (resultado.ok) {
      this.todasCategorias.set(resultado.data);
    }
  }

  private async carregarEdicao(id: string): Promise<void> {
    this.carregando.set(true);
    this.erro.set(null);
    const [lista, categoria] = await Promise.all([
      this.categoriaService.listar(),
      this.categoriaService.buscarPorId(id),
    ]);
    this.carregando.set(false);

    if (lista.ok) {
      this.todasCategorias.set(lista.data);
    }
    if (!categoria.ok) {
      this.erro.set(categoria.problem);
      return;
    }

    const c = categoria.data;
    this.formulario.patchValue({
      nome: c.nome,
      tipo: c.tipo,
      categoriaPaiId: c.categoriaPaiId ?? '',
      corHex: c.corHex ?? COR_CATEGORIA_PADRAO,
      icone: c.icone ?? '',
      ordem: c.ordem,
      ativo: c.ativo,
    });
    this.tipoAtual.set(c.tipo);
    this.corPicker.set(this.normalizarCor(c.corHex ?? COR_CATEGORIA_PADRAO));
  }

  sincronizarCorDoPicker(valor: string): void {
    this.formulario.patchValue({ corHex: valor }, { emitEvent: false });
    this.corPicker.set(valor);
  }

  sincronizarPickerDoInput(): void {
    const valor = this.formulario.get('corHex')?.value as string;
    if (!valor) return;
    const normalizado = this.normalizarCor(valor);
    if (normalizado !== valor) {
      this.formulario.patchValue({ corHex: normalizado }, { emitEvent: false });
    }
    this.corPicker.set(normalizado);
  }

  private normalizarCor(valor: string | null | undefined): string {
    if (!valor) return COR_CATEGORIA_PADRAO;
    const hex = valor.startsWith('#') ? valor.slice(1) : valor;
    if (/^[0-9A-Fa-f]{6}$/.test(hex)) {
      return `#${hex}`;
    }
    return COR_CATEGORIA_PADRAO;
  }

  async enviar(): Promise<void> {
    if (this.formulario.invalid) {
      this.formulario.markAllAsTouched();
      return;
    }

    this.enviando.set(true);
    this.erro.set(null);

    const raw = this.formulario.getRawValue();
    const input: CategoriaInput = {
      nome: raw.nome.trim(),
      tipo: raw.tipo,
      categoriaPaiId: raw.categoriaPaiId || null,
      corHex: raw.corHex?.trim() || null,
      icone: raw.icone?.trim() || null,
      ordem: raw.ordem ?? 0,
      ativo: raw.ativo,
    };

    const resultado = this.modoEdicao()
      ? await this.categoriaService.atualizar(this.categoriaId()!, input)
      : await this.categoriaService.criar(input);

    this.enviando.set(false);

    if (!resultado.ok) {
      this.erro.set(resultado.problem);
      return;
    }

    await this.router.navigate(['/categorias']);
  }

  mensagemErro(): string {
    const p = this.erro();
    if (!p) return '';
    const slug = p.type?.split('/').pop();
    if (slug === 'categoria-ja-existe') {
      return 'Já existe uma categoria com este nome e tipo.';
    }
    if (slug === 'categoria-invalida') {
      return p.detail || 'Categoria inválida. Verifique a hierarquia.';
    }
    return p.detail || p.title || 'Erro ao salvar categoria.';
  }
}