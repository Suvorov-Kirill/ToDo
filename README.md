# ToDo

A simple ToDo application written in Swift.

## Overview

This application is a task manager that allows you to organize and keep track of your tasks efficiently. It features modern architecture and robust data persistence, along with a smooth and responsive user interface.

## Features

### Task List
- Add new tasks.
- Edit existing tasks.
- Delete tasks.
- Search for tasks by text.

### Data Loading
- On the first launch, the app loads the task list from the dummyjson API: [https://dummyjson.com/todos](https://dummyjson.com/todos).

### Multithreading
- All operations for creating, loading, editing, deleting, and searching tasks are handled on background threads using GCD.
- The user interface remains responsive and is never blocked during these operations.

### CoreData Persistence
- All task data is saved using CoreData.

### Unit Tests
- Includes unit tests for core components of the application.

### VIPER Architecture
- The project follows the VIPER architecture.
- Each module is clearly separated into the following components: View, Interactor, Presenter, Entity, Router.

## Author

[Suvorov-Kirill](https://github.com/Suvorov-Kirill)
