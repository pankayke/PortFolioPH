<?php

namespace App\Exports;

use App\Models\Job;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Builder;
use Maatwebsite\Excel\Concerns\FromQuery;
use Maatwebsite\Excel\Concerns\WithChunkReading;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;

class JobsExport implements FromQuery, WithChunkReading, WithHeadings, WithMapping
{
    public function query(): Builder
    {
        return Job::query()
            ->select([
                'id',
                'recruiter_id',
                'title',
                'description',
                'location',
                'salary_min',
                'salary_max',
                'job_type',
                'status',
                'required_skills',
                'deadline',
                'created_at',
                'updated_at',
            ])
            ->with('recruiter:id,name')
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
            substr($job->description ?? '', 0, 100).'...',
            $job->location ?? 'N/A',
            $job->salary_min ?? 'N/A',
            $job->salary_max ?? 'N/A',
            ucfirst($job->job_type ?? 'full-time'),
            ucfirst($job->status ?? 'draft'),
            $skills,
            $this->formatDate($job->deadline, 'Y-m-d'),
            $this->formatDate($job->created_at, 'Y-m-d H:i:s'),
            $this->formatDate($job->updated_at, 'Y-m-d H:i:s'),
        ];
    }

    private function formatDate(mixed $value, string $format): string
    {
        if ($value === null || $value === '') {
            return 'N/A';
        }

        if ($value instanceof \DateTimeInterface) {
            return $value->format($format);
        }

        try {
            return Carbon::parse((string) $value)->format($format);
        } catch (\Throwable) {
            return 'N/A';
        }
    }
}
