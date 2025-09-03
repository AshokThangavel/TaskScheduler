# TaskScheduler
IRIS Task Scheduler

# 🌐 Web-Based Task Scheduler for InterSystems IRIS

A simple, native web-based task scheduler that helps you manage and monitor **InterSystems IRIS** tasks with an intuitive calendar interface.

## 📌 Features

- 📅 **Calendar View** – Visual representation of scheduled tasks (Month/Week/Day views).
- ⚙️ **Manage IRIS Tasks** – Manage IRIS tasks.
- 🔄 **Recurring Jobs** – Support for recurring system tasks like:
  - `Switch Journal`
  - `Enable Async Subtask Polling`
  - `Security Scan`
  - `Feature Tracker`
- 🌐 **Web-Native Interface** – Built using modern web technologies; no need for external clients.

## 🚀 Getting Started

### Prerequisites

- InterSystems IRIS instance
- A web server (e.g., Apache, Nginx or Node.js for hosting frontend)
- Basic understanding of IRIS Task Manager

### Installation

1. Clone the repository:
   ```bash
   git clone https://your-repo-url/task-scheduler-iris.git
2. **Navigate to the project directory**:

   ```bash
   cd irisTest
   ```

2. **Run the docker compose file**:

   ```bash
   docker compose -f docker-compose.yml up -d --build
   ```



## 📸 Screenshot
<img width="1897" height="877" alt="image" src="https://github.com/user-attachments/assets/88469845-15f7-4512-80f4-1574b51f7e07" />


> Example: Visual schedule for September 2025 with recurring task executions.

## 🧩 Tech Stack

* HTML/CSS/JavaScript
* FullCalendar.js (or similar library)
* InterSystems IRIS backend integration (via REST or native APIs)

## 🛠️ Future Enhancements

* ✅ Task creation and editing from UI
* 📊 Task statistics dashboard
* 🔔 Notification/Alert system for failed tasks
* 🔐 Authentication & Role Management

## 📄 License

MIT License. Feel free to modify and use it in your own IRIS projects.

---

> **Note:** This project is a basic-level scheduler. For advanced scheduling, consider integrating with cron-like logic or IRIS advanced task management features.

---
