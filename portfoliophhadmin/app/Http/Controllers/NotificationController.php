<?php

namespace App\Http\Controllers;

use App\Http\Resources\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Notifications\DatabaseNotification;

class NotificationController extends Controller
{
    /**
     * List notifications for the authenticated user.
     */
    public function index(Request $request): JsonResponse
    {
        $perPage = max(1, min(50, (int) $request->input('per_page', 20)));

        $notifications = $request->user()
            ->notifications()
            ->latest()
            ->paginate($perPage)
            ->through(fn (DatabaseNotification $notification): array => $this->serializeNotification($notification));

        return ApiResponse::paginated($notifications, 'Notifications retrieved successfully', 200);
    }

    /**
     * Mark a single notification as read.
     */
    public function markAsRead(Request $request, string $id): JsonResponse
    {
        $notification = $request->user()->notifications()->where('id', $id)->first();

        if (! $notification) {
            return ApiResponse::notFound('Notification');
        }

        if ($notification->read_at === null) {
            $notification->markAsRead();
        }

        return ApiResponse::success(
            $this->serializeNotification($notification->fresh()),
            'Notification marked as read',
            200
        );
    }

    /**
     * Mark all unread notifications as read.
     */
    public function markAllAsRead(Request $request): JsonResponse
    {
        $user = $request->user();
        $count = $user->unreadNotifications()->count();
        $user->unreadNotifications->markAsRead();

        return ApiResponse::success(
            ['marked_count' => $count],
            'All notifications marked as read',
            200
        );
    }

    private function serializeNotification(DatabaseNotification $notification): array
    {
        $payload = is_array($notification->data) ? $notification->data : [];

        return [
            'id' => $notification->id,
            'event' => $payload['event'] ?? null,
            'application_id' => $payload['application_id'] ?? null,
            'job_id' => $payload['job_id'] ?? null,
            'job_title' => $payload['job_title'] ?? null,
            'status' => $payload['status'] ?? null,
            'title' => $payload['title'] ?? 'Notification',
            'message' => $payload['message'] ?? '',
            'is_read' => $notification->read_at !== null,
            'read_at' => $notification->read_at?->toIso8601String(),
            'created_at' => $notification->created_at?->toIso8601String(),
        ];
    }
}
