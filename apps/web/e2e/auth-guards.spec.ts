import { expect, test } from '@playwright/test';
import {
  limparSessao,
  mockAuthApiAnonimo,
  mockAuthApiAutenticado,
  seedSessaoAutenticada,
  USUARIO_MOCK,
} from './fixtures/auth-api';

test.describe('Guards e layouts de auth', () => {
  test.beforeEach(async ({ page }) => {
    await limparSessao(page);
    await mockAuthApiAnonimo(page);
  });

  test('deslogado em / redireciona para login com redirect', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveURL(/\/auth\/login\?redirect=%2F/);
    await expect(page.getByRole('heading', { name: 'Entrar no Augustus' })).toBeVisible();
    await expect(page.locator('.auth-layout__brand-title')).toHaveText('Augustus');
  });

  test('logado em /auth/login redireciona para home', async ({ page }) => {
    await mockAuthApiAutenticado(page);
    await seedSessaoAutenticada(page);
    await page.goto('/auth/login');
    await expect(page).toHaveURL('/');
    await expect(page.getByText(`Olá, ${USUARIO_MOCK.nome}`)).toBeVisible();
  });

  test('pagina de registro usa AuthLayout sem chrome admin', async ({ page }) => {
    await page.goto('/auth/register');
    await expect(
      page.getByRole('heading', { name: 'Criar conta no Augustus' }),
    ).toBeVisible();
    await expect(page.locator('.br-header')).toHaveCount(0);
    await expect(page.locator('.augustus-footer')).toHaveCount(0);
  });
});