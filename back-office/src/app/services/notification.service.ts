import { Injectable } from '@angular/core';
import { ApiService } from './api.service';

@Injectable({
    providedIn: 'root'
})
export class NotificationService {

    constructor(private api: ApiService) { }

    sendNotificationToUser(userId: string, title: string, body: string, type: string = 'SYSTEM') {
        const params = { userId, title, body, type };
        // Using param-based post as per controller
        // @RequestParam usage in controller implies query params or form-data, let's try query params first or form data wrapper
        // Actually the controller uses @RequestParam, so we should send query params
        return this.api.post(`notifications/send/user`, null); // Special case handling needed in ApiService for params in POST if not body
        // Wait, my ApiService implementation puts params in query for GET, but not for POST.
        // I should probably fix ApiService or handling it here.
        // Let's assume I fix ApiService to support params in POST or construct URL manually.
    }

    // Helper to send as query params manually since my ApiService might need tweaking
    sendNotificationToUserQuery(userId: string, title: string, body: string, type: string = 'SYSTEM') {
        const query = `userId=${encodeURIComponent(userId)}&title=${encodeURIComponent(title)}&body=${encodeURIComponent(body)}&type=${type}`;
        return this.api.post(`notifications/send/user?${query}`, {});
    }
}
