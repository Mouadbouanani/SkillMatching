import { Injectable } from '@angular/core';
import { ApiService } from './api.service';

@Injectable({
    providedIn: 'root'
})
export class ProfileService {

    constructor(private api: ApiService) { }

    getAllProfiles() {
        return this.api.get<any[]>('profiles/all');
    }

    deleteProfile(profileId: string) {
        return this.api.delete(`profiles/${profileId}`);
    }
}
