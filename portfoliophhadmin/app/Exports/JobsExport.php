<?php

namespace App\Exports;

use App\Models\Job;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;

class JobsExport implements FromCollection, WithHeadings, WithMapping
{
    /**
     * @return \Illuminate\Support\Collection
     */
    public function collection()
    {
        return Job::with('recruiter')->get();
    }

    public function headings(): array
    {
        return [
            'ID',
            'Title',
            'Recruiter',
            'Company',
            'Description',
            'Location',
            'Salary Min',
            'Salary Max',
            'Job Type',
            'Status',
            'Required Skills',
            'Deadline',
            'Created At',
            'Updated At',
        ];
    }

    public function map($job): array
    {
        $skills = is_array($job->required_skills) 
            ? implode(', ', $job->required_skills) 
            : $job->required_skills;

        return [
            $job->id,
            $job->title,
            $job->recruiter?->name ?? 'N/A',
            $job->recruiter?->company_name ?? 'N/A',
            substr($job->description ?? '', 0, 100) . '...',
            $job->location ?? 'N/A',
            $job->salary_min ?? 'N/A',
            $job->salary_max ?? 'N/A',
            ucfirst($job->job_type ?? 'full-time'),
            ucfirst($job->status ?? 'draft'),
            $skills,
            $job->deadline?->format('Y-m-d') ?? 'N/A',
            $job->created_at->format('Y-m-d H:i:s'),
            $job->updated_at->format('Y-m-d H:i:s'),
        ];
    }
}
