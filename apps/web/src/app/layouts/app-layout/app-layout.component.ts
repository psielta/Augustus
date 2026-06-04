import { CommonModule } from '@angular/common';
import { Component, inject, OnDestroy, OnInit } from '@angular/core';
import { NavigationEnd, Router, RouterModule } from '@angular/router';
import { filter, Subject, takeUntil } from 'rxjs';
import { BrBreadcrumb } from '@govbr-ds/webcomponents-angular/standalone';
import { AuthService } from '../../core/auth/auth.service';
import { FooterComponent } from '../../shared/components/footer/footer.component';
import { HeaderComponent } from '../../shared/components/header/header.component';
import { MenuComponent } from '../../shared/components/menu/menu.component';

interface BreadcrumbItem {
  label: string;
  url?: string;
  active?: boolean;
}

const MENU_STORAGE_KEY = 'augustus.ui.menuOpen';

@Component({
  selector: 'app-app-layout',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    HeaderComponent,
    MenuComponent,
    FooterComponent,
    BrBreadcrumb,
  ],
  templateUrl: './app-layout.component.html',
  styleUrls: ['./app-layout.component.scss'],
})
export class AppLayoutComponent implements OnInit, OnDestroy {
  protected readonly auth = inject(AuthService);
  private readonly router = inject(Router);
  private readonly destroy$ = new Subject<void>();

  menuOpen = true;
  breadcrumbItems: BreadcrumbItem[] = [
    { label: 'Augustus', url: '/', active: true },
  ];

  ngOnInit(): void {
    const mobile = window.matchMedia('(max-width: 768px)');
    const stored = localStorage.getItem(MENU_STORAGE_KEY);
    if (stored !== null) {
      this.menuOpen = stored === 'true';
    } else {
      this.menuOpen = !mobile.matches;
    }

    this.router.events
      .pipe(
        filter((e) => e instanceof NavigationEnd),
        takeUntil(this.destroy$),
      )
      .subscribe(() => this.closeMenu());
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
    if (!window.matchMedia('(max-width: 768px)').matches) {
      return;
    }
    this.menuOpen = false;
    localStorage.setItem(MENU_STORAGE_KEY, 'false');
  }

}