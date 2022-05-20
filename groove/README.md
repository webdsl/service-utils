<img style="margin: 0 auto;" src="./images/logo.png" />

A simple Habit Tracker.

## Feature Overview

- General
  - New users can sign up and verify their email.
  - Users can request a password reset token per email.
  - Users can change their name, email, password and notification preferences.
- Habits
  - Users can create new habits and complete their own habits.
  - Users see a few statistics about their streaks and completion rates.
  - Users can delete and modify their own habits.
- Management
  - Administrators have an overview of all users and can delete and upgrade users.
  - Administrators can send newsletter emails.

## Development

### Setup

To run, WebDSL itself is sufficient.
To develop, you will need to install at least Node to build the css files (don't forget to `npm install`).

### Running the development server

I have WebDSL installed on Windows, a weird issue where I manually need to kill of an orphaned tomcat server.

The dev process needs the following steps:

1. check if we need to kill of tomcat
2. calculate the new styles
3. run `webdsl run`

The Powershell script `restart.ps1` does all of the above, but your mileage may vary. When in doubt look at what the script is doing. And be prepared to wait for WebDSL.
Since WebDSL tries to be smart and aggressive with the cache, css changes sometimes are only loaded with `restart.ps1 -clean`.
