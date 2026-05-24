import { Routes } from '@angular/router';
import { naoAutenticadoGuard } from './core/auth/auth.guard';
import { HomeComponent } from './pages/home/home.component';

export const routes: Routes = [
  { path: '', component: HomeComponent },
  {
    path: 'formulario',
    loadComponent: () =>
      import('./pages/form/form.component').then((m) => m.FormComponent),
  },
  {
    path: 'cores',
    loadComponent: () =>
      import('./pages/colors/colors.component').then((m) => m.ColorsComponent),
  },
  {
    path: 'auth/login',
    canMatch: [naoAutenticadoGuard],
    loadComponent: () =>
      import('./pages/auth/login/login.component').then((m) => m.LoginComponent),
  },
  {
    path: 'auth/register',
    canMatch: [naoAutenticadoGuard],
    loadComponent: () =>
      import('./pages/auth/register/register.component').then(
        (m) => m.RegisterComponent,
      ),
  },
  {
    path: 'auth/verify-pending',
    loadComponent: () =>
      import('./pages/auth/verify-pending/verify-pending.component').then(
        (m) => m.VerifyPendingComponent,
      ),
  },
  {
    path: 'auth/verify-email',
    loadComponent: () =>
      import('./pages/auth/verify-email/verify-email.component').then(
        (m) => m.VerifyEmailComponent,
      ),
  },
  { path: '**', redirectTo: '' },
];
