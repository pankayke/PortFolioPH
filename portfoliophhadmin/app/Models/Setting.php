<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Setting extends Model
{
    use HasFactory;

    protected $fillable = ['key', 'value', 'type'];

    /**
     * Helper to get a setting value with fallback.
     */
    public static function get(string $key, $default = null)
    {
        $setting = self::where('key', $key)->first();
        if (! $setting) {
            return $default;
        }

        return match ($setting->type) {
            'boolean' => filter_var($setting->value, FILTER_VALIDATE_BOOLEAN),
            'integer' => (int) $setting->value,
            'json' => json_decode($setting->value, true),
            default => $setting->value,
        };
    }

    /**
     * Helper to set a setting value.
     */
    public static function set(string $key, $value, string $type = 'string')
    {
        if (is_bool($value)) {
            $value = $value ? '1' : '0';
            $type = 'boolean';
        } elseif (is_int($value)) {
            $value = (string) $value;
            $type = 'integer';
        } elseif (is_array($value)) {
            $value = json_encode($value);
            $type = 'json';
        }

        return self::updateOrCreate(
            ['key' => $key],
            ['value' => $value, 'type' => $type]
        );
    }
}
