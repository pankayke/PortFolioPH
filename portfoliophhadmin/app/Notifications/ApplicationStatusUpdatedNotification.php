<?php

namespace App\Notifications;

use App\Models\Application;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;

class ApplicationStatusUpdatedNotification extends Notification
{
    use Queueable;

    public function __construct(private readonly Application $application)
    {
    }

    /**
     * Get the notification's delivery channels.
     */
    public function via(object $notifiable): array
    {
        return ['database'];
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray(object $notifiable): array
    {
        $status = (string) $this->application->status;
        $jobTitle = (string) ($this->application->job?->title ?? 'your application');
        $isAccepted = $status === 'accepted';

        return [
            'event' => 'application.status.updated',
            'application_id' => $this->application->id,
            'job_id' => $this->application->job_id,
            'job_title' => $jobTitle,
            'status' => $status,
            'title' => $isAccepted ? 'Application accepted' : 'Application update',
            'message' => $isAccepted
                ? "Congratulations! You have been accepted for {$jobTitle}."
                : "Your application for {$jobTitle} has been rejected.",
        ];
    }
}
