import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  EventEmitter,
  Input,
  Output,
  inject,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { BrButton } from '@govbr-ds/webcomponents-angular/standalone';
import { AuthService } from '../../../core/auth/auth.service';

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [CommonModule, RouterModule, FormsModule, BrButton],
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class HeaderComponent {
  @Input() public logoUrl = 'assets/brand/augustus-symbol.svg';
  @Input() public logoAlt = 'Augustus';
  @Input() public headerSign =
    'Augustus - Controlador de finanças pessoais';
  @Input() public headerTitle = 'Augustus';
  @Input() public headerSubtitle = 'Controlador de finanças pessoais';
  @Input() public searchLabel = 'Texto da pesquisa';
  @Input() public searchPlaceholder = 'O que você procura?';
  @Input() public menuVisible = false;
  @Output() public menuToggled = new EventEmitter<boolean>();
  @Output() public searchSubmitted = new EventEmitter<string>();

  public isSearchOpen = false;
  public searchQuery = '';

  protected readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  public toggleMenu(): void {
    this.menuVisible = !this.menuVisible;
    this.menuToggled.emit(this.menuVisible);
  }

  public openSearch(): void {
    this.isSearchOpen = true;
  }

  public closeSearch(): void {
    this.isSearchOpen = false;
    this.searchQuery = '';
  }

  public submitSearch(): void {
    const termo = this.searchQuery.trim();
    if (termo) {
      this.searchSubmitted.emit(termo);
    }
  }

  async onSair(): Promise<void> {
    await this.auth.logout();
    await this.router.navigate(['/auth/login'], { queryParams: { logout: 1 } });
  }
}