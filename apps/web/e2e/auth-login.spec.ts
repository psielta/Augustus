import { expect, test } from '@playwright/test';
import {
  limparSessao,
  mockAuthApiAnonimo,
  mockAuthApiAutenticado,
  USUARIO_MOCK,
} from './fixtures/auth-api';

test.describe('Login e redirect seguro', () => {
  test.beforeEach(async ({ page }) => {
    await limparSessao(page);
    await mockAuthApiAnonimo(page);
    await mockAuthApiAutenticado(page);
  });

  async function preencherLogin(page: import('@playwright/test').Page): Promise<void> {
    await page.locator('input[autocomplete="email"]').fill(USUARIO_MOCK.email);
    await page
      .locator('input[autocomplete="current-password"]')
      .fill('senha-e2e-123');
  }

  async function submeterLogin(page: import('@playwright/test').Page): Promise<void> {
    await page.locator('form button[type="submit"]').click();
  }

  test('login bem-sucedido mostra shell admin e botao Sair a direita', async ({
    page,
  }) => {
    await page.goto('/auth/login');
    await preencherLogin(page);
    await submeterLogin(page);

    await expect(page).toHaveURL('/');
    await expect(page.getByText(`Olá, ${USUARIO_MOCK.nome}`)).toBeVisible();

    const actions = page.locator('.header-actions');
    await expect(actions).toBeVisible();
    const box = await actions.boundingBox();
    const viewport = page.viewportSize();
    expect(box).not.toBeNull();
    expect(viewport).not.toBeNull();
    // Bloco de acoes deve estar na metade direita da viewport.
    expect(box!.x + box!.width / 2).toBeGreaterThan(viewport!.width * 0.5);
  });

  test('logout volta para login', async ({ page }) => {
    await page.goto('/auth/login');
    await preencherLogin(page);
    await submeterLogin(page);
    await expect(page).toHaveURL('/');

    await page.locator('.header-actions .br-button.secondary').click();
    await expect(page).toHaveURL(/\/auth\/login\?logout=1/);
  });

  const redirectsMaliciosos = [
    { param: '//evil.com', destino: '/' },
    { param: '/\\evil.com', destino: '/' },
    { param: 'http://evil.com', destino: '/' },
    { param: 'evil', destino: '/' },
  ];

  for (const { param, destino } of redirectsMaliciosos) {
    test(`bloqueia redirect malicioso: ${param}`, async ({ page }) => {
      await page.goto(`/auth/login?redirect=${encodeURIComponent(param)}`);
      await preencherLogin(page);
      await submeterLogin(page);
      await expect(page).toHaveURL(destino);
    });
  }

  test('aceita redirect interno valido', async ({ page }) => {
    await page.goto('/auth/login?redirect=%2Fformulario');
    await preencherLogin(page);
    await submeterLogin(page);
    await expect(page).toHaveURL('/formulario');
  });
});