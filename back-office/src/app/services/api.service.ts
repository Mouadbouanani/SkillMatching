import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';

@Injectable({
    providedIn: 'root'
})
export class ApiService {
    private baseUrl = 'http://localhost:8080/api';

    constructor(private http: HttpClient) { }

    private getHeaders(): HttpHeaders {
        const token = localStorage.getItem('token');
        let headers = new HttpHeaders({
            'Content-Type': 'application/json'
        });
        if (token) {
            headers = headers.set('Authorization', `Bearer ${token}`);
        }
        return headers;
    }

    get<T>(path: string, params?: any): Observable<T> {
        let httpParams = new HttpParams();
        if (params) {
            Object.keys(params).forEach(key => {
                if (params[key] !== null && params[key] !== undefined) {
                    httpParams = httpParams.set(key, params[key]);
                }
            });
        }

        return this.http.get<T>(`${this.baseUrl}/${path}`, { headers: this.getHeaders(), params: httpParams })
            .pipe(catchError(this.handleError));
    }

    post<T>(path: string, body: any): Observable<T> {
        return this.http.post<T>(`${this.baseUrl}/${path}`, body, { headers: this.getHeaders() })
            .pipe(catchError(this.handleError));
    }

    put<T>(path: string, body: any): Observable<T> {
        return this.http.put<T>(`${this.baseUrl}/${path}`, body, { headers: this.getHeaders() })
            .pipe(catchError(this.handleError));
    }

    delete<T>(path: string): Observable<T> {
        return this.http.delete<T>(`${this.baseUrl}/${path}`, { headers: this.getHeaders() })
            .pipe(catchError(this.handleError));
    }

    private handleError(error: any) {
        console.error('API Error:', error);
        return throwError(() => error);
    }
}
