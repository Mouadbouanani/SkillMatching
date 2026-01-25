import { Component } from '@angular/core';
import { NotificationService } from '../../../services/notification.service';
import { UserService } from '../../../services/user.service';

@Component({
    selector: 'app-notification-sender',
    template: `
    <div class="fade-in">
      <h1>Send Notification</h1>
      <p class="text-muted mb-6">Send manual push notifications to users.</p>

      <div class="card p-6" style="max-width: 600px;">
        <div class="flex flex-col gap-4">
          <div>
            <label class="text-sm text-muted mb-2 block">Target User UID (Optional)</label>
            <input type="text" [(ngModel)]="targetUid" class="input" placeholder="Enter Firebase UID (Leave empty to broadcast - TODO)">
          </div>

          <div>
             <label class="text-sm text-muted mb-2 block">Title</label>
             <input type="text" [(ngModel)]="title" class="input" placeholder="Notification Title">
          </div>

          <div>
             <label class="text-sm text-muted mb-2 block">Body/Message</label>
             <textarea [(ngModel)]="body" class="textarea" rows="4" placeholder="Enter message body here..."></textarea>
          </div>

          <button class="btn btn-primary" (click)="send()">
             <i class="fas fa-paper-plane"></i> Send Notification
          </button>

          <div *ngIf="message" class="p-4 mt-4" [ngClass]="{'text-success': success, 'text-danger': !success}" style="background: rgba(255,255,255,0.05); border-radius: 4px;">
             {{ message }}
          </div>
        </div>
      </div>
    </div>
  `
})
export class NotificationSenderComponent {
    targetUid: string = '';
    title: string = '';
    body: string = '';
    message: string = '';
    success: boolean = false;

    constructor(private notifService: NotificationService) { }

    send() {
        if (!this.targetUid || !this.title || !this.body) {
            this.message = "Please fill all fields.";
            this.success = false;
            return;
        }

        this.notifService.sendNotificationToUserQuery(this.targetUid, this.title, this.body).subscribe({
            next: () => {
                this.message = "Notification Sent Successfully!";
                this.success = true;
                this.title = '';
                this.body = '';
            },
            error: (err) => {
                this.message = "Error sending notification: " + (err.error?.message || err.message);
                this.success = false;
            }
        });
    }
}
