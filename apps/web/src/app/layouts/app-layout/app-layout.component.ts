import { CommonModule } from '@angular/common';
import { Component, inject, OnDestroy, OnInit } from '@angular/core';
import { NavigationEnd, Router, RouterModule } from '@angular/router';
import { filter, Subject, takeUntil } from 'rxjs';
import { AuthService } from '../../core/auth/auth.service';
import { FooterComponent } from '../../shared/components/footer/footer.component';
import { HeaderComponent } from '../../shared/components/header/header.component';
import { MenuComponent } from '../../shared/components/menu/menu.component';

interface BreadcrumbItem {
  label: string;
  url?: string;
}

const MENU_STORAGE_KEY = 'augustus.ui.menuOpen';

const ROUTE_BREADCRUMBS: Record<string, BreadcrumbItem[]> = {
  '/': [{ label: 'Augustus' }],
  '/formulario': [
    { label: 'Augustus', url: '/' },
    { label: 'Formulário' },
  ],
  '/cores': [
    { label: 'Augustus', url: '/' },
    { label: 'Cores' },
  ],
  '/categorias': [
    { label: 'Augustus', url: '/' },
    { label: 'Categorias' },
  ],
  '/categorias/nova': [
    { label: 'Augustus', url: '/' },
    { label: 'Categorias', url: '/categorias' },
    { label: 'Nova' },
  ],
};

@Component({
  selector: 'app-app-layout',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    HeaderComponent,
    MenuComponent,
    FooterComponent,
  ],
  templateUrl: './app-layout.component.html',
  styleUrls: ['./app-layout.component.scss'],
})
export class AppLayoutComponent implements OnInit, OnDestroy {
  protected readonly auth = inject(AuthService);
  private readonly router = inject(Router);
  private readonly destroy$ = new Subject<void>();

  menuOpen = false;
  breadcrumbItems: BreadcrumbItem[] = [{ label: 'Augustus' }];

  ngOnInit(): void {
    const stored = localStorage.getItem(MENU_STORAGE_KEY);
    if (stored !== null) {
      this.menuOpen = stored === 'true';
    }

    this.atualizarBreadcrumb(this.router.url);

    this.router.events
      .pipe(
        filter((e) => e instanceof NavigationEnd),
        takeUntil(this.destroy$),
      )
      .subscribe((event: NavigationEnd) => {
        this.atualizarBreadcrumb(event.urlAfterRedirects);
        this.closeMenuOnNavigate();
      });
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  toggleMenu(): void {
    this.menuOpen = !this.menuOpen;
    localStorage.setItem(MENU_STORAGE_KEY, String(this.menuOpen));
  }

  closeMenu(): void {
    this.menuOpen = false;
    localStorage.setItem(MENU_STORAGE_KEY, 'false');
  }

  private closeMenuOnNavigate(): void {
    this.closeMenu();
  }

  private atualizarBreadcrumb(url: string): void {
    const path = url.split('?')[0];
    if (path.startsWith('/categorias/') && path.endsWith('/editar')) {
      this.breadcrumbItems = [
        { label: 'Augustus', url: '/' },
        { label: 'Categorias', url: '/categorias' },
        { label: 'Editar' },
      ];
      return;
    }
    this.breadcrumbItems = ROUTE_BREADCRUMBS[path] ?? [{ label: 'Augustus' }];
  }
}