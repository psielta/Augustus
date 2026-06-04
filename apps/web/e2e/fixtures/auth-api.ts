import type { Page, Route } from '@playwright/test';

export const USUARIO_MOCK = {
  id: '00000000-0000-0000-0000-000000000001',
  nome: 'Maria E2E',
  email: 'maria@augustus.test',
  status: 'ATIVO' as const,
  papelSistema: 'USUARIO' as const,
  emailVerificado: true,
  criadoEm: '2026-01-01T00:00:00Z',
};

export const TOKENS_MOCK = {
  accessToken: 'e2e-access-token',
  refreshToken: 'e2e-refresh-token',
  accessTokenExpiraEm: '2099-12-31T23:59:59Z',
  refreshTokenExpiraEm: '2099-12-31T23:59:59Z',
  tokenType: 'Bearer',
};

const AUTH_PREFIX = '**/api/auth/';

export async function mockAuthApiAnonimo(page: Page): Promise<void> {
  await page.route(`${AUTH_PREFIX}**`, async (route: Route) => {
    const path = new URL(route.request().url()).pathname;

    if (route.request().method() === 'POST' && path.endsWith('/auth/refresh')) {
      await route.fulfill({
        status: 401,
        contentType: 'application/problem+json',
        body: JSON.stringify({
          type: '/api/auth/refresh-token-invalido',
          title: 'Refresh invalido',
          status: 401,
        }),
      });
      return;
    }

    if (route.request().method() === 'GET' && path.endsWith('/auth/me')) {
      await route.fulfill({
        status: 401,
        contentType: 'application/problem+json',
        body: JSON.stringify({
          type: '/api/auth/nao-autenticado',
          title: 'Nao autenticado',
          status: 401,
        }),
      });
      return;
    }

    if (route.request().method() === 'POST' && path.endsWith('/auth/login')) {
      await route.fulfill({ status: 200, json: TOKENS_MOCK });
      return;
    }

    if (route.request().method() === 'POST' && path.endsWith('/auth/logout')) {
      await route.fulfill({ status: 204, body: '' });
      return;
    }

    await route.continue();
  });
}

export async function mockAuthApiAutenticado(page: Page): Promise<void> {
  await page.route(`${AUTH_PREFIX}**`, async (route: Route) => {
    const path = new URL(route.request().url()).pathname;
    const method = route.request().method();

    if (method === 'POST' && path.endsWith('/auth/refresh')) {
      await route.fulfill({ status: 200, json: TOKENS_MOCK });
      return;
    }

    if (method === 'GET' && path.endsWith('/auth/me')) {
      await route.fulfill({ status: 200, json: USUARIO_MOCK });
      return;
    }

    if (method === 'POST' && path.endsWith('/auth/login')) {
      await route.fulfill({ status: 200, json: TOKENS_MOCK });
      return;
    }

    if (method === 'POST' && path.endsWith('/auth/logout')) {
      await route.fulfill({ status: 204, body: '' });
      return;
    }

    await route.continue();
  });
}

export async function seedSessaoAutenticada(page: Page): Promise<void> {
  await page.addInitScript((tokens) => {
    localStorage.setItem('augustus.auth.access', tokens.accessToken);
    localStorage.setItem('augustus.auth.refresh', tokens.refreshToken);
    localStorage.setItem('augustus.auth.accessExpiraEm', tokens.accessTokenExpiraEm);
    localStorage.setItem('augustus.auth.refreshExpiraEm', tokens.refreshTokenExpiraEm);
  }, TOKENS_MOCK);
}

export async function limparSessao(page: Page): Promise<void> {
  await page.addInitScript(() => {
    localStorage.removeItem('augustus.auth.access');
    localStorage.removeItem('augustus.auth.refresh');
    localStorage.removeItem('augustus.auth.accessExpiraEm');
    localStorage.removeItem('augustus.auth.refreshExpiraEm');
  });
}