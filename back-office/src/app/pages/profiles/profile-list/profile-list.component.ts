import { Component, OnInit } from '@angular/core';
import { ProfileService } from '../../../services/profile.service';

@Component({
  selector: 'app-profile-list',
  template: `
    <div class="fade-in">
      <div class="flex justify-between items-center mb-6">
        <h1>Profile Registry</h1>
        <button class="btn btn-primary" (click)="loadProfiles()">
            <i class="fas fa-sync-alt"></i> Refresh
        </button>
      </div>

      <div class="card table-container">
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Bio</th>
              <th>Hourly Rate</th>
              <th>Skills</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr *ngFor="let profile of profiles">
              <td>
                 <div class="flex items-center gap-2">
                    <img [src]="profile.profilePictureUrl || 'assets/default-avatar.svg'" style="width: 40px; height: 40px; border-radius: 50%; object-fit: cover;" />
                    <div style="font-weight: 500;">
                        {{ profile.name || 'Unknown' }}
                    </div>
                 </div>
              </td>
              <td class="text-muted">{{ profile.bio ? (profile.bio | slice:0:30) + '...' : 'No bio provided' }}</td>
              <td>{{ profile.hourlyRate ? (profile.hourlyRate | currency) : 'N/A' }}</td>
              <td>
                 <!-- Check properties of skill based on backend response, usually skillName or name -->
                 <ng-container *ngIf="profile.skills && profile.skills.length > 0; else noSkills">
                    <span *ngFor="let skill of profile.skills.slice(0, 3)" class="badge badge-primary" style="margin-right: 4px;">
                        {{ skill.name || skill.skillName || skill }}
                    </span>
                    <span *ngIf="profile.skills.length > 3" class="text-xs text-muted">+{{profile.skills.length - 3}}</span>
                 </ng-container>
                 <ng-template #noSkills>
                    <span class="text-xs text-muted">No skills listed</span>
                 </ng-template>
              </td>
              <td>
                <button class="btn btn-danger btn-sm" title="Delete Profile" (click)="deleteProfile(profile)">
                    <i class="fas fa-trash-alt"></i>
                </button>
              </td>
            </tr>
          </tbody>
        </table>
        
        <div *ngIf="profiles.length === 0" class="p-6 text-center text-muted">
           <i class="fas fa-id-card fa-3x mb-3"></i>
           <p>No profiles found.</p>
        </div>
      </div>
    </div>
  `
})
export class ProfileListComponent implements OnInit {
  profiles: any[] = [];

  constructor(private profileService: ProfileService) { }

  ngOnInit() {
    this.loadProfiles();
  }

  loadProfiles() {
    this.profileService.getAllProfiles().subscribe({
      next: (data) => this.profiles = data,
      error: (e) => console.error(e)
    });
  }

  deleteProfile(profile: any) {
    if (confirm(`Delete profile of ${profile.name}?`)) {
      this.profileService.deleteProfile(profile.id).subscribe(() => {
        this.profiles = this.profiles.filter(p => p.id !== profile.id);
      });
    }
  }
}
