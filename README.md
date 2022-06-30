# Centrality README

## Table of Contents
1. [Overview](#Overview)
1. [Product Specifications](#Product-Specifications)
1. [Wireframes](#Wireframes)
2. [Schema](#[In-Progress]-Schema)

## Overview
### Description
Centrality is an all-in one productivity suite that accomodates for different user workflows and functions. The app is targeted towards students, working professionals, and anybody else looking for a better way to organize their lives. These days, most people use multiple apps to meet all their organizational needs, but Centrality includes functionality for multiple productivity tools (to-do lists, time-blockers, Pomodoro timers, calendars, and notes) in one place, making it a multi-use app that aims to meet users productivity needs.

### App Evaluation
- **Category:** Productivity
- **Mobile:** Mobile is not essential as this program could easily be implemented as a desktop app. However, having a productivity suite available on a mobile device adds convenience to the user's experience since they do not need to be in front of a computer to look over their schedule and plan for the day.
- **Story:** Allows users to stay within one app for different organizational needs rather than requiring them to experiment with several apps and attempt to integrate them together.
- **Market:** Students and  working professionals can utilize this app to stay on top of their fast-paced schedules and gauge balance with their personal lives.
- **Habit:** Students and workers need to use this daily to organize their daily routines and plan for upcoming events, assignments, projects, and deadlines.
- **Scope:** V1 would allow basic C.R.U.D functionality in the to-do list. V2 would involve categories, labels/tags, priority rankings, and descriptions associated with each task on the todo-list. V3 would work integrate data passed between to-do list, focus timer, calendar, and time-blocker. V4 would add conveient features such as dark-mode and detailed filtering options. V5 would allow integration with other apps like Google Calendar, Outlook, Facebook, etc.

## Product Specifications

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* Allow users to create an account
* Allow users to create, read, update, and delete tasks
* Allow users to add due date and reminders to tasks
* Allow user to add tags/categories to tasks
* Allow users to filter view by tags, due date, or priority, 
* Table view for viewing tasks
* Kanban view for viewing tasks
* Push Notifications

**Optional Nice-to-have Stories**
* Allow user to save task info to an account, not just locally
* Allow users to describe tasks
* Allow users to rank priority of tasks
* Grid view for viewing tasks
* Pomodoro Timer
* Focus Board
* Calendar view for viewing tasks
* Dark mode toggle
* Time-Blocker
* Notes Manager
* Sync w/ GCal & Outlook
* Collaborative feature : allow users to share tasks with eachother
* Allow users to add subtasks to a task
* Allow users to add custom metrics (task difficulty, task duration)

### 2. Screen Archetypes

* Login and Signup Screen
   * Allow users to create and manage an account
* Stream Archetype - To-Do List Feed
    * Table view for viewing tasks
    * Kanban view for viewing tasks
* Creation & Detail Archetype - Task Modification Modal
    * Allow users to create, read, update, and delete tasks
    * Allow users to add due date and reminders to tasks
    * Allow user to add tags/categories to tasks
* Profile Archetype
    * Allow users to create and manage an account
* Settings Archetype - View Settings
    * Allow users to filter view by tags, due date, or priority, 

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Task Manager / To-Do List
* Focus Timer
* Calendar Screen
* Time-Blocker
* Profile & Settings Screen

**Flow Navigation** (Screen to Screen)

* Login Screen
    * => Registration Screen
    * => Task Manager / To-Do List
* Registration Screen
    * => Login Screen
    * => Task Manager / To-Do List
* Task Manager / To-Do List
    * => Search for task
    * => Modify task filter, group, and view settings
* Focus Timer
    * => [MODAL] Modify timer settings
    * => [MODAL] Add task to focus queue
* Calendar Screen
    * => View tasks details of selected day
* Time-Blocker
    * => [MODAL] Add task to a time-block and set it's duration
* Profile & Settings Screen
    * Update account info (avatar, username, password, email, etc.)
    * => Modify app settings (Dark Mode, Push Notifications, Language)
    * View usage stats (tasks completed, percentages, etc.)

## Wireframes
### Low-Fidelity Wireframe and Navigation Flow
<img src="Lofi Prototype.png" width=600>

### [In-Progress] Digital Wireframes & Mockups

### [In-Progress] Interactive Prototype

## [In-Progress] Schema 
### Models
#### Task

   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | objectId      | Number   | unique id for the current task (default field) |
   | dateCreated   | DateTime | date when user created task |
   | dueDate       | DateTime | due date for task set by user |
   | taskTitle     | String   | title for the task |
   | taskDesc      | String   | description for the task |
   | taskPriority  | Number | priority-level of the task |
   | reminders     | DateTime Array | list of timed reminders set by user |
   | categories    | String | category that task belongs to |

### [In-Progress] Networking
- [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]
