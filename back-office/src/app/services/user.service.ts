import { Injectable } from '@angular/core';
import { ApiService } from './api.service';

@Injectable({
    providedIn: 'root'
})
export class UserService {

    constructor(private api: ApiService) { }

    getAllUsers() {
        return this.api.get<any[]>('users/admin/users');
    }

    updateRole(firebaseUid: string, newRole: string) {
        return this.api.put(`users/admin/users/${firebaseUid}/role`, { newRole });
    }

    deleteUser(firebaseUid: string) {
        return this.api.delete(`users/admin/users/${firebaseUid}`);
    }
}
