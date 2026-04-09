<style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');

    .cc-theme {
        --cc-bg: #f8fafc;
        --cc-surface: #ffffff;
        --cc-border: #e2e8f0;
        --cc-text: #0f172a;
        --cc-muted: rgba(100, 116, 139, 0.85);
        --cc-rail-width: 270px;
        --cc-activity-width: 330px;
        --cc-gap: 12px;
        --cc-dense-space: 12px;
        --cc-shadow-inner: inset 0 1px 0 rgba(255, 255, 255, 0.85);
        --cc-shadow-ambient: 0 16px 40px -24px rgba(15, 23, 42, 0.35);
        --cc-shadow-card: var(--cc-shadow-inner), var(--cc-shadow-ambient);
        --cc-focus-ring: 0 0 0 3px rgba(99, 102, 241, 0.2);
        font-family: 'Inter', sans-serif;
        background: radial-gradient(circle at 12% 0%, #e8edff 0%, #f8fafc 32%, #f8fafc 100%);
    }

    .cc-ultra-shell {
        width: 100%;
        min-height: calc(100vh - 7.5rem);
        border: 1px solid rgba(226, 232, 240, 0.85);
        border-radius: 18px;
        padding: var(--cc-dense-space);
    }

    .cc-ultra-grid {
        display: grid;
        grid-template-columns: var(--cc-rail-width) minmax(0, 1fr) var(--cc-activity-width);
        gap: var(--cc-gap);
        align-items: start;
    }

    .cc-main-panel {
        min-width: 0;
    }

    .cc-left-rail,
    .cc-activity-rail {
        position: sticky;
        top: 0.75rem;
        height: calc(100vh - 8.5rem);
        overflow: auto;
    }

    .cc-compact-grid-5 {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: var(--cc-dense-space);
    }

    .cc-metric-strip {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 8px;
    }

    .cc-wide-chart {
        width: 100%;
        height: 200px;
    }

    .cc-audit-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 0.65rem;
        padding: 0.55rem 0.6rem;
        border-radius: 10px;
        border: 1px solid #e2e8f0;
        background: #ffffff;
    }

    .cc-pulse-footer {
        position: sticky;
        bottom: 0;
        z-index: 20;
        display: grid;
        grid-template-columns: repeat(4, minmax(0, 1fr));
        gap: 8px;
        margin-top: 10px;
        border: 1px solid #dbe5f2;
        border-radius: 12px;
        background: rgba(255, 255, 255, 0.92);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        padding: 0.55rem 0.7rem;
    }

    .cc-pulse-item {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 0.5rem;
        padding: 0.35rem 0.45rem;
        border-right: 1px solid #e2e8f0;
    }

    .cc-pulse-item:last-child {
        border-right: 0;
    }

    .cc-density-table th,
    .cc-density-table td {
        padding-top: 0.55rem;
        padding-bottom: 0.55rem;
    }

    .cc-theme h1,
    .cc-theme h2,
    .cc-theme h3,
    .cc-theme h4 {
        letter-spacing: -0.02em;
    }

    .cc-elevated-card {
        background: var(--cc-surface);
        border: 1px solid var(--cc-border);
        border-radius: 14px;
        box-shadow: var(--cc-shadow-card);
    }

    .cc-admin-rail {
        background: rgba(255, 255, 255, 0.74);
        border: 1px solid rgba(226, 232, 240, 0.9);
        border-radius: 16px;
        box-shadow: var(--cc-shadow-card);
        backdrop-filter: blur(14px);
        -webkit-backdrop-filter: blur(14px);
    }

    .cc-rail-link {
        position: relative;
        display: flex;
        align-items: center;
        gap: 0.65rem;
        padding: 0.7rem 0.95rem;
        border-radius: 9999px;
        color: #475569;
        font-size: 0.875rem;
        font-weight: 600;
        transition: all 0.2s ease;
    }

    .cc-rail-link:hover {
        background: rgba(255, 255, 255, 0.82);
        color: #0f172a;
    }

    .cc-rail-link-active {
        color: #ffffff;
        background: linear-gradient(90deg, #4f46e5, #7c3aed);
        box-shadow: 0 10px 24px -16px rgba(79, 70, 229, 0.8);
    }

    .cc-rail-link-active::before {
        content: '';
        position: absolute;
        left: -9px;
        top: 24%;
        width: 4px;
        height: 52%;
        border-radius: 9999px;
        background: rgba(99, 102, 241, 0.95);
        box-shadow: 0 0 10px rgba(99, 102, 241, 0.65);
    }

    .cc-status-pulse {
        position: relative;
        width: 9px;
        height: 9px;
        border-radius: 9999px;
        background: #22c55e;
        box-shadow: 0 0 0 5px rgba(34, 197, 94, 0.16);
    }

    .cc-status-pulse::after {
        content: '';
        position: absolute;
        inset: -7px;
        border-radius: 9999px;
        border: 2px solid rgba(34, 197, 94, 0.22);
        animation: ccPulse 1.9s ease-out infinite;
    }

    @keyframes ccPulse {
        0% {
            transform: scale(0.66);
            opacity: 0.9;
        }
        100% {
            transform: scale(1.36);
            opacity: 0;
        }
    }

    .cc-muted {
        color: var(--cc-muted);
    }

    .cc-glass-chip {
        display: inline-flex;
        align-items: center;
        gap: 0.38rem;
        padding: 0.28rem 0.65rem;
        border-radius: 9999px;
        border: 1px solid;
        font-size: 0.74rem;
        font-weight: 700;
        letter-spacing: 0.01em;
    }

    .cc-record {
        transition: transform 0.2s ease, box-shadow 0.2s ease, background 0.2s ease;
    }

    .cc-record .cc-quick-actions {
        opacity: 0;
        transform: translateY(6px);
        transition: all 0.2s ease;
    }

    .cc-record:hover {
        transform: translateY(-2px);
        background: linear-gradient(90deg, rgba(99, 102, 241, 0.06), rgba(139, 92, 246, 0.04));
        box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.75), 0 10px 20px -18px rgba(15, 23, 42, 0.4);
    }

    .cc-record:hover .cc-quick-actions {
        opacity: 1;
        transform: translateY(0);
    }

    .cc-field {
        width: 100%;
        border: 1px solid #d6deea;
        background: #f8fbff;
        border-radius: 12px;
        padding: 0.62rem 0.85rem;
        font-size: 0.92rem;
        color: #0f172a;
        transition: box-shadow 0.2s ease, border-color 0.2s ease, background 0.2s ease;
    }

    .cc-field:focus {
        outline: none;
        border-color: #818cf8;
        background: #ffffff;
        box-shadow: var(--cc-focus-ring);
    }

    .cc-field-error {
        border-color: #fca5a5;
        background: #fff5f5;
    }

    .cc-inline-icon {
        width: 1rem;
        height: 1rem;
        color: #64748b;
    }

    .cc-stat-bar {
        height: 0.38rem;
        border-radius: 9999px;
        background: #e2e8f0;
        overflow: hidden;
    }

    .cc-stat-bar > span {
        display: block;
        height: 100%;
        border-radius: 9999px;
        background: linear-gradient(90deg, #4f46e5, #8b5cf6);
    }

    .cc-progress {
        width: 100%;
        height: 0.38rem;
        border: 0;
        border-radius: 9999px;
        overflow: hidden;
        background: #e2e8f0;
    }

    .cc-progress::-webkit-progress-bar {
        background: #e2e8f0;
        border-radius: 9999px;
    }

    .cc-progress::-webkit-progress-value {
        border-radius: 9999px;
        background: linear-gradient(90deg, #4f46e5, #8b5cf6);
    }

    .cc-progress::-moz-progress-bar {
        border-radius: 9999px;
        background: linear-gradient(90deg, #4f46e5, #8b5cf6);
    }

    @media (min-width: 1280px) {
        .cc-metric-strip {
            grid-template-columns: repeat(4, minmax(0, 1fr));
        }

        .cc-compact-grid-5 {
            grid-template-columns: repeat(5, minmax(0, 1fr));
        }
    }

    @media (max-width: 1535px) {
        .cc-ultra-grid {
            grid-template-columns: var(--cc-rail-width) minmax(0, 1fr);
        }

        .cc-activity-rail {
            display: none;
        }
    }

    @media (max-width: 1279px) {
        .cc-ultra-shell {
            padding: 10px;
        }

        .cc-ultra-grid {
            grid-template-columns: 1fr;
        }

        .cc-left-rail {
            position: relative;
            top: 0;
            height: auto;
        }

        .cc-pulse-footer {
            grid-template-columns: repeat(2, minmax(0, 1fr));
        }

        .cc-pulse-item {
            border-right: 0;
            border-bottom: 1px solid #e2e8f0;
        }

        .cc-pulse-item:nth-last-child(-n+2) {
            border-bottom: 0;
        }
    }
</style>
