<?php

namespace App\Observers;

use App\Models\AuditLog;

class AuditObserver
{
    public function created($model): void
    {
        $this->logAction($model, 'created');
    }

    public function updated($model): void
    {
        $this->logAction($model, 'updated');
    }

    public function deleted($model): void
    {
        $this->logAction($model, 'deleted');
    }

    private function logAction($model, string $action): void
    {
        if (auth()->check()) {
            AuditLog::create([
                'user_id' => auth()->id(),
                'action' => $action,
                'model_type' => get_class($model),
                'model_id' => $model->id,
                'old_values' => $action === 'updated' ? $model->getOriginal() : null,
                'new_values' => $action !== 'deleted' ? $model->getAttributes() : null,
                'ip_address' => request()->ip(),
            ]);
        }
    }
}
