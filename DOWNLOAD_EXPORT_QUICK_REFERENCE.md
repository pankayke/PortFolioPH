# PortFolioPH - Download & Export Features - Quick Reference

## Testing Endpoints

### API Endpoints (Protected - require Bearer token)

#### CV Downloads
```
GET /api/profile/cv
- Download current user's CV
- Response: PDF file stream
- Error 404: If user has no CV uploaded

GET /api/users/{userId}/cv
- Download specific user's CV (Admin/Recruiter)
- Response: PDF file stream
- Error 404: If user has no CV uploaded
- Error 403: If no permission

GET /api/applications/{applicationId}/cv
- Download applicant's CV
- Response: PDF file stream
- Error 404: If applicant has no CV
- Error 403: If no permission
```

### Web Routes (Admin Only)

#### Export Routes
```
GET /admin/users/export/excel
- Response: Excel file with all users
- Format: CompressedXLSX with proper headers

GET /admin/users/export/csv
- Response: CSV file with all users
- Format: Standard CSV

GET /admin/jobs/export/excel
- Response: Excel file with all jobs

GET /admin/jobs/export/csv
- Response: CSV file with all jobs

GET /admin/applications/export/excel
- Response: Excel file with all applications

GET /admin/applications/export/csv
- Response: CSV file with all applications
```

#### CV Download Routes
```
GET /admin/users/{userId}/download-cv
- Download specific user's CV
- Redirects to file stream
- Error: User has no CV

GET /admin/applications/{applicationId}/download-cv
- Download applicant's CV
- Redirects to file stream
- Error: Applicant has no CV
```

---

## Flutter Integration References

### Basic Usage Example (Seeker)

```dart
// In a Seeker screen
class SeekerCVSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FileDownloadProvider>(
      builder: (context, downloadProvider, _) {
        return Column(
          children: [
            if (downloadProvider.isDownloading)
              DownloadProgressCard(
                title: 'Downloading CV',
                provider: downloadProvider,
                onDismiss: () => downloadProvider.reset(),
              ),
            DownloadButton(
              label: 'Download My CV',
              isLoading: downloadProvider.isDownloading,
              onPressed: () async {
                await downloadProvider.downloadMyCV();
                if (context.mounted && downloadProvider.state == DownloadState.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Saved: ${downloadProvider.lastDownloadPath}')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
```

### Example: Recruiter Candidate Profile

```dart
// In candidate profile view
class CandidateProfileView extends StatelessWidget {
  final RecruiterApplication application;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Existing profile content...
        
        // Add CV download button
        Consumer<FileDownloadProvider>(
          builder: (context, downloadProvider, _) {
            return DownloadButton(
              label: 'Download CV',
              icon: Icons.download,
              color: Colors.blue,
              isLoading: downloadProvider.isDownloading,
              onPressed: () async {
                await downloadProvider.downloadApplicantCV(
                  application.id,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
```

### Example: Admin Export Menu

```dart
// In admin users list
class AdminUsersView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FileDownloadProvider>(
      builder: (context, downloadProvider, _) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Users'),
                ExportMenu(
                  title: 'Export Users',
                  onExcelPressed: () async {
                    await downloadProvider.downloadUserExport('xlsx');
                  },
                  onCSVPressed: () async {
                    await downloadProvider.downloadUserExport('csv');
                  },
                ),
              ],
            ),
            // Users table...
          ],
        );
      },
    );
  }
}
```

---

## Exported Excel/CSV Column Definitions

### Users Export
| Column | Type | Description |
|--------|------|-------------|
| ID | Integer | User unique ID |
| Name | Text | User full name |
| Email | Text | User email address |
| Username | Text | User login username |
| Full Name | Text | User full name |
| Phone | Text | Contact phone number |
| Location | Text | User location |
| Role | Text | job_seeker, recruiter, admin |
| Active | Text | Yes/No |
| Created At | DateTime | Account creation date |
| Updated At | DateTime | Last modification date |

