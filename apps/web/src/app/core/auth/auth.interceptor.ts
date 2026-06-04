import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, from, switchMap, throwError } from 'rxjs';
import { AuthService } from './auth.service';
import { TokenStorage } from './token-storage';

const SKIP_PATHS = [
  '/api/auth/login',
  '/api/auth/register',
  '/api/auth/refresh',
  '/api/auth/verify-email',
  '/api/auth/resend-verification',
];

function isSkip(url: string): boolean {
  return SKIP_PATHS.some((p) => url.includes(p));
}

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const tokenStorage = inject(TokenStorage);
  const auth = inject(AuthService);

  let request = req;
  if (!isSkip(req.url)) {
    const token = tokenStorage.lerAccess();
    if (token) {
      request = req.clone({
        setHeaders: { Authorization: `Bearer ${token}` },
      });
    }
  }

  return next(request).pipe(
    catchError((err) => {
      if (err?.status !== 401 || isSkip(req.url)) {
        return throwError(() => err);
      }
      return from(auth.refresh()).pipe(
        switchMap((ok) => {
          if (!ok) {
            return throwError(() => err);
          }
          const novoToken = tokenStorage.lerAccess();
          if (!novoToken) {
            return throwError(() => err);
          }
          const retried = req.clone({
            setHeaders: { Authorization: `Bearer ${novoToken}` },
          });
          return next(retried);
        }),
      );
    }),
  );
};
