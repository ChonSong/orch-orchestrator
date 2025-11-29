# Project Requirements & Changelog

## 📋 Current Requirements (Active)
- [ ] **Chat Sidebar & Session Details**: 
  - Implement a sidebar in the dashboard to show real-time progress updates.
  - Allow users to click on a task log entry to view the full chat history/trace for that session.
  - **Status**: In Progress
  - **Added**: 2025-11-29

- [ ] **Session Details UI Polish**:
  - Separate Input and Output into distinct, styled boxes.
  - Fix text truncation issues.
  - **Status**: In Progress
  - **Added**: 2025-11-29

## ✅ Completed Requirements
- [x] **Orchestrator Documentation**: Created `docs/ORCHESTRATOR_README.md` covering all modes and architecture.
- [x] **Persistent Task History**: 
  - Implemented `orch_history.json` to save all task executions.
  - Added metrics (Cost, Models, Duration) to history.
  - Added `UserInteraction` module for CLI questions.
- [x] **Dashboard Integration**:
  - Connected `orch` to `observe-dashboard` via `live_state.json`.
  - Added `/api/persistent-history` and `/api/telemetry` endpoints.
  - Updated frontend to merge and display live telemetry + persistent history.
  - Fixed "No active agents" issue by ensuring absolute paths for state files.
- [x] **Visual Improvements**:
  - Updated `#send-btn` to blue background/white text.
  - Added "LIVE" indicators for active steps.

## 🔮 Future Requirements (Backlog)
- [ ] **Interactive Chat**: Allow users to reply to the orchestrator directly from the dashboard (currently CLI only).
- [ ] **Filter & Search**: Add search functionality to the history log.
- [ ] **Export**: Ability to export session logs as Markdown/PDF.
