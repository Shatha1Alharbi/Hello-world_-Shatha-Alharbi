# Learning Streak Tracker

**An iOS application for building consistent learning habits through goal-based progress tracking, flexible daily logging, and time-aware streak management.**

## Overview

Learning Streak Tracker helps users establish and maintain learning routines by turning long-term learning goals into measurable daily commitments.

The application allows users to define a learning goal, track daily progress, and record rest days through a controlled Freeze mechanism. Its core logic is designed to balance consistency with flexibility, particularly when users forget to record their activity before midnight.

Built with **Swift and SwiftUI**, the application uses observable state, calendar-based date calculations, and centralized validation rules to keep the interface synchronized with the underlying learning records.

## Key Features

| Feature | Description |
|---|---|
| Goal Management | Create and edit learning goals with weekly, monthly, or yearly durations. |
| Daily Logging | Record a day as Learned or Frozen. |
| Flexible Status Updates | Switch between Learned and Freeze within the permitted logging window. |
| 32-Hour Grace Period | Record or modify the previous day's activity until 8:00 AM the following day. |
| Interactive Calendar | View color-coded daily records and select eligible dates. |
| Freeze Allowance | Enforce a maximum number of Freeze days according to the selected goal duration. |
| Progress Statistics | Display accumulated Learned and Freeze days for the current goal. |
| Goal Evaluation | Determine whether a goal is Active, Completed, or Failed. |
| Automatic Date Synchronization | Update the interface when the date changes or the application becomes active. |

## Technical Design

### Architecture and Separation of Responsibilities

The application separates presentation logic from learning-related business rules.

**SwiftUI Views** are responsible for rendering the interface, displaying learning statistics, handling user interactions, and responding to observable state changes.

**LearningViewModel** centralizes the application's business logic, including goal management, daily records, date validation, Freeze eligibility, streak calculations, and goal-state evaluation.

**Data Models** represent the core domain entities:

- `LearningGoal` — Stores the goal name, duration, and start date.
- `DailyRecord` — Represents an activity record associated with a date and status.
- `DayStatus` — Defines the two supported states: `learned` and `frozen`.
- `GoalDuration` — Defines the supported goal durations: week, month, and year.
- `GoalState` — Represents the goal's lifecycle state.

The ViewModel uses Swift's `@Observable` macro to expose state changes to SwiftUI. This enables the interface to reflect updates to records, statistics, and goal information without manually synchronizing individual UI elements.

### State Management

The Activity screen maintains two distinct date values:

- `currentTime` represents the current device time and is used to evaluate time-sensitive interface behavior.
- `selectedDate` represents the date the user is currently interacting with.

Separating these values allows users to review or modify an eligible previous day without changing the application's understanding of the current date.

When a user selects a date, the header reflects that selection, and logging actions target the selected date rather than always targeting today.

The application also detects day transitions and restores the current date as the default selection when appropriate.

## Core Business Logic

### 1. Daily Record Management

Each calendar day can have one active record status:

- **Learned:** The user completed their learning activity.
- **Frozen:** The user used an available Freeze day.

The application prevents duplicate daily records by checking whether a record already exists for the selected calendar day.

When users change a day's status, the existing record is updated rather than creating a second entry.

For example:

`Learned → Frozen → Learned`

The calendar representation and associated statistics are recalculated based on the latest status.

This approach preserves a single effective status per day and prevents duplicate counting.

### 2. The 32-Hour Grace Period

A central feature of the application is its time-based logging policy.

Rather than closing a day's logging window at midnight, the application extends the deadline until **8:00 AM on the following day**.

This provides a 32-hour window measured from the beginning of the calendar day.

**Example: November 1, 2026**

| Date and time | Expected behavior |
|---|---|
| November 1, 12:00 AM | Logging window opens. |
| November 1, 11:59 PM | Logging and status changes remain available. |
| November 2, 12:00 AM | The previous day remains eligible for logging. |
| November 2, 7:59 AM | Users can still modify November 1. |
| November 2, 8:00 AM | The grace period reaches its deadline. |
| November 2, 8:01 AM | November 1 is no longer editable. |

The ViewModel evaluates date eligibility through `canEdit(_:now:)`.

This validation considers the goal's active state, its start and end dates, whether the selected date is in the future, and whether the permitted logging window remains open.

The interface uses the result to disable ineligible calendar selections.

**Design rationale:** The grace period accommodates users who complete their learning activities but forget to record them before midnight, while maintaining a defined deadline for historical changes.

### 3. Previous-Day Selection and Editing

During the grace period, users can select the previous day from the displayed weekly calendar, provided that date is visible and eligible.

Once selected:

1. The activity header displays the selected date.
2. The Learned and Freeze buttons reflect that day's existing status.
3. The user can submit or change the record if validation permits.
4. The calendar and progress statistics reflect the updated record.

After a successful logging action, the Activity screen restores the current date as the selected date.

