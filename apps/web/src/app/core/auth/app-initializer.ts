import { inject } from '@angular/core';
import { AuthService } from './auth.service';

export function inicializarAuth(): () => Promise<void> {
  return async () => {
    const auth = inject(AuthService);
    await auth.restaurarSessao();
  };
}
