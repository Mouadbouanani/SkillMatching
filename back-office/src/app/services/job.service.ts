import { Injectable } from '@angular/core';
import { ApiService } from './api.service';

@Injectable({
    providedIn: 'root'
})
export class JobService {

    constructor(private api: ApiService) { }

    getAllJobs() {
        return this.api.get<any[]>('jobs');
    }

    deleteJob(jobId: string) {
        return this.api.delete(`jobs/${jobId}`);
    }

    updateJobStatus(jobId: string, status: string) {
        // ApiService does not support query params in PUT body argument, need to check ApiService.put signature
        // My ApiService.put(path, body). It doesn't take params as 3rd arg in my implementation.
        // So I must append to URL.
        return this.api.put(`jobs/${jobId}/status?status=${status}`, {});
    }

    getCategories() {
        return this.api.get<any[]>('jobs/categories');
    }
}
