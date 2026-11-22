<?php
require __DIR__ . '/db.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') respond(405, ['error' => 'Method not allowed']);
try {
    $t = bearer_token();
    if (!$t) respond(401, ['error' => 'Unauthorized']);
    $pdo = db();
    $st = $pdo->prepare('DELETE FROM sessions WHERE token_hash = ?');
    $st->execute([hash('sha256', $t)]);
    respond(200, ['message' => 'Logged out']);
} catch (Throwable $e) {
    respond(500, ['error' => 'Server error']);
}