import { expect, test } from '@playwright/test';
import {
  limparSessao,
  mockAuthApiAnonimo,
  mockAuthApiAutenticado,
  seedSessaoAutenticada,
} from './fixtures/auth-api';

test.describe('Marca e footer Augustus', () => {
  test('login exibe marca Augustus no AuthLayout', async ({ page }) => {
    await limparSessao(page);
    await mockAuthApiAnonimo(page);
    await page.goto('/auth/login');
    await expect(page.locator('.auth-layout__brand img')).toHaveAttribute(
      'src',
      /augustus-symbol\.svg/,
    );
    await expect(page.locator('.auth-layout__brand-title')).toHaveText('Augustus');
  });

  test('area autenticada exibe footer custom sem placeholders', async ({
    page,
  }) => {
    await limparSessao(page);
    await mockAuthApiAutenticado(page);
    await seedSessaoAutenticada(page);
    await page.goto('/');

    const footer = page.locator('.augustus-footer');
    await expect(footer).toBeVisible();
    await expect(footer).toContainText('Augustus');
    await expect(footer).toContainText('Controlador de finanças pessoais');
    await expect(footer.getByText(/lorem ipsum/i)).toHaveCount(0);
    await expect(page.locator('br-footer')).toHaveCount(0);
  });
});