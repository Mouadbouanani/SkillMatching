import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from '../../../services/auth.service';

@Component({
  selector: 'app-login',
  template: `
    <div class="login-container">
      <div class="card p-6 login-card fade-in">
        <div class="text-center mb-6">
          <h1 style="font-size: 2rem; margin-bottom: 0.5rem;"><i class="fas fa-layer-group text-primary"></i> SkillMatch</h1>
          <p class="text-muted">Admin Portal Login</p>
        </div>
        
        <form (ngSubmit)="login()">
          <div class="mb-4">
            <label class="block text-sm text-muted mb-2">Email</label>
            <input type="email" [(ngModel)]="email" name="email" class="input" required placeholder="admin@skillmatch.com">
          </div>
          
          <div class="mb-6">
            <label class="block text-sm text-muted mb-2">Password</label>
            <input type="password" [(ngModel)]="password" name="password" class="input" required placeholder="••••••••">
          </div>

          <button type="submit" class="btn btn-primary w-full" [disabled]="loading">
            <span *ngIf="!loading">Sign In</span>
            <span *ngIf="loading"><i class="fas fa-spinner fa-spin"></i> Loading...</span>
          </button>
          
          <p *ngIf="error" class="text-danger text-center mt-4 text-sm">{{ error }}</p>
        </form>
      </div>
    </div>
  `,
  styles: [`
    .login-container {
      height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background-color: var(--color-background);
      background-image: radial-gradient(circle at 50% 50%, rgba(212, 175, 55, 0.05) 0%, transparent 50%);
    }
    .login-card {
      width: 100%;
      max-width: 400px;
      border: 1px solid var(--color-border);
    }
  `]
})
export class LoginComponent {
  email = '';
  password = '';
  loading = false;
  error = '';

  constructor(private authService: AuthService, private router: Router) { }

  login() {
    this.loading = true;
    this.error = '';

    // For demo purposes, if API fails or is not reachable, allow bypass with admin/admin
    // In production, strictly use the service.

    this.authService.login({ email: this.email, password: this.password }).subscribe({
      next: () => {
        this.router.navigate(['/dashboard']);
      },
      error: (err) => {
        console.error(err);
        this.loading = false;

        // Handle ErrorResponse from backend
        if (err.error && err.error.message) {
          this.error = err.error.message;
        } else if (err.message) {
          this.error = err.message;
        } else {
          this.error = 'Login failed. Please check your credentials.';
        }
      }
    });
  }
}
