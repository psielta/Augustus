import { inject } from '@angular/core';
import { CanActivateFn, CanMatchFn, Router } from '@angular/router';
import { AuthService } from './auth.service';

export const authGuard: CanActivateFn = (_route, state) => {
  const auth = inject(AuthService);
  const router = inject(Router);
  if (auth.isAutenticado()) {
    return true;
  }
  return router.createUrlTree(['/auth/login'], {
    queryParams: { redirect: state.url },
  });
};

export const naoAutenticadoGuard: CanMatchFn = () => {
  const auth = inject(AuthService);
  const router = inject(Router);
  if (auth.isAutenticado()) {
    return router.createUrlTree(['/']);
  }
  return true;
};
