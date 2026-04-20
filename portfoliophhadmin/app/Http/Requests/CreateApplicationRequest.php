<?php

namespace App\Http\Requests;

use App\Models\Application;
use App\Models\Job;
use Illuminate\Foundation\Http\FormRequest;

class CreateApplicationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'job_id' => [
                'required',
                'integer',
                'exists:jobs,id',
                function ($attribute, $value, $fail) {
                    $job = Job::query()->select(['id', 'status'])->find($value);
                    if ($job && $job->status !== 'approved') {
                        $fail('Job is not open for applications.');

                        return;
                    }

                    // Check if user already applied to this job
                    $exists = Application::where('user_id', $this->user()?->id)
                        ->where('job_id', $value)
                        ->exists();

                    if ($exists) {
                        $fail('You have already applied to this job.');
                    }
                },
            ],
            'cover_letter' => ['nullable', 'string', 'max:2000'],
        ];
    }

    public function messages(): array
    {
        return [
            'job_id.required' => 'Job is required',
            'job_id.exists' => 'Job not found',
            'cover_letter.max' => 'Cover letter must not exceed 2000 characters',
        ];
    }
}