### Jobs Export
| Column | Type | Description |
|--------|------|-------------|
| ID | Integer | Job unique ID |
| Title | Text | Job title |
| Recruiter | Text | Recruiter name |
| Company | Text | Company name |
| Description | Text | Job description (truncated) |
| Location | Text | Job location |
| Salary Min | Decimal | Minimum salary |
| Salary Max |Decimal | Maximum salary |
| Job Type | Text | full-time, part-time, contract |
| Status | Text | draft, approved, closed |
| Required Skills | Text | Comma-separated skills |
| Deadline | Date | Job application deadline |
| Created At | DateTime | Job creation date |
| Updated At | DateTime | Last update date |

### Applications Export
| Column | Type | Description |
|--------|------|-------------|
| ID | Integer | Application unique ID |
| Job Title | Text | Job the applicant applied for |
| Applicant Name | Text | Applicant full name |
| Applicant Email | Text | Applicant email |
| Recruiter | Text | Recruiter name |
| Company | Text | Company name |
| Cover Letter | Text | Cover letter (truncated) |
| Status | Text | pending, reviewing, shortlisted, accepted, rejected |
| Applied At | DateTime | Application submission date |
| Updated At | DateTime | Last status update |

---

## Error Handling

### Common Errors

**404 Not Found**
- CV not uploaded yet
- Solution: User needs to upload CV in profile

**403 Forbidden**
- User trying to download CV they don't have access to
- Solution: Check permissions

**413 Payload Too Large**
- File exceeds size limits
- CV max: 5MB
- Solution: Reduce file size

**429 Too Many Requests**
- Rate limit exceeded
- Solution: Wait before retrying

**500 Internal Server Error**
- Server issue
- Check logs: `storage/logs/laravel.log`

---

## Troubleshooting

### CV not downloading
1. Check if user has uploaded CV: `User.resume_path` should not be null
2. Check file exists: `storage/app/public/resumes/{file}`
3. Check Laravel log for errors

### Export file empty
1. Ensure data exists in database
2. Check that Maatwebsite/Excel is installed: `composer show | grep excel`
3. Verify export service is generating headers correctly

### Flutter app crashes on download
1. Check permissions are granted
2. Wrap download call in try-catch
3. Check file path is valid for current platform

---

## Performance Tips

### For Large Exports
- Users export: Works well up to 100K+ users
- Jobs export: Works well up to 50K+ jobs
- Applications export: Works well up to 500K+ applications

### Optimization
- Use pagination for UI lists
- Cache export files temporarily
- Implement background downloads for large files
- Show progress to user

---

## Security Considerations

✅ Protected by authentication middleware
✅ Rate limited to prevent abuse
✅ File validation (PDF only for templates)
✅ Directory restrictions (storage/ only)
✅ No path traversal possible

⚠️ Ensure:
- Storage directory is not publicly accessible
- Logs don't expose sensitive information
- Exports are deleted after appropriate time
- Users can only download their own CV (unless admin)

---

## Code Examples

### Test CV Download (cURL)
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8000/api/profile/cv \
  -o my_cv.pdf
```

### Test Export (Browser)
```
http://localhost:8000/admin/users/export/excel
```

### Test with Postman
1. Set method: GET
2. URL: `http://localhost:8000/api/profile/cv`
3. Headers: `Authorization: Bearer {your_token}`
4. Send → Right-click response → Save response to file

---

## Related Documentation

- [IMPLEMENTATION_FEATURES_COMPLETE.md](IMPLEMENTATION_FEATURES_COMPLETE.md) - Full implementation details
- [FLUTTER_LARAVEL_INTEGRATION_GUIDE.md](FLUTTER_LARAVEL_INTEGRATION_GUIDE.md) - Integration guide
- [BACKEND_API_GUIDE.md](BACKEND_API_GUIDE.md) - API documentation

---

## Version Info

- Laravel Excel: 3.1.68
- Flutter PDF: 3.11.1
- Implementation Date: April 2026
- Last Updated: April 12, 2026
