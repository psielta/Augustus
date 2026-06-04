import { Component, ViewEncapsulation } from '@angular/core';
import { RouterLink, RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-auth-layout',
  standalone: true,
  imports: [RouterOutlet, RouterLink],
  templateUrl: './auth-layout.component.html',
  styleUrls: ['./auth-layout.component.scss'],
  encapsulation: ViewEncapsulation.None,
})
export class AuthLayoutComponent {}