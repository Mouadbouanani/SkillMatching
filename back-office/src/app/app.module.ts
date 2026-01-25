import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule } from '@angular/common/http';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { DashboardComponent } from './pages/dashboard/dashboard.component';
import { UserListComponent } from './pages/users/user-list/user-list.component';
import { JobListComponent } from './pages/jobs/job-list/job-list.component';
import { ProfileListComponent } from './pages/profiles/profile-list/profile-list.component';
import { NotificationSenderComponent } from './pages/notifications/notification-sender/notification-sender.component';
import { LoginComponent } from './pages/auth/login/login.component';

@NgModule({
  declarations: [
    AppComponent,
    DashboardComponent,
    UserListComponent,
    JobListComponent,
    ProfileListComponent,
    NotificationSenderComponent,
    LoginComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    HttpClientModule,
    FormsModule,
    ReactiveFormsModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
