import { CanActivateFn, Router } from '@angular/router';
import { inject } from '@angular/core';
import { AuthService } from '../services/auth.service';

export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isAuthenticated()) {
    const user = authService.getCurrentUser();
    if (user && user.role === 'ADMIN') {
      return true;
    }
    // Authenticated but not admin
    alert('Access Denied: Admins Only');
    authService.logout();
    return false;
  }

  router.navigate(['/login']);
  return false;
};
