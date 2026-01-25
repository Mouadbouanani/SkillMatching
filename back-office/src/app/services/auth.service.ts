import { Injectable } from '@angular/core';
import { ApiService } from './api.service';
import { BehaviorSubject, tap } from 'rxjs';
import { Router } from '@angular/router';

@Injectable({
    providedIn: 'root'
})
export class AuthService {
    private userSubject = new BehaviorSubject<any>(null);
    public user$ = this.userSubject.asObservable();

    constructor(private api: ApiService, private router: Router) {
        const user = localStorage.getItem('user');
        if (user) {
            this.userSubject.next(JSON.parse(user));
        }
    }

    // NOTE: Adjust login payload based on actual AuthController
    login(credentials: any) {
        return this.api.post<any>('users/login', credentials).pipe(
            tap((response: any) => {
                if (response && response.idToken) {
                    if (response.user.role !== 'ADMIN') {
                        throw new Error('Access Denied: Admin privileges required.');
                    }
                    localStorage.setItem('token', response.idToken);
                    localStorage.setItem('user', JSON.stringify(response.user));
                    this.userSubject.next(response.user);
                }
            })
        );
    }

    logout() {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        this.userSubject.next(null);
        this.router.navigate(['/login']);
    }

    isAuthenticated(): boolean {
        return !!localStorage.getItem('token');
    }

    getCurrentUser() {
        return this.userSubject.value;
    }
}
