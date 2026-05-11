<?php

namespace App\Services;

use App\Exports\ApplicationsExport;
use App\Exports\JobsExport;
use App\Exports\UsersExport;
use App\Models\Application;
use App\Models\User;
use Maatwebsite\Excel\Facades\Excel;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class ExportService
{
    /**
     * Export users to Excel
     */
    public function exportUsers(string $format = 'xlsx'): BinaryFileResponse
    {
        return Excel::download(
            new UsersExport,
            'users_export_'.now()->format('Y-m-d_H-i-s').'.'.$format,
            $format === 'csv' ? 'Csv' : 'Xlsx'
        );
    }

    /**
     * Export jobs to Excel
     */
    public function exportJobs(string $format = 'xlsx'): BinaryFileResponse
    {
        return Excel::download(
            new JobsExport,
            'jobs_export_'.now()->format('Y-m-d_H-i-s').'.'.$format,
            $format === 'csv' ? 'Csv' : 'Xlsx'
        );
    }

    /**
     * Export applications to Excel
     */
    public function exportApplications(string $format = 'xlsx'): BinaryFileResponse
    {
        return Excel::download(
            new ApplicationsExport,
            'applications_export_'.now()->format('Y-m-d_H-i-s').'.'.$format,
            $format === 'csv' ? 'Csv' : 'Xlsx'
        );
    }

    /**
     * Download CV for a user
     */
    public function downloadCV(User $user): BinaryFileResponse
    {
        $cvPath = $user->resume_path;

        if (! $cvPath || ! file_exists(storage_path("app/$cvPath"))) {
            abort(404, 'CV not found');
        }

        return response()->download(
            storage_path("app/$cvPath"),
            'CV_'.$user->name.'_'.now()->format('Y-m-d').'.pdf'
        );
    }

    /**
     * Download CV for an applicant from application
     */
    public function downloadApplicantCV(Application $application): BinaryFileResponse
    {
        $user = $application->user;
        $cvPath = $user->resume_path;

        if (! $cvPath || ! file_exists(storage_path("app/$cvPath"))) {
            abort(404, 'Applicant CV not found');
        }

        return response()->download(
            storage_path("app/$cvPath"),
            'CV_'.$user->name.'_'.now()->format('Y-m-d').'.pdf'
        );
    }

    /**
     * Export applicants with CVs (creates a package with Excel and CVs)
     * Note: This would require more complex implementation with ZIP files
     */
    public function exportApplicantsWithCVs(string $jobId): BinaryFileResponse
    {
        return Excel::download(
            new ApplicationsExport,
            'applicants_job_'.$jobId.'_'.now()->format('Y-m-d_H-i-s').'.xlsx'
        );
    }
}
