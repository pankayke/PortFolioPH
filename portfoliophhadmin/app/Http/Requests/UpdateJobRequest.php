<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateJobRequest extends FormRequest
{
    public function authorize(): bool
    {
        $user = $this->user();

        return $user?->role === 'recruiter';
    }

    public function rules(): array
    {
        return [
            'title' => ['sometimes', 'string', 'max:255', 'min:5'],
            'description' => ['sometimes', 'string', 'min:20', 'max:5000'],
            'location' => ['sometimes', 'string', 'max:255'],
            'salary_min' => ['nullable', 'numeric', 'min:0'],
            'salary_max' => ['nullable', 'numeric', 'gte:salary_min'],
            'job_type' => ['sometimes', Rule::in(['full_time', 'part_time', 'contract', 'freelance'])],
            'required_skills' => ['nullable', 'array'],
            'required_skills.*' => ['string', 'max:100'],
            'deadline' => ['nullable', 'date', 'after:now'],
            'status' => ['sometimes', Rule::in(['draft', 'pending', 'approved', 'closed'])],
        ];
    }

    public function messages(): array
    {
        return [
            'title.min' => 'Title must be at least 5 characters',
            'description.min' => 'Description must be at least 20 characters',
            'salary_max.gte' => 'Max salary must be >= min salary',
            'job_type.in' => 'Invalid job type',
            'status.in' => 'Invalid status',
            'deadline.after' => 'Deadline must be in the future',
        ];
    }
}
