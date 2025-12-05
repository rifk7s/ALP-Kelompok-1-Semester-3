<?php

return [

    'credentials' => [
        'file' => base_path(env('FIREBASE_CREDENTIALS')),
    ],

    'database' => [
        'url' => env('FIREBASE_DB_URL'),
    ],
    'project_id' => env('FIREBASE_PROJECT_ID'),

    'projects' => [
        'app' => [
            'credentials' => [
                'file' => base_path(env('FIREBASE_CREDENTIALS')),
            ],
            'database' => [
                'url' => env('FIREBASE_DB_URL'),
            ],
            'project_id' => env('FIREBASE_PROJECT_ID'),
        ],
    ],

];
