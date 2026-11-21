import {defineConfig} from '@playwright/test';
export default defineConfig({testDir:'./tests/system',workers:1,use:{baseURL:'http://127.0.0.1:4173',headless:true,channel:'chromium'},webServer:{command:'npm run start -- --port 4173',url:'http://127.0.0.1:4173',reuseExistingServer:false},reporter:'list'});
