import { Component, OnInit } from '@angular/core';
import { UserService } from '../../../services/user.service';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common'; // Import CommonModule

@Component({
  selector: 'app-user-list',
  template: `
    <div class="fade-in">
      <div class="flex justify-between items-center mb-6">
        <h1>User Management</h1>
        <div class="flex gap-2">
           <button class="btn btn-primary" (click)="loadUsers()">
             <i class="fas fa-sync-alt"></i> Refresh
           </button>
        </div>
      </div>

      <div class="card table-container">
        <table>
          <thead>
            <tr>
              <th>User</th>
              <th>Role</th>
              <th>Status</th>
              <th>Contact</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr *ngFor="let user of users">
              <td>
                <div class="flex items-center gap-3">
                    <img [src]="user.profilePictureUrl || 'assets/default-avatar.svg'" class="avatar">
                    <div>
                        <div style="font-weight: 600;">{{ user.displayName || 'No Name' }}</div>
                        <div class="text-sm text-muted">{{ user.email }}</div>
                        <div class="text-xs text-muted">UID: {{ user.firebaseUid | slice:0:6 }}...</div>
                    </div>
                </div>
              </td>
              <td>
                <span class="badge" [ngClass]="{
                    'badge-primary': user.role === 'PROVIDER', 
                    'badge-success': user.role === 'CLIENT' || user.role === 'USER',
                    'badge-admin': user.role === 'ADMIN'
                }">
                  {{ user.role }}
                </span>
              </td>
              <td>
                  <span class="badge" [class.badge-success]="user.emailVerified" [class.badge-danger]="!user.emailVerified">
                    {{ user.emailVerified ? 'Verified' : 'Unverified' }}
                  </span>
              </td>
              <td class="text-sm">
                 <div *ngIf="user.phoneNumber"><i class="fas fa-phone text-muted"></i> {{ user.phoneNumber }}</div>
                 <div><i class="fas fa-calendar text-muted"></i> {{ user.createdAt | date:'shortDate' }}</div>
              </td>
              <td>
                <div class="flex gap-2">
                  <button class="btn btn-outline btn-sm" title="Edit Role" (click)="openEditModal(user)">
                    <i class="fas fa-edit"></i>
                  </button>
                  <button class="btn btn-danger btn-sm" title="Delete User" (click)="deleteUser(user)">
                    <i class="fas fa-trash-alt"></i>
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
        
        <div *ngIf="users.length === 0" class="p-6 text-center text-muted">
           <i class="fas fa-users fa-3x mb-3"></i>
           <p>No users found or error loading data.</p>
        </div>
      </div>

      <!-- Edit Role Modal -->
      <div class="modal-backdrop" *ngIf="showModal" (click)="closeModal()">
        <div class="modal-content" (click)="$event.stopPropagation()">
            <h2>Edit Role</h2>
            <p class="text-muted mb-4">Change role for {{ selectedUser?.email }}</p>
            
            <div class="mb-4">
                <label class="block mb-2 text-sm">Select Role</label>
                <select [(ngModel)]="selectedRole" class="select">
                    <option value="CLIENT">CLIENT</option>
                    <option value="PROVIDER">PROVIDER</option>
                    <option value="ADMIN">ADMIN</option>
                </select>
            </div>

            <div *ngIf="errorMessage" class="text-danger mb-4 text-sm">{{ errorMessage }}</div>

            <div class="flex justify-end gap-2">
                <button class="btn btn-outline" (click)="closeModal()">Cancel</button>
                <button class="btn btn-primary" (click)="saveRole()" [disabled]="loading">
                    <span *ngIf="loading"><i class="fas fa-spinner fa-spin"></i> Saving...</span>
                    <span *ngIf="!loading">Save Changes</span>
                </button>
            </div>
        </div>
      </div>

    </div>
  `,
  styles: [`
    .avatar {
        width: 40px; height: 40px; border-radius: 50%; object-fit: cover; background: #333;
    }
    .badge-admin {
        background-color: rgba(207, 102, 121, 0.15);
        color: var(--color-danger);
        border: 1px solid rgba(207, 102, 121, 0.3);
    }
    .badge-danger {
        color: var(--color-danger);
    }
    .btn-sm { padding: 0.25rem 0.5rem; font-size: 0.8rem; }

    /* Modal Styles */
    .modal-backdrop {
        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(0,0,0,0.7);
        z-index: 1000;
        display: flex; justify-content: center; align-items: center;
        animation: fadeIn 0.2s;
    }
    .modal-content {
        background: var(--color-surface);
        padding: 2rem;
        border-radius: var(--radius-lg);
        width: 90%; max-width: 400px;
        border: 1px solid var(--color-border);
        box-shadow: var(--shadow-lg);
    }
  `]
})
export class UserListComponent implements OnInit {
  users: any[] = [];

  // Modal State
  showModal = false;
  selectedUser: any = null;
  selectedRole = 'CLIENT';
  loading = false;
  errorMessage = '';

  constructor(private userService: UserService) { }

  ngOnInit() {
    this.loadUsers();
  }

  loadUsers() {
    this.userService.getAllUsers().subscribe({
      next: (data) => this.users = data,
      error: (e) => console.error(e)
    });
  }

  openEditModal(user: any) {
    this.selectedUser = user;
    this.selectedRole = user.role;
    this.showModal = true;
    this.errorMessage = '';
  }

  closeModal() {
    this.showModal = false;
    this.selectedUser = null;
  }

  saveRole() {
    if (!this.selectedUser) return;

    this.loading = true;
    this.errorMessage = '';

    this.userService.updateRole(this.selectedUser.firebaseUid, this.selectedRole).subscribe({
      next: () => {
        this.loading = false;
        this.closeModal();
        this.loadUsers();
      },
      error: (err) => {
        this.loading = false;
        console.error(err);
        // Handle backend error message nicely
        if (err.error && err.error.message) {
          this.errorMessage = err.error.message;
        } else {
          this.errorMessage = "Failed to update role. " + (err.statusText || '');
        }
      }
    });
  }

  deleteUser(user: any) {
    if (confirm(`Are you sure you want to delete ${user.email}?\nThis action cannot be undone.`)) {
      this.userService.deleteUser(user.firebaseUid).subscribe(() => this.loadUsers());
    }
  }
}