Once the grace period expires, the record remains part of the calendar history but is no longer eligible for modification.

### 4. Freeze Allowance and Validation

Freeze usage is controlled by the duration of the current learning goal.

| Goal duration | Maximum Freeze days |
|---|---:|
| Weekly goal | 2 |
| Monthly goal | 8 |
| Yearly goal | 96 |

The `freezeLimit` property determines the applicable allowance, while `freezesUsed` counts Frozen records belonging to the current goal.

Before accepting a Freeze action, `canFreeze(on:)` verifies that:

- The selected date is eligible for editing.
- The date is not already marked as Frozen.
- The current goal has remaining Freeze allowance.

If any condition fails, the operation is rejected.

Changing a Frozen record back to Learned updates the effective record and reduces the number of Freeze days counted against the goal's allowance.

This keeps Freeze eligibility consistent with the current set of records.

### 5. Goal Lifecycle and Completion Rules

A learning goal progresses through three possible states:

**Active** — The goal is ongoing, and its completion requirements are still being evaluated.

**Completed** — The goal duration has ended, and all required days have a valid Learned or Frozen record.

**Failed** — A required day remains unrecorded after its permitted deadline, making the goal incomplete.

The ViewModel evaluates goal status using `goalState(at:)`.

An important part of this logic is the treatment of the final day.

If the goal duration has ended but the final day's grace period is still open, the application allows the user to complete the missing record before determining the final outcome.

This prevents an incomplete goal from being marked as Failed prematurely.

Previously recorded activity remains represented in the accumulated statistics, even when the goal is no longer successful.

### 6. Time-Aware Interface Updates

Time-sensitive interfaces must account for changes that occur while the application is running.

The Activity screen refreshes its time state:

- When the view appears.
- When the application returns to the active scene phase.
- Periodically, using a Combine timer configured with a 60-second interval.

The `refreshCurrentTime()` function updates the current time, detects calendar-day transitions, and checks whether the selected date remains editable.

When a new day begins, the current day becomes the default selection. If a previously selected day becomes ineligible, the selection is restored to the current day.

This keeps the interface aligned with the application's date-validation rules without requiring the user to manually refresh the screen.

## User Interface

The interface is implemented with SwiftUI and uses state-dependent visual feedback to communicate activity status.

**Activity Calendar**

- Orange indicates a Learned record.
- Blue indicates a Frozen record.
- Light orange highlights an eligible selected date without an existing record.
- Ineligible dates cannot be selected for editing.

**Activity Controls**

The Learned and Freeze controls dynamically reflect the selected day's status and the result of business-rule validation.

**Progress Statistics**

Learned and Freeze totals are derived from the current goal's records, allowing statistics to remain consistent when a daily status changes.

## Testing and Validation

The application has been manually tested on a physical iPhone using controlled device-date scenarios.

Testing covered:

- Goal creation and lifecycle transitions.
- Learned and Freeze recording.
- Switching between daily statuses.
- Duplicate-record prevention.
- Grace-period boundaries before and after 8:00 AM.
- Automatic date selection when a new day begins.
- Calendar colors and selected-date behavior.
- Freeze allowance enforcement.
- Goal completion and failure conditions.
- Interface behavior after application reopening.

**Known limitation:** The compact weekly calendar is based on the current week. A previous day that falls outside the displayed week may not be directly accessible from that calendar, even if its grace period remains open.

## Technology Stack

| Technology | Purpose |
|---|---|
| Swift | Application programming and business logic |
| SwiftUI | Declarative user interface |
| Observation | Observable ViewModel state |
| Foundation | Date and calendar calculations |
| Combine | Periodic time-update publisher |
| Xcode | Development, building, and device testing |

## Getting Started

### Prerequisites

- macOS with a compatible version of Xcode.
- An iOS Simulator or a compatible physical iPhone.
- An Apple development signing team when running on a physical device.

### Installation

1. Clone or download the repository.
2. Open the project in Xcode.
3. Select the application target.
4. Configure signing if required.
5. Choose a compatible simulator or connected device.
6. Build and run the project using `Command + R`.

## Screenshots

The following section will showcase the application's primary screens and user interactions.

### Onboarding and Goal Setup

*Screenshot to be added.*

### Activity Dashboard

*Screenshot to be added.*

### Weekly Calendar and Daily Records

*Screenshot to be added.*

### Goal Management

*Screenshot to be added.*

### Goal Completion and Failure States

*Screenshots to be added.*

## Future Improvements

Potential improvements include:

- Extending navigation between calendar weeks while preserving date-editing restrictions.
- Expanding automated testing for time-sensitive business rules.
- Improving accessibility feedback for disabled actions.
- Strengthening long-term data storage and recovery.

---

**Learning Streak Tracker** demonstrates the implementation of date-sensitive business rules, state-driven interfaces, and goal-based activity tracking in a native iOS application.
