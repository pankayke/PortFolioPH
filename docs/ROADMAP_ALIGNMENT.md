# External Roadmap Alignment (SmartDentQue → PortFolioPH)

## Context
The provided external roadmap (`SmartDentQue`) is for a dental queue/appointment domain and does not map 1:1 to `PortFolioPH` (student portfolio builder).

To follow the roadmap **responsibly**, execution is aligned by sprint discipline and delivery cadence, while adapting feature scope to this repository’s architecture and product goals.

## Mapping Strategy
- Keep sprint sequencing, delivery rigor, and validation gates.
- Translate domain-specific tasks to PortfolioPH-equivalent modules.
- Implement only tasks that fit existing project architecture (Flutter + Provider + SQLite).

## Current Alignment Snapshot
| External Theme | PortfolioPH Equivalent | Status |
|---|---|---|
| Sprint 1 Infrastructure | Core setup, routing, DB, theme | ✅ Completed |
| Sprint 2 Core user flow | Auth + profile setup | ✅ Completed |
| Sprint 3 CRUD-heavy feature set | Portfolio Projects CRUD + gallery | ✅ Completed |
| Sprint 4 records/media modules | Resume Certifications + certificate media | ✅ In Progress (first slice implemented) |

## Implemented in This Session (Sprint 4 Slice)
1. Certification state management via `CertificationProvider`.
2. Certificate image upload/delete service with local persistent file storage.
3. Resume tab upgraded from placeholder to certification CRUD list with search.
4. Add/Edit certification form with:
   - Validation (required fields, URL validation)
   - Issue/expiry date handling
   - Optional image attachment and replacement
5. App dependency graph updated to register `CertificationProvider`.

## Next Recommended Sprint 4 Steps
1. Add `Education` CRUD in Resume module.
2. Add `Work Experience` CRUD in Resume module.
3. Add timeline/section aggregation for complete Resume preview.
4. Add widget tests for Resume certification flow.

## Validation Summary
- `flutter analyze` executed after implementation.
- No new analyzer errors in changed files.
- Existing analyzer infos/warnings are legacy issues outside this slice.
