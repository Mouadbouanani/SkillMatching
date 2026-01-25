import { Component, OnInit } from '@angular/core';
import { JobService } from '../../../services/job.service';

@Component({
  selector: 'app-job-list',
  template: `
    <div class="fade-in">
      <div class="flex justify-between items-center mb-6">
        <h1>Jobs Overview</h1>
      </div>

      <div class="card table-container">
        <table>
          <thead>
            <tr>
              <th>Title</th>
              <th>Description</th>
              <th>Budget</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr *ngFor="let job of jobs">
              <td>{{ job.title }}</td>
              <td class="text-muted">{{ job.description | slice:0:50 }}...</td>
              <td>{{ job.budget | currency }}</td>
              <td>
                 <span class="badge" [ngClass]="{
                    'badge-success': job.status === 'COMPLETED',
                    'badge-primary': job.status === 'OPEN'
                 }">{{ job.status }}</span>
              </td>
              <td>
                <div class="flex gap-2">
                  <button *ngIf="job.status !== 'COMPLETED' && job.status !== 'CANCELLED'" 
                          class="btn btn-outline" style="padding: 0.25rem 0.5rem;" 
                          title="Mark as Completed" (click)="updateStatus(job, 'COMPLETED')">
                    <i class="fas fa-check"></i>
                  </button>
                  <button class="btn btn-danger" style="padding: 0.25rem 0.5rem;" (click)="deleteJob(job)">
                    <i class="fas fa-trash"></i>
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  `
})
export class JobListComponent implements OnInit {
  jobs: any[] = [];

  constructor(private jobService: JobService) { }

  ngOnInit() {
    this.jobService.getAllJobs().subscribe({
      next: (data) => this.jobs = data,
      error: (e) => console.error(e)
    });
  }

  deleteJob(job: any) {
    if (confirm(`Delete job "${job.title}"?`)) {
      this.jobService.deleteJob(job.id).subscribe(() => {
        this.jobs = this.jobs.filter(j => j.id !== job.id);
        this.loadJobs();
      });
    }
  }

  updateStatus(job: any, status: string) {
    if (confirm(`Mark job "${job.title}" as ${status}?`)) {
      this.jobService.updateJobStatus(job.id, status).subscribe(() => this.loadJobs());
    }
  }

  loadJobs() {
    this.jobService.getAllJobs().subscribe({
      next: (data) => this.jobs = data,
      error: (e) => console.error(e)
    });
  }
}
