<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255', 'min:2'],
            'email' => ['required', 'email', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/'],
            'role' => ['required', Rule::in('job_seeker', 'recruiter')],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Full name is required',
            'name.min' => 'Name must be at least 2 characters',
            'email.required' => 'Email address is required',
            'email.email' => 'Email must be a valid email address',
            'email.unique' => 'Email is already registered',
            'password.required' => 'Password is required',
            'password.min' => 'Password must be at least 8 characters',
            'password.regex' => 'Password must contain uppercase, lowercase, and numbers',
            'role.required' => 'Role selection is required',
            'role.in' => 'Invalid role selected',
        ];
    }
}
