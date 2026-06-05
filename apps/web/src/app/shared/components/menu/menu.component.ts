import { CommonModule } from '@angular/common';
import { Component, EventEmitter, OnDestroy, OnInit, Output } from '@angular/core';
import { NavigationEnd, Router, RouterModule } from '@angular/router';
import { Subject } from 'rxjs';
import { filter, takeUntil } from 'rxjs/operators';
import { MenuItem } from './menu-item.model';

@Component({
  selector: 'app-menu',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './menu.component.html',
  styleUrls: ['./menu.component.scss'],
})
export class MenuComponent implements OnInit, OnDestroy {
  @Output() readonly fecharMenu = new EventEmitter<void>();

  itemAtivo: string | null = null;
  private readonly destroy$ = new Subject<void>();

  constructor(private readonly router: Router) {}

  ngOnInit(): void {
    this.setActiveItemFromRoute(this.router.url);

    this.router.events
      .pipe(
        filter((event) => event instanceof NavigationEnd),
        takeUntil(this.destroy$),
      )
      .subscribe((event: NavigationEnd) => {
        this.setActiveItemFromRoute(event.url);
      });
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  readonly menuItems: MenuItem[] = [
    { id: 'home', name: 'Home', icon: 'fas fa-home', url: '/' },
    {
      id: 'form',
      name: 'Formulário',
      icon: 'fas fa-check-circle',
      url: '/formulario',
    },
    {
      id: 'cores',
      name: 'Cores',
      icon: 'fas fa-palette',
      url: '/cores',
    },
    {
      id: 'categorias',
      name: 'Categorias',
      icon: 'fas fa-tags',
      url: '/categorias',
    },
  ];

  setActiveItemFromRoute(url: string): void {
    const cleanUrl = url.split('?')[0];
    const routeToIdMap: Record<string, string> = {
      '/': 'home',
      '/formulario': 'form',
      '/cores': 'cores',
      '/categorias': 'categorias',
    };

    if (cleanUrl.startsWith('/categorias')) {
      this.itemAtivo = 'categorias';
      return;
    }

    this.itemAtivo = routeToIdMap[cleanUrl] ?? null;
  }
}