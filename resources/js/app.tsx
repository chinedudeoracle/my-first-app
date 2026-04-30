import '../css/app.css';

import { createInertiaApp } from '@inertiajs/react';
import { createRoot } from 'react-dom/client';
import { Toaster } from '@/components/ui/sonner';
import { TooltipProvider } from '@/components/ui/tooltip';
import { initializeTheme } from '@/hooks/use-appearance';
import AppLayout from '@/layouts/app-layout';
import AuthLayout from '@/layouts/auth-layout';
import SettingsLayout from '@/layouts/settings/layout';

const appName = import.meta.env.VITE_APP_NAME || 'Laravel';

createInertiaApp({
    title: (title) => (title ? `${title} - ${appName}` : appName),

    resolve: (name) => {
        const pages = import.meta.glob('./pages/**/*.tsx', { eager: true });
        const page = pages[`./pages/${name}.tsx`] as any;

        if (!page) {
            throw new Error(`Page not found: ${name}`);
        }

        const component = page.default;

        if (name === 'welcome') {
            component.layout = undefined;
        } else if (name.startsWith('auth/')) {
            component.layout = (page: React.ReactNode) => <AuthLayout>{page}</AuthLayout>;
        } else if (name.startsWith('settings/')) {
            component.layout = (page: React.ReactNode) => (
                <AppLayout>
                    <SettingsLayout>{page}</SettingsLayout>
                </AppLayout>
            );
        } else {
            component.layout = (page: React.ReactNode) => <AppLayout>{page}</AppLayout>;
        }

        return component;
    },

    setup({ el, App, props }) {
        createRoot(el).render(
            <TooltipProvider delayDuration={0}>
                <App {...props} />
                <Toaster />
            </TooltipProvider>
        );
    },

    progress: {
        color: '#4B5563',
    },
});

initializeTheme();