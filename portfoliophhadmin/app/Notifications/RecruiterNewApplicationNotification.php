<?php

namespace App\Notifications;

use App\Models\Application;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class RecruiterNewApplicationNotification extends Notification implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new notification instance.
     */
    public function __construct(public Application $application) {}

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['database', 'mail'];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail(object $notifiable): MailMessage
    {
        $applicantName = $this->application->user->name ?? 'A candidate';
        $jobTitle = $this->application->job->title ?? 'your job';

        return (new MailMessage)
            ->subject("New Application: {$jobTitle}")
            ->greeting("Hello {$notifiable->name},")
            ->line("{$applicantName} has just applied for the position: {$jobTitle}.")
            ->action('View Application', url('/applications/'.$this->application->id))
            ->line('Thank you for using PortFolioPH!');
    }

    /**
     * Get the array representation of the notification.
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        return [
            'event' => 'new_application',
            'application_id' => $this->application->id,
            'job_id' => $this->application->job_id,
            'job_title' => $this->application->job->title ?? 'Unknown Job',
            'title' => 'New Application Received',
            'message' => "{$this->application->user->name} applied for {$this->application->job->title}.",
        ];
    }
}
