import { Routes } from '@angular/router';
import { authGuard, naoAutenticadoGuard } from './core/auth/auth.guard';
import { AppLayoutComponent } from './layouts/app-layout/app-layout.component';
import { AuthLayoutComponent } from './layouts/auth-layout/auth-layout.component';
import { HomeComponent } from './pages/home/home.component';

export const routes: Routes = [
  {
    path: 'auth',
    component: AuthLayoutComponent,
    children: [
      {
        path: 'login',
        canMatch: [naoAutenticadoGuard],
        loadComponent: () =>
          import('./pages/auth/login/login.component').then((m) => m.LoginComponent),
      },
      {
        path: 'register',
        canMatch: [naoAutenticadoGuard],
        loadComponent: () =>
          import('./pages/auth/register/register.component').then(
            (m) => m.RegisterComponent,
          ),
      },
      {
        path: 'verify-pending',
        loadComponent: () =>
          import('./pages/auth/verify-pending/verify-pending.component').then(
            (m) => m.VerifyPendingComponent,
          ),
      },
      {
        path: 'verify-email',
        loadComponent: () =>
          import('./pages/auth/verify-email/verify-email.component').then(
            (m) => m.VerifyEmailComponent,
          ),
      },
    ],
  },
  {
    path: '',
    component: AppLayoutComponent,
    canActivateChild: [authGuard],
    children: [
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
    ],
  },
  { path: '**', redirectTo: '' },
];