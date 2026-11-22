<?php
require __DIR__ . '/db.php';
try {
    $user = current_user(db());
    if (!$user) respond(401, ['error' => 'Unauthorized']);
    respond(200, [
        'app_title' => 'CourtBook',
        'message'   => 'Welcome back, ' . $user['name'] . '!',
        'user'      => $user,
    ]);
} catch (Throwable $e) {
    respond(500, ['error' => 'Server error']);
}