## Summary

- Jira/Story: 
- What changed:
- Why this change is needed:
- Scope (files/LOC):

## Plan Lock (Mandatory)

- [ ] `tasks/todo.md` updated before coding
- [ ] Executable acceptance criteria defined
- [ ] Risk level assessed (1-10): 
- [ ] Rollback strategy documented

## Architecture & Design

- [ ] Change follows Clean Architecture boundaries
- [ ] No cross-layer leakage introduced
- [ ] Root-cause fix (not a bandaid)
- [ ] Minimal viable scope used (prefer <=3 files / <=50 LOC unless justified)

## Verification Evidence (Mandatory)

### API Route-Test Mapping (Required for touched API routes)
- [ ] List each touched API route and the covering Feature test method(s)
- [ ] Include auth/authorization negative-path coverage for each protected route
- [ ] Include validation/edge-case coverage for each write route

| Route | Controller Action | Feature Test Methods |
|---|---|---|
| /api/applications/bulk-status | ApplicationController@bulkUpdateStatus | ApplicationControllerTest::test_recruiter_can_bulk_update_only_owned_applications; ApplicationControllerTest::test_bulk_update_status_requires_recruiter_authorization; ApplicationControllerTest::test_bulk_update_status_validates_payload; ApplicationControllerTest::test_bulk_update_status_without_auth_fails |
| /api/applications/{application} | ApplicationController@destroy | ApplicationControllerTest::test_job_seeker_can_withdraw_pending_application; ApplicationControllerTest::test_withdraw_non_pending_application_fails |
| /api/notifications | NotificationController@index | NotificationControllerTest::test_list_notifications_returns_authenticated_users_notifications; NotificationControllerTest::test_notifications_index_caps_per_page_to_50; NotificationControllerTest::test_notification_endpoints_require_authentication |
| /api/notifications/{id}/read | NotificationController@markAsRead | NotificationControllerTest::test_mark_notification_as_read_updates_read_at; NotificationControllerTest::test_mark_notification_as_read_for_other_user_returns_404; NotificationControllerTest::test_notification_endpoints_require_authentication |
| /api/notifications/read-all | NotificationController@markAllAsRead | NotificationControllerTest::test_mark_all_notifications_as_read_marks_all_unread_records; NotificationControllerTest::test_notification_endpoints_require_authentication |
| /api/saved-jobs | SavedJobController@index/store | SavedJobControllerTest::test_job_seeker_can_list_saved_jobs; SavedJobControllerTest::test_job_seeker_can_save_job; SavedJobControllerTest::test_non_job_seeker_cannot_save_job; SavedJobControllerTest::test_duplicate_save_job_returns_conflict; SavedJobControllerTest::test_saved_jobs_endpoints_require_authentication |
| /api/saved-jobs/{jobId} | SavedJobController@destroy | SavedJobControllerTest::test_job_seeker_can_unsave_job; SavedJobControllerTest::test_unsave_missing_saved_job_returns_404; SavedJobControllerTest::test_saved_jobs_endpoints_require_authentication |

### Automated checks
- [ ] Lint passes
- [ ] Tests pass
- [ ] Coverage acceptable for touched logic (target >=80% where practical)

### Manual validation
- [ ] Repro steps documented
- [ ] Proof-of-fix documented
- [ ] Edge cases tested and listed

### Regression checks
- [ ] Diff reviewed for behavioral regressions
- [ ] Performance impact assessed (if applicable)
- [ ] No unintended UI/UX side effects

## Failure Recovery

- [ ] If plan deviation/regression occurred, task was paused and re-planned
- [ ] Post-change rollback path verified

## Continuous Improvement

- [ ] Any correction/failed attempt logged to `tasks/lessons.md`
- [ ] Prevention rules added (min 3) when applicable

## Reviewer Checklist

- [ ] Meets senior-engineer quality bar
- [ ] Naming/readability maintainable long-term
- [ ] Error handling and input validation are sufficient
- [ ] Security/privacy implications considered

## Notes for Reviewer

- Known limitations:
- Follow-up tasks:
- Screenshots / logs / links:
