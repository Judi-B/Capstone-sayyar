# 🚐 Sayyar

> A smart student transportation platform connecting students, drivers, and bus providers to streamline daily rides.
<img height="400" alt="image" src="https://github.com/user-attachments/assets/38c7f103-ea10-4ecd-b61b-f48254f01092" />


## Overview

**Sayyar** is a student transportation platform designed to facilitate communication and coordination between **students, drivers, and student transportation companies**.

The platform acts as a central connection point that simplifies daily transportation operations while giving transportation companies greater exposure to their target customers.

Sayyar focuses on automating repetitive transportation tasks and using intelligent route planning to make student transportation more efficient, organized, and convenient.

## The Problem

Managing student transportation on a daily basis involves coordinating multiple parties, routes, schedules, and pickup locations.

For transportation providers, manually organizing students into buses and planning efficient routes can be time-consuming and difficult to scale. Students, on the other hand, need a simple way to access and manage their transportation services.

Sayyar addresses these challenges by bringing all parties together in a single platform and automating key parts of the transportation workflow.

## How Sayyar Works

Sayyar connects three main types of users:

### 🎓 Students

Students use Sayyar as their access point to their daily transportation services.

The platform provides students with an intuitive mobile experience for interacting with their transportation arrangements.

### 🚌 Drivers

Drivers are connected with the students they are responsible for transporting and can use the platform to manage their daily rides and routes.

### 🏢 Bus Providers

Transportation companies use Sayyar to manage their transportation operations and connect with students who need transportation services.

The platform also provides transportation companies with greater exposure to their target customer base.

---

## Intelligent Route Optimization

One of Sayyar's core features is its **geographical clustering and route optimization system**.

Instead of treating every student as an independent pickup location, Sayyar analyzes students' geographical locations and groups students who are located close to one another.

The backend uses **HDBSCAN (Hierarchical Density-Based Spatial Clustering of Applications with Noise)** to identify naturally occurring groups of students based on their geographical proximity.

This allows the system to:

* Group nearby students together.
* Determine efficient bus allocations.
* Reduce unnecessary transportation capacity.
* Help determine the number of buses required.
* Create more efficient routes.
* Match student groups with suitable transportation routes.

### Optimization Flow

```text
Students
    │
    ▼
Geographical Locations
    │
    ▼
HDBSCAN Clustering
    │
    ▼
Groups of Nearby Students
    │
    ▼
Bus Allocation
    │
    ▼
Route Optimization
    │
    ▼
Optimized Daily Rides
```

The clustering algorithm is particularly useful because the number of meaningful groups does not need to be predetermined. Instead, groups are identified based on the geographical distribution of students.

---

## 🗺️ Maps & Routing

Sayyar integrates with **Google Maps APIs** to support its geographical and routing functionality.

Google Maps is used to provide:

* Map visualization
* Student location visualization
* Route generation
* Distance information
* Route optimization

The combination of geographical clustering and routing allows Sayyar to move beyond simple transportation management and provide an intelligent approach to planning daily student rides.

---

## 📱 Mobile Application

The Sayyar mobile application is built using **Flutter and Dart**.

The application was designed around the idea that transportation management is something users interact with **every day**. As a result, the focus was placed on creating an interface that is:

* Simple
* Intuitive
* Easy to navigate
* Fast to use
* Suitable for daily operations

The Flutter application provides the user-facing experience for students, drivers, and bus providers while communicating with the Django backend through APIs.

---

## 🏗️ Technology Stack

| Layer                | Technology            |
| -------------------- | --------------------- |
| Mobile Application   | Flutter               |
| Programming Language | Dart                  |
| Backend              | Django                |
| API                  | Django REST Framework |
| Database             | PostgreSQL            |
| Authentication       | JWT                   |
| Clustering           | HDBSCAN               |
| Maps & Routing       | Google Maps APIs      |

---

## 🧩 System Architecture

```text
                    ┌──────────────────────┐
                    │       SAYYAR         │
                    │  Student Transport   │
                    │       Platform       │
                    └──────────┬───────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
              ▼                ▼                ▼
        ┌───────────┐    ┌───────────┐    ┌───────────┐
        │ Students  │    │  Drivers  │    │    Bus    │
        │           │    │           │    │ Providers │
        └─────┬─────┘    └─────┬─────┘    └─────┬─────┘
              │                │                │
              └────────────────┼────────────────┘
                               │
                               ▼
                     ┌──────────────────┐
                     │     Flutter      │
                     │   Mobile App     │
                     └────────┬─────────┘
                              │
                           REST API
                              │
                              ▼
                     ┌──────────────────┐
                     │      Django      │
                     │     Backend      │
                     └───────┬──────────┘
                             │
                ┌────────────┼────────────┐
                │            │            │
                ▼            ▼            ▼
          PostgreSQL      HDBSCAN     Google Maps
           Database      Clustering      APIs
```

---

## ✨ Key Features

### For Students

* Access to student transportation services.
* Simple and intuitive mobile experience.
* Connection with transportation providers.
* Daily ride management.

### For Drivers

* Access to assigned students and rides.
* Organized daily transportation routes.
* Centralized communication with the transportation system.

### For Bus Providers

* Manage student transportation operations.
* Organize students based on geographical location.
* Optimize bus allocation and routes.
* Reduce unnecessary transportation capacity.
* Reach and connect with their target customers through the platform.

---

## 📸 Screenshots

<!-- Add application screenshots here -->

### Student App

<img  height="400" alt="Screenshot 2025-05-20 232413" src="https://github.com/user-attachments/assets/92dffeb4-8804-4d2b-871b-d90f81457fbf" />


### Driver App


<img height="400" alt="Screenshot 2025-05-20 230410" src="https://github.com/user-attachments/assets/3d8ce2e0-d17b-4392-acf9-8b2f6196ec4b" />


### Route Optimization

<img height="400" alt="Screenshot 2025-05-20 231549" src="https://github.com/user-attachments/assets/fed06e84-fdb4-41c4-9fa4-73992c663d35" />


---

## 🎥 Demo

A demonstration of Sayyar's functionality can be found below:

**Video Demo:**
[Watch the Sayyar Demo](https://youtube.com/shorts/FySQiBvrqac)

---

## 🎯 Project Vision

Sayyar aims to make student transportation **simpler, smarter, and more connected**.

By connecting students, drivers, and transportation providers on one platform and combining an intuitive mobile experience with geographical clustering and route optimization, Sayyar helps transform repetitive transportation planning into a more automated and efficient process.

> **Sayyar — connecting students, drivers, and transportation providers for smarter daily rides.**

---

## 👥 User Types

```text
                    SAYYAR
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ▼              ▼              ▼
    Students        Drivers      Bus Providers
        │              │              │
        └──────────────┼──────────────┘
                       │
                 Daily Rides
                       │
                       ▼
              Optimized Transport
```
