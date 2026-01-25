import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { DashboardComponent } from './pages/dashboard/dashboard.component';
import { UserListComponent } from './pages/users/user-list/user-list.component';
import { JobListComponent } from './pages/jobs/job-list/job-list.component';
import { ProfileListComponent } from './pages/profiles/profile-list/profile-list.component';
import { NotificationSenderComponent } from './pages/notifications/notification-sender/notification-sender.component';
import { LoginComponent } from './pages/auth/login/login.component';
import { authGuard } from './guards/auth.guard';

const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
  { path: 'dashboard', component: DashboardComponent, canActivate: [authGuard] },
  { path: 'users', component: UserListComponent, canActivate: [authGuard] },
  { path: 'jobs', component: JobListComponent, canActivate: [authGuard] },
  { path: 'profiles', component: ProfileListComponent, canActivate: [authGuard] },
  { path: 'notifications', component: NotificationSenderComponent, canActivate: [authGuard] },
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
