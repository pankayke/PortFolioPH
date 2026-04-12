<?php

namespace App\Exports;

use App\Models\Application;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;

class ApplicationsExport implements FromCollection, WithHeadings, WithMapping
{
    /**
     * @return \Illuminate\Support\Collection
     */
    public function collection()
    {
        return Application::with(['user', 'job'])->get();
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
            substr($application->cover_letter ?? '', 0, 100) . (strlen($application->cover_letter ?? '') > 100 ? '...' : ''),
            ucfirst($application->status ?? 'pending'),
            $application->created_at->format('Y-m-d H:i:s'),
            $application->updated_at->format('Y-m-d H:i:s'),
        ];
    }
}
