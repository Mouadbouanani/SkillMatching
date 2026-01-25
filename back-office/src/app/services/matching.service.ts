import { Injectable } from '@angular/core';
import { ApiService } from './api.service';

@Injectable({
    providedIn: 'root'
})
export class MatchingService {

    constructor(private api: ApiService) { }

    triggerMatching(jobId: string) {
        return this.api.post(`matches/trigger/${jobId}`, {});
    }

    getMatchSuggestions(jobId: string) {
        return this.api.get<any[]>(`matches/suggestions/${jobId}`);
    }
}
