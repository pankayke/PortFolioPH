<?php

namespace App\Http\Controllers;

use App\Models\Application;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\StreamedResponse;

class CVController extends Controller
{
    /**
     * Download current user's own CV (self-download).
     */
    public function downloadMine(Request $request): StreamedResponse
    {
        $user = $request->user();
        abort_if(! $user->resume_path, 404, 'You have not uploaded a CV yet.');

        return $this->streamCV($user);
    }

    /**
     * Download CV for a specific user.
     * Allowed: admin, self, or a recruiter who has an application from this user for their job.
     */
    public function downloadUserCV(Request $request, User $user): StreamedResponse
    {
        $viewer = $request->user();

        if ($viewer->role !== 'admin') {
            if ($viewer->role === 'recruiter') {
                // Recruiters can only download CVs of users who applied to their jobs
                $hasApplication = Application::where('user_id', $user->id)
                    ->whereHas('job', fn ($q) => $q->where('recruiter_id', $viewer->id))
                    ->exists();

                abort_unless($hasApplication, 403, 'You are not authorized to download this CV.');
            } else {
                // Job seekers can only download their own CV
                abort_if($viewer->id !== $user->id, 403, 'You are not authorized to download this CV.');
            }
        }

        abort_if(! $user->resume_path, 404, 'CV not found.');

        return $this->streamCV($user);
    }

    /**
     * Download CV for a specific applicant.
     * Allowed: admin, or the recruiter who owns the job the application belongs to.
     */
    public function downloadApplicantCV(Request $request, Application $application): StreamedResponse
    {
        $viewer = $request->user();

        $application->loadMissing('job:id,recruiter_id', 'user:id,name,resume_path');

        abort_unless(
            $viewer->role === 'admin' || $viewer->id === $application->job?->recruiter_id,
            403,
            'You are not authorized to download this applicant CV.'
        );

        $user = $application->user;
        abort_if(! $user || ! $user->resume_path, 404, 'Applicant CV not found.');

        return $this->streamCV($user);
    }

    /**
     * Stream the CV file safely via the Storage facade.
     * Using Storage::disk() instead of raw file_exists/storage_path prevents path traversal attacks.
     */
    private function streamCV(User $user): StreamedResponse
    {
        $disk = Storage::disk('public');
        abort_unless($disk->exists($user->resume_path), 404, 'CV file not found on disk.');

        $filename = 'CV_'.Str::slug($user->name).'_'.now()->format('Y-m-d').'.pdf';

        return response()->streamDownload(function () use ($disk, $user): void {
            readfile($disk->path($user->resume_path));
        }, $filename, [
            'Content-Type' => 'application/pdf',
        ]);
    }
}
