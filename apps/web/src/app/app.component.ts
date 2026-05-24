import { CommonModule } from "@angular/common";
import { Component, inject } from "@angular/core";
import { Router, RouterModule } from "@angular/router";
import {
  BrBreadcrumb,
  BrButton,
} from "@govbr-ds/webcomponents-angular/standalone";
import { AuthService } from "./core/auth/auth.service";
import { FooterComponent } from "./shared/components/footer/footer.component";
import { HeaderComponent } from "./shared/components/header/header.component";
import { MenuComponent } from "./shared/components/menu/menu.component";

interface BreadcrumbItem {
  label: string;
  url?: string;
  active?: boolean;
}

@Component({
  selector: "app-root",
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    HeaderComponent,
    MenuComponent,
    FooterComponent,
    BrBreadcrumb,
    BrButton,
  ],
  templateUrl: "./app.component.html",
  styleUrls: ["./app.component.scss"],
})
export class AppComponent {
  protected readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  isMenuVisible = true;

  breadcrumbItems: BreadcrumbItem[] = [
    { label: "Augustus", url: "/", active: true },
  ];

  toggleMenu() {
    this.isMenuVisible = !this.isMenuVisible;
  }

  async sair(): Promise<void> {
    await this.auth.logout();
    await this.router.navigate(["/auth/login"], { queryParams: { logout: 1 } });
  }
}
