<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Application;
use Illuminate\Support\Facades\Storage;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class CVController extends Controller
{
    /**
     * Download current user's CV
     */
    public function downloadMine(Request $request): BinaryFileResponse
    {
        $user = $request->user();
        
        return $this->downloadUserCV($user);
    }

    /**
     * Download CV for a specific user (admin/recruiter access)
     */
    public function downloadUserCV(User $user): BinaryFileResponse
    {
        if (!$user->resume_path) {
            abort(404, 'CV not found');
        }

        $path = storage_path("app/public/{$user->resume_path}");

        if (!file_exists($path)) {
            abort(404, 'CV file not found');
        }

        return response()->download(
            $path,
            'CV_' . Str::slug($user->name) . '_' . now()->format('Y-m-d') . '.pdf'
        );
    }

    /**
     * Download CV for an applicant
     */
    public function downloadApplicantCV(Application $application): BinaryFileResponse
    {
        $user = $application->user;
        
        if (!$user->resume_path) {
            abort(404, 'Applicant CV not found');
        }

        $path = storage_path("app/public/{$user->resume_path}");

        if (!file_exists($path)) {
            abort(404, 'Applicant CV file not found');
        }

        return response()->download(
            $path,
            'CV_' . Str::slug($user->name) . '_' . now()->format('Y-m-d') . '.pdf'
        );
    }
}
