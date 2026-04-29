import { defineConfig } from 'vite'
import laravel from 'laravel-vite-plugin'

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/js/app.tsx'], // or your entry file
            refresh: true,
        }),
    ],

    base: '/build/', 
})