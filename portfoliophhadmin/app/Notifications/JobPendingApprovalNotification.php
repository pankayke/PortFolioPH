<?php

namespace App\Notifications;

use App\Models\Job;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class JobPendingApprovalNotification extends Notification implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new notification instance.
     */
    public function __construct(public Job $job) {}

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['database'];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail(object $notifiable): MailMessage
    {
        // Admins might get too many emails, so we default to database only.
        return new MailMessage;
    }

    /**
     * Get the array representation of the notification.
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        $recruiterName = $this->job->recruiter->name ?? 'A recruiter';

        return [
            'event' => 'job_pending_approval',
            'job_id' => $this->job->id,
            'job_title' => $this->job->title,
            'title' => 'Job Pending Approval',
            'message' => "{$recruiterName} posted a new job requiring approval: {$this->job->title}.",
        ];
    }
}
