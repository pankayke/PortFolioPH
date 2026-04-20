<?php

namespace App\Exports;

use App\Models\Application;
use Illuminate\Database\Eloquent\Builder;
use Maatwebsite\Excel\Concerns\FromQuery;
use Maatwebsite\Excel\Concerns\WithChunkReading;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;

class ApplicationsExport implements FromQuery, WithChunkReading, WithHeadings, WithMapping
{
    public function query(): Builder
    {
        return Application::query()
            ->select([
                'id',
                'user_id',
                'job_id',
                'cover_letter',
                'status',
                'created_at',
                'updated_at',
            ])
            ->with([
                'user:id,name,email',
                'job:id,title,recruiter_id',
                'job.recruiter:id,name,company_name',
            ])
            ->latest('id');
    }

    public function chunkSize(): int
    {
        return 1000;
    }

    public function headings(): array
    {
        return [
            'ID',
            'Job Title',
            'Applicant Name',
            'Applicant Email',
            'Recruiter',
            'Company',
            'Cover Letter',
            'Status',
            'Applied At',
            'Updated At',
        ];
    }

    public function map($application): array
    {
        return [
            $application->id,
            $application->job?->title ?? 'N/A',
            $application->user?->name ?? 'N/A',
            $application->user?->email ?? 'N/A',
            $application->job?->recruiter?->name ?? 'N/A',
            $application->job?->recruiter?->company_name ?? 'N/A',
            substr($application->cover_letter ?? '', 0, 100).(strlen($application->cover_letter ?? '') > 100 ? '...' : ''),
            ucfirst($application->status ?? 'pending'),
            $application->created_at->format('Y-m-d H:i:s'),
            $application->updated_at->format('Y-m-d H:i:s'),
        ];
    }
}
