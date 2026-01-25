import { Component, OnInit } from '@angular/core';
import { JobService } from '../../services/job.service';
import { UserService } from '../../services/user.service';

@Component({
  selector: 'app-dashboard',
  template: `
    <div class="fade-in">
      <div class="flex justify-between items-center mb-6">
        <div>
          <h1>Dashboard</h1>
          <p class="text-muted">Welcome to the SkillMatching Admin Portal</p>
        </div>
        <button class="btn btn-primary" (click)="downloadReport()">
          <i class="fas fa-file-export"></i> Download Report
        </button>
      </div>

      <div class="grid-stats">
        <div class="card stat-card">
          <div class="icon-wrapper">
            <i class="fas fa-users"></i>
          </div>
          <div class="stat-info">
            <h3>{{ userCount }}</h3>
            <p class="text-muted">Total Users</p>
          </div>
        </div>

        <div class="card stat-card">
          <div class="icon-wrapper" style="color: var(--color-success)">
            <i class="fas fa-briefcase"></i>
          </div>
          <div class="stat-info">
            <h3>{{ jobCount }}</h3>
            <p class="text-muted">Active Jobs</p>
          </div>
        </div>

        <div class="card stat-card">
          <div class="icon-wrapper" style="color: #BB86FC">
             <i class="fas fa-check-circle"></i>
          </div>
          <div class="stat-info">
            <h3>{{ completedJobsCount }}</h3>
            <p class="text-muted">Completed Jobs</p>
          </div>
        </div>
      </div>

      <div class="card mt-4">
        <div class="flex justify-between items-center">
            <h2>Recent Activity</h2>
            <button class="btn btn-outline btn-sm" (click)="refreshActivity()">
                <i class="fas fa-sync-alt"></i>
            </button>
        </div>
        <p class="text-muted">Latest events from users and jobs.</p>
        
        <div class="activity-list mt-4">
           <div class="activity-item p-4 border-bottom" *ngFor="let activity of activities">
              <div class="flex items-center gap-3">
                  <div class="activity-icon" [ngClass]="activity.type">
                      <i [class]="activity.icon"></i>
                  </div>
                  <div class="flex-1">
                      <p class="text-sm">
                        <span class="text-primary" style="font-weight: 600;">{{ activity.title }}</span> 
                        {{ activity.description }}
                      </p>
                      <span class="text-muted text-xs">{{ activity.time | date:'medium' }}</span>
                  </div>
              </div>
           </div>
           
           <div *ngIf="activities.length === 0" class="p-6 text-center text-muted">
              No recent activity found.
           </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .grid-stats {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
      gap: 1.5rem;
    }
    .stat-card {
      display: flex;
      align-items: center;
      gap: 1.5rem;
    }
    .icon-wrapper {
      width: 60px;
      height: 60px;
      border-radius: 50%;
      background-color: rgba(255,255,255,0.05);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.5rem;
      color: var(--color-primary);
    }
    .border-bottom {
        border-bottom: 1px solid var(--color-border);
    }
    .activity-item:last-child {
        border-bottom: none;
    }
    .activity-icon {
        width: 35px; height: 35px; border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        font-size: 0.9rem;
    }
    .activity-icon.user { background: rgba(212, 175, 55, 0.15); color: var(--color-primary); }
    .activity-icon.job { background: rgba(3, 218, 198, 0.15); color: var(--color-success); }
    .btn-sm { padding: 0.25rem 0.5rem; font-size: 0.8rem; }
  `]
})
export class DashboardComponent implements OnInit {
  userCount = 0;
  jobCount = 0;
  completedJobsCount = 0;
  activities: any[] = [];

  private users: any[] = [];
  private jobs: any[] = [];

  constructor(private userService: UserService, private jobService: JobService) { }

  ngOnInit() {
    this.refreshData();
  }

  refreshData() {
    this.userService.getAllUsers().subscribe({
      next: (users) => {
        this.users = users;
        this.userCount = users.length;
        this.generateActivities();
      }
    });

    this.jobService.getAllJobs().subscribe({
      next: (jobs) => {
        this.jobs = jobs;
        this.jobCount = jobs.length;
        this.completedJobsCount = jobs.filter(j => j.status === 'COMPLETED').length;
        this.generateActivities();
      }
    });
  }

  refreshActivity() {
    this.refreshData();
  }

  generateActivities() {
    const activeArr: any[] = [];

    // New Users
    const recentUsers = [...this.users].sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()).slice(0, 3);
    recentUsers.forEach(u => {
      activeArr.push({
        type: 'user',
        icon: 'fas fa-user-plus',
        title: 'New Member',
        description: `registered: ${u.displayName || u.email}`,
        time: u.createdAt
      });
    });

    // New Jobs
    const recentJobs = [...this.jobs].sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()).slice(0, 3);
    recentJobs.forEach(j => {
      activeArr.push({
        type: 'job',
        icon: 'fas fa-briefcase',
        title: 'New Job Posted',
        description: ` "${j.title}" by ${this.getUserName(j.requesterId)}`,
        time: j.createdAt
      });
    });

    this.activities = activeArr.sort((a, b) => new Date(b.time).getTime() - new Date(a.time).getTime()).slice(0, 5);
  }

  getUserName(uid: string) {
    const user = this.users.find(u => u.firebaseUid === uid);
    return user ? (user.displayName || user.email) : 'Unknown User';
  }

  downloadReport() {
    const data = this.jobs.map(j => ({
      ID: j.id,
      Title: j.title,
      Budget: j.budget,
      Status: j.status,
      Requester: this.getUserName(j.requesterId),
      Date: new Date(j.createdAt).toLocaleDateString()
    }));

    if (data.length === 0) {
      alert("No data available to download.");
      return;
    }

    const csvContent = this.convertToCSV(data);
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8' });
    const url = window.URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.setAttribute('href', url);
    link.setAttribute('download', `SkillMatch_Report_${new Date().toISOString().split('T')[0]}.csv`);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }

  private convertToCSV(objArray: any[]) {
    const array = typeof objArray != 'object' ? JSON.parse(objArray) : objArray;
    let str = '';
    const header = Object.keys(array[0]).join(',');
    str += header + '\r\n';

    for (let i = 0; i < array.length; i++) {
      let line = '';
      for (const index in array[i]) {
        if (line != '') line += ',';
        line += array[i][index];
      }
      str += line + '\r\n';
    }
    return str;
  }
}
