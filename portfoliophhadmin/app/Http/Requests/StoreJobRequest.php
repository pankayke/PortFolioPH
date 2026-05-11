<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreJobRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->role === 'recruiter';
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:255', 'min:5'],
            'description' => ['required', 'string', 'min:20', 'max:5000'],
            'location' => ['required', 'string', 'max:255'],
            'salary_min' => ['nullable', 'numeric', 'min:0'],
            'salary_max' => ['nullable', 'numeric', 'gte:salary_min'],
            'job_type' => ['required', Rule::in(['full_time', 'part_time', 'contract', 'freelance'])],
            'required_skills' => ['nullable', 'array'],
            'required_skills.*' => ['string', 'max:100'],
            'deadline' => ['nullable', 'date', 'after:now'],
        ];
    }

    public function messages(): array
    {
        return [
            'title.required' => 'Job title is required',
            'title.min' => 'Job title must be at least 5 characters',
            'description.required' => 'Job description is required',
            'description.min' => 'Description must be at least 20 characters',
            'location.required' => 'Location is required',
            'salary_max.gte' => 'Max salary must be greater than or equal to min salary',
            'job_type.required' => 'Job type is required',
            'job_type.in' => 'Invalid job type',
            'deadline.after' => 'Deadline must be in the future',
        ];
    }
}
